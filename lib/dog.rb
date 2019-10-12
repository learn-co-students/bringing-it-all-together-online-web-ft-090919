class Dog

  attr_accessor :name, :breed, :id


    def initialize(name:, breed:, id: nil)
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
      sql = <<-SQL
        DROP TABLE dogs
      SQL

      DB[:conn].execute(sql)
    end

    def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed) VALUES (?,?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        @id = DB[:conn].execute("SELECT last_insert_rowid()").flatten.first
        self
      end
    end

    def self.create(name:, breed:)

      self.new(name: name, breed: breed).tap {|o| o.save}

    end

    def self.new_from_db(row)
      self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL

      dog = DB[:conn].execute(sql, id).flatten
      self.new_from_db(dog)
    end

    def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL

      dog = DB[:conn].execute(sql, name, breed).flatten

      if !dog.empty?
        self.new_from_db(dog)
      else
        self.create(name: name, breed: breed)
      end
    end

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
      SQL

      dog = DB[:conn].execute(sql, name).flatten
      self.new_from_db(dog)
    end

    def update
      sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



end
