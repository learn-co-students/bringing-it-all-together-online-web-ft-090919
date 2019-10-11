class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, breed:, name:)
        @id = id
        @breed = breed
        @name = name
    end

    def self.create_table
        DB[:conn].execute('CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)')
    end

    def save
            sql = <<-SQL
                    INSERT INTO dogs (name, breed)
                    VALUES (?,?)
                SQL
            dog = DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
            self
    end 

    def self.drop_table
        DB[:conn].execute('DROP TABLE dogs')
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
                SELECT *
                FROM dogs
                WHERE name = ?
              SQL
        
        DB[:conn].execute(sql, name).collect do |row|
            self.new_from_db(row)
        end.first
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
                SELECT *
                FROM dogs
                WHERE id = ?
              SQL

        DB[:conn].execute(sql, id).collect do |row|
            self.new_from_db(row)
        end.first
    end
    
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
                SELECT *
                FROM dogs
                WHERE name = ?
                AND breed = ?
            SQL
            
        data = DB[:conn].execute(sql, name, breed)
        if !data.empty?
            dog_data = data[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
           dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end