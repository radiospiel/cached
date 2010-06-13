load "fast_gem.rb"

FastGem.load "sqlite3"

class Db
  (class << self; self; end).class_eval do
    attr_writer :database
    
    def database
      @database || "test.db"
    end
    
    def db
      @db ||= SQLite3::Database.new("test.db") 
    end

    def log(query, *args)
      STDERR.puts "[sqlite] #{query}"
    end
    
    def sql!(query, *args)
      log query, *args
      db.execute query, *args
    end

    def sql(query, *args)
      sql! query, *args
    end
    
    def ask(query, *args)
      log query, *args
      db.get_first_value(query, *args)
    end
    
    def row(query, *args)
      log query, *args
      db.get_first_row(query, *args)
    end
  end
end
