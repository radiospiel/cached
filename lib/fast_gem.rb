module Gem
  require 'rbconfig'

  if !defined?(ConfigMap)

    ConfigMap = {
      :EXEEXT            => RbConfig::CONFIG["EXEEXT"],
      :RUBY_SO_NAME      => RbConfig::CONFIG["RUBY_SO_NAME"],
      :arch              => RbConfig::CONFIG["arch"],
      :bindir            => RbConfig::CONFIG["bindir"],
      :datadir           => RbConfig::CONFIG["datadir"],
      :libdir            => RbConfig::CONFIG["libdir"],
      :ruby_install_name => RbConfig::CONFIG["ruby_install_name"],
      :ruby_version      => RbConfig::CONFIG["ruby_version"],
      :rubylibprefix     => RbConfig::CONFIG["rubylibprefix"],
      :sitedir           => RbConfig::CONFIG["sitedir"],
      :sitelibdir        => RbConfig::CONFIG["sitelibdir"],
      :vendordir         => RbConfig::CONFIG["vendordir"] ,
      :vendorlibdir      => RbConfig::CONFIG["vendorlibdir"]
    }

  end

  def self.user_home
    ENV["HOME"]
  end
end

require 'rubygems/defaults'

module FastGem
  extend self

  def gem_paths
    [ Gem.default_dir, Gem.user_dir ]
  end

  #
  # Try ro find the file "name" in any of the available paths, and return the path
  def find(name)
    # look into each gempath for a matching file, sort by version (roughly), 
    # and return the last hit
    gem_paths.
      map { |gem_path| Dir.glob("#{gem_path}/gems/#{name}-[0-9]*") }.
      flatten.
      sort_by { |gem_path| gem_path.gsub(/.*\/gems\/[^-]+-/, "") }.
      last
  end
  
  def load(name)
    path = find(name)
    # STDERR.puts "Load #{name} from #{path}"
    $: << "#{path}/lib"
    require name
  end
end
