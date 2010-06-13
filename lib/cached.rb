load "db.rb"
Db.database ||= "#{ENV["HOME"]}/.cached.sql"

require 'digest/sha1'

class Entry
  extend Db
  
  def self.init
    unless ask "SELECT name FROM sqlite_master WHERE type='table' AND name='cached'"
      ask "CREATE TABLE cached(key, value, valid_until)"
    end

    ask "CREATE UNIQUE INDEX IF NOT EXISTS cached_key ON cached(key)"
    ask "CREATE INDEX IF NOT EXISTS cached_valid_until ON cached(valid_until)"
  end

  init

  def self.cleanup
    ask "DELETE FROM cached WHERE valid_until < ?", now
  end

  def self.now
    Time.now.to_i
  end

  def self.get(key)
    value, valid_until = *row("SELECT value, valid_until FROM cached WHERE key=?", key)
    return value if value && valid_until.to_i >= now
  end

  def self.set(key, value, options)
    ask "INSERT OR REPLACE INTO cached (key, value, valid_until) VALUES(?, ?, ?)", key, value, now + options[:ttl]
  end
end

module Cached
  def self.exec(*args)
    ttl = 3600
    
    case args.first
    when /^--ttl=([0-9]+)$/
      args.shift
      ttl = $1.to_i
    end
    
    key = Digest::SHA1.hexdigest(Dir.getwd + ":" + args.inspect)
    Entry.get(key) || begin
      value = run(*args)
      Entry.set(key, value, :ttl => ttl)
      value
    end
  end

  def self.shell_escape(*args)
    args.map do |str|
      if str.empty?
        "''"
      elsif %r{\A[0-9A-Za-z+,./:=@_-]+\z} =~ str
        str
      else
        result = ''
        str.scan(/('+)|[^']+/) {
          if $1
            result << %q{\'} * $1.length
          else
            result << "'#{$&}'"
          end
        }
        result
      end
    end.join(" ")
  end

  def self.run(*args)
    command = args.join(" ")
    # command = shell_escape args
    `#{command}`
  end
end

#
# TODO: start cleanup in background... Entry.cleanup
