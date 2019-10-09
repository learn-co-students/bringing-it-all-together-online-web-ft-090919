class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
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
    INSERT INTO dogs (name, breed) VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
  end

  def self.create (name:, breed:)
  var = self.new(name:name, breed:breed)
  var.save
  var
  end

  def self.new_from_db(row)
    var = self.new(id:row[0],name:row[1], breed:row[2])
    var
  end

  def self.find_by_id(id)
  sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
  SQL
  var = DB[:conn].execute(sql, id).first
  self.new(id:var[0], name:var[1], breed:var[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first

    if dog
      self.new_from_db(dog)
    else
      self.create(name:name, breed:breed)
    end
  end

  def self.find_by_name(name)
  sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
  SQL
  array = DB[:conn].execute(sql, name).first
  self.new(id:array[0], name:array[1], breed:[2])
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id).first
  end

end