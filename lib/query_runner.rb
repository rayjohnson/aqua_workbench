
require 'json'


def run_query(job)
  puts "hello"
  puts "Job: job.name"
  request = job.to_json(:except=>[:id], :include=>{:queries=>{:except=>[:id, :job_id]}})
  puts "Body: #{request}"

  # TODO trim newlines off of query text
  # TODO: need way to get credentials
  return
  aqua = AQuA.new(ENV["ZUORA_USER"], ENV["ZUORA_PW"])

  result = aqua.batch_query(request)
  puts result
  job_id = result.parsed_response["id"]
  puts job_id
end



  report_request = {
     'format' => "csv",
     'version' => "1.1",
     'encrypted' => "none",
     'partner' => nil,
     'project' => nil,
     'queries' => [
        {
          'name' => "RatePlanCharge",
          'query' => "",
          'type' => "zoqlexport",
          'apiVersion' => "64.0"
        }
     ]
  }