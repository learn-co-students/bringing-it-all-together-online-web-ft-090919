class Dog
    attr_accessor :name, :breed
    attr_reader :id

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
            );
        SQL
        DB[:conn].execute(sql) 
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"
        DB[:conn].execute(sql) 
    end

    def find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE name = ?
        SQL
        dog = DB[:conn].execute(sql, name).first
        Dog.new(dog[0], dog[1], dog[2])
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(props={})
        dog = Dog.new(props)
        dog.save
    end

    def update
        sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id=?", id).first 
        self.new_from_db(row)
    end

    def self.find_or_create_by(props={})
        sql = <<-SQL
        SELECT * FROM dogs WHERE name=? AND breed=?
        SQL
        dog = DB[:conn].execute(sql, props[:name], props[:breed])

        if !dog.empty?
            dog_props = dog[0]
            dog = Dog.new_from_db(dog_props)
        else
            dog = Dog.create(props)
        end
        dog
    end

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name=?", name).first 
        self.new_from_db(row)
    end
end