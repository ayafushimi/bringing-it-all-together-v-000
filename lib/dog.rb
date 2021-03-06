class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize(id:nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES(?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1;
    SQL

    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1;
    SQL

    row = DB[:conn].execute(sql, name, breed)

    if row.empty?
      self.create(name:name, breed:breed)
    else
      self.new_from_db(row[0])
    end

  end

  def self.new_from_db(row)
    self.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1;
    SQL

    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
