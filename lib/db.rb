
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
  	String :query
    String :apiVersion
  	# deleted field - TODO
    foreign_key :job_id, :jobs
  end
end

unless DB.table_exists? :results
  DB.create_table(:results) do
  	primary_key :id
  	String :name
  	String :result_id
  	String :partner
    String :project
    String :version
    String :format
    String :startTime   # TODO make DateTime
    String :status
    String :encrypted

    foreign_key :connection_id, :connections
  end
end

unless DB.table_exists? :batches
  DB.create_table(:batches) do
  	primary_key :id
  	String :name
  	String :full
  	String :message
    String :query
    String :status
    String :recordCount
    String :apiVersion
    String :fileId
    String :batchType
    String :batchId

    foreign_key :result_id, :results
  end
end

Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :instance_hooks

class Connection < Sequel::Model
  one_to_many :results
end

class Job < Sequel::Model
  one_to_many :queries
end

class Query < Sequel::Model(:queries)
  many_to_one :jobs  
end

class Result < Sequel::Model
  one_to_many :batches
  many_to_one :connections
end

class Batch < Sequel::Model(:batches)
  many_to_one :results  
end
