
require 'json'


def run_query(connection, job)
  puts "hello"
  puts "Job: job.name"
  request = job.to_json(:except=>[:id, :name], :include=>{:queries=>{:except=>[:id, :job_id]}})
  puts "Body: #{request}"

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

  puts "Compare: #{report_request.to_json}"
  # TODO trim newlines off of query text
  # TODO: need way to get credentials
  username = "rjohnson@yp.com.zdev"
  password = "1BigFatCat"
  aqua = AQuA.new(username, password)
  puts "about to do it"

  result = aqua.batch_query(request)
  # TODO: look for errors
  puts result
  job_id = result.parsed_response["id"]
  puts job_id

  # Save the ID so it can show up in result screen
  result = Result.new
  result.result_id = job_id
  result.save
end