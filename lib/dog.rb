
class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = <<~SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql ="DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<~SQL
      INSERT INTO dogs(name, breed)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    self.new(id: row[0],name: row[1],breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<~SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<~SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    AND
    breed = ?
    SQL

    if DB[:conn].execute(sql, name, breed).empty?
      new_dog = self.new(name: name, breed: breed)
      new_dog.save
    else
      DB[:conn].execute(sql, name, breed).map do |row|
        self.new_from_db(row)
      end.first
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<~SQL
    UPDATE dogs
    SET name = ?,
    breed = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

  end

end
