class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(info_hash)
    @name = info_hash[:name]
    @breed = info_hash[:breed]
    @id = info_hash[:id]
    # @name = name
    # @breed = breed
    # @id = id
  end
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def self.create(info_hash)
    dog = self.new(info_hash)
    dog.save
    dog
  end
  
  def self.new_from_db(info)
    info_hash = {:name => info[1], :breed => info[2], :id => info[0]}
    new_dog = self.new(info_hash)

    new_dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    info = DB[:conn].execute(sql, name).flatten
    self.new_from_db(info)
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    info = DB[:conn].execute(sql, id).flatten
    self.new_from_db(info)
  end
  
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1").flatten
      self
    end
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @breed, @id)
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      info = dog[0]
      info_hash = {:name => info[1], :breed => info[2], :id => info[0]} 
      dog = Dog.new(info_hash)
    else
      info_hash2 = {:name => name, :breed => breed, :id => nil}
      dog = self.create(info_hash2)
    end
    dog
  end
  
  
end





