load "fast_gem.rb"

FastGem.load "sqlite3"

module Db
  def database=(database)
    @database = database
  end
  
  def database
    @database || "test.db"
  end
  
  def db
    @db ||= SQLite3::Database.new("test.db") 
  end

  def log(query, *args)
    # STDERR.puts "[sqlite] #{query}"
  end
  
  def sql(query, *args)
    log query, *args
    r = db.execute query, *args
    return r if r
    return [ db.changes ] if query =~ /^\s*(DELETE|INSERT)\b/i
  end

  def ask(query, *args)
    log query, *args
    r = db.get_first_value(query, *args)
    return r if r
    return db.changes if query =~ /^\s*(DELETE|INSERT)\b/i
  end
  
  def row(query, *args)
    log query, *args
    db.get_first_row(query, *args)
  end
end
