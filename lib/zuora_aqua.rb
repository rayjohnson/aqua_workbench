
# Wrap up Aqua interfaces into a class
require 'httparty'

class AQuA
  include HTTParty
  # TODO: apisandbox or www need to be set from ENV
  #base_uri 'www.zuora.com'
  base_uri 'https://apisandbox.zuora.com'
  #format :json

  def initialize(user, pass)
    self.class.basic_auth user, pass
  end

  def batch_query(payload)
    options = { :body => payload.to_json, :headers => { 'Content-Type' => 'application/json',  'Accept' => 'application/json'} }
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
