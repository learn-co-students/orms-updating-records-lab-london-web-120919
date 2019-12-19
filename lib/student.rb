require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    create table if not exists students (
      id integer primary key,
      name text,
      grade integer
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    drop table students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
    insert into students (name, grade) values(?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name:, grade:)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
