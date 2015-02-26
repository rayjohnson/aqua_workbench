
config_dir = File.expand_path('~/.aqua_workbench')
unless Dir[config_dir].length > 0
  Dir::mkdir(config_dir)
end

DB = Sequel.sqlite("#{config_dir}/data.db")

unless DB.table_exists? :connections
  DB.create_table(:connections) do
  	primary_key :id
  	String :name
  	String :username
  	String :password
  	String :environment
  end
end

unless DB.table_exists? :jobs
  DB.create_table(:jobs) do
  	primary_key :id
  	String :name
  	String :format
  	String :version
  	String :encrypted
  	String :partner
  	String :project
  	# Queries - foreign key thing TODO
  end
end

unless DB.table_exists? :queries
  DB.create_table(:queries) do
  	primary_key :id
  	String :name
  	String :type
  	String :query_text
  	# deleted field - TODO
  end
end


class Connection < Sequel::Model
end

class Job < Sequel::Model
end

class Query < Sequel::Model(:queries)
end