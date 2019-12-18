require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id=nil,name,grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY, 
          name TEXT, 
          grade INTEGER
          )
          SQL
    DB[:conn].execute(sql) 
  end

  def self.drop_table
    sql = <<-SQL 
      DROP TABLE students
      SQL
    DB[:conn].execute(sql) 
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL 
        INSERT into students (name,grade)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name,grade)
    sql = <<-SQL 
        INSERT into students (name,grade)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql,name,grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.new_from_db(db_info)
    Student.new(db_info[0],db_info[1],db_info[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL 
        SELECT *
        FROM students
        WHERE name = ?
      SQL
      new_student = DB[:conn].execute(sql,name)[0]
      Student.new(new_student[0],new_student[1],new_student[2])
  end



  def update
    sql = <<-SQL 
        UPDATE students 
        SET name = ?, grade = ? 
        WHERE id = ?
      SQL
      DB[:conn].execute(sql,self.name,self.grade,self.id)
  end
end
