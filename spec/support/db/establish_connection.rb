ENV['RACK_ENV'] = 'test'
db_yml = YAML.load_file(ERB.new(File.join('db', 'config.yml')).result)
ActiveRecord::Base.establish_connection db_yml["test"]
