
# Wrap up Aqua interfaces into a class
require 'httparty'

class AQuA
  include HTTParty
  # TODO: apisandbox or www need to be set from ENV
  #base_uri 'www.zuora.com'
  base_uri 'https://apisandbox.zuora.com'
  #format :json

  def initialize(connection)
    self.class.basic_auth connection.username, connection.password
    if connection.environment == "prod"
      self.class.base_uri "https://api.zuora.com"
    else
      self.class.base_uri "https://apisandbox.zuora.com"
    end
  end

  def batch_query(json_payload)
    options = { :body => json_payload, :headers => { 'Content-Type' => 'application/json',  'Accept' => 'application/json'} }
    self.class.post('/apps/api/batch-query/', options)
  end

  def query_job_result(job_id)
    options = { :headers => { 'Accept' => 'application/json'} }
    self.class.get('/apps/api/batch-query/jobs/' + job_id, options)
  end

  def get_csv_file(file_id)
    options = { :headers => { 'Accept' => 'application/csv'} }
    self.class.get('/apps/api/file/' + file_id, options)
  end

end
