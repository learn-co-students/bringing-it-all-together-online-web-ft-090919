
require 'pry'
class Dog

attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)

  @name = name
  @breed = breed
  @id = id
end

def self.create_table
sql = <<-SQL
CREATE TABLE dogs (
  id INTEGER,
  name TEXT,
  breed,TEXT );
SQL

DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<-SQL
  DROP TABLE dogs
  SQL

  DB[:conn].execute(sql)
  end

def save
  sql = <<-SQL
    INSERT INTO dogs(name, breed)
    VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end

def self.create(dog_hash)
  self.new(dog_hash).save

end

def self.new_from_db(db_dog)
  db_dog = {:id => db_dog[0],:name => db_dog[1],:breed => db_dog[2]}
  Dog.new(db_dog)

end

def self.find_by_id(id)
dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).flatten
dog = self.new_from_db(dog)
end

def self.find_or_create_by(dog_hash)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?;", dog_hash[:name],dog_hash[:breed]).flatten
  if dog.empty?
    self.create(dog_hash)
else
  self.new_from_db(dog)
  end
end

def self.find_by_name(dog)
dog_name = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", dog).flatten
self.new_from_db(dog_name)
end

def update
sql = "UPDATE dogs SET name = ? Where id = ?"
DB[:conn].execute(sql, self.name ,self.id)
end

end
