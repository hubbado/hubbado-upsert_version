ENV['RACK_ENV'] = 'test'
db_yml = YAML.load(ERB.new(File.read('db/config.yml')).result)
ActiveRecord::Base.establish_connection db_yml["test"]
