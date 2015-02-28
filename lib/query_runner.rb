
require 'json'


def run_query(connection, job)
  puts "hello"
  puts "Job: job.name"
  request = job.to_json(:except=>[:id, :name], :include=>{:queries=>{:except=>[:id, :job_id]}})
  puts "Body: #{request}"

  # TODO: need way to get credentials
  #username = "rjohnson@yp.com.zdev"
  #password = "1BigFatCat"
  aqua = AQuA.new(connection.username, connection.password)
  puts "about to do it"

  result = aqua.batch_query(request)
  # TODO: look for errors
  puts result
  job_id = result.parsed_response["id"]
  puts job_id

  # Save the ID so it can show up in result screen
  result = Result.new
  result.result_id = job_id
  connection.add_result(result)
  result.save
end

def check_results
  results = Result.all
  results.each do |r|
    if r.status == "completed"
      next
    end

    connection = Connection.where(:id=>r.connection_id).first
    puts "USER: #{connection.username}"

    aqua = AQuA.new(connection.username, connection.password)
    job_status = aqua.query_job_result(r.result_id)

    puts "Result #{job_status}"
    puts job_status.parsed_response["status"]
    puts "Parsed: #{job_status.parsed_response}"

    response = job_status.parsed_response

    r.version = response["version"]
    r.startTime = response["startTime"]
    r.format = response["format"]
    r.status = response["status"]
    r.save

    response["batches"].each do |batch_hash|
      batch = Batch.new(batch_hash)
      r.add_batch(batch)
      batch.save
    end
  end
end