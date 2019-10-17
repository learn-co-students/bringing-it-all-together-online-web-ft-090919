class Dog 
  
  attr_accessor :name, :breed, :id
  
  
  def initialize (id: nil, name:, breed:)
    @name = name 
    @breed = breed 
    @id = id 
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    row = DB[:conn].execute(sql, id).first
    
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
    
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    # dogs = DB[:conn].execute(sql, name).map { |row|
    #   Dog.new(id: row[0], name: row[1], breed: row[2])
    # }
    # dogs.first
    
    row = DB[:conn].execute(sql, name).first
    Dog.new(id: row[0], name: row[1], breed: row[2]) if row
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL
    row = DB[:conn].execute(sql, [name, breed]).first
    
    if row
      # if there is a dog in the database return a new
      # dog object with info from row
      Dog.new(id: row[0], name: row[1], breed: row[2]) 
    else
      # if there is NOT a dog in the database CREATE and return a new
      # dog object with info from row
      Dog.create(name: name, breed: breed)
    end
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end 

end