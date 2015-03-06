
require 'json'

# monkey patch stolen from rails
class String
  def truncate(truncate_at, options = {})
    return dup unless length > truncate_at

    options[:omission] ||= '...'
    length_with_room_for_omission = truncate_at - options[:omission].length
    stop = \
      if options[:separator]
        rindex(options[:separator], length_with_room_for_omission) ||      length_with_room_for_omission
      else
        length_with_room_for_omission
      end

     "#{self[0...stop]}#{options[:omission]}"
  end
end

def show_bad_request_message(code)
  if code == 401
    # TODO: is there more control we can have on UI on Mac (not show feather?)
    msgBox = Tk.messageBox(
      'type'    => "ok",  
      'icon'    => "info", 
      'title'   => "Invalid credentials",
      'message' => "You were not able to authenticate to Zuora with provided credentials.  Http code: #{code}"
    )
  else
    msgBox = Tk.messageBox(
      'type'    => "ok",  
      'icon'    => "info", 
      'title'   => "Communication error",
      'message' => "Could not communicate with Zuora.  Http code: #{code}"
    )
  end
end

def show_zuora_error_message(result_hash)
    message = ""
    result_hash.each do |key, value|
      puts "#{key}: #{value}"
      message << "#{key}: #{value.to_s.truncate(600, separator: /\s/)}\r\n"
    end
    puts message
    # TODO: Zuora puts entire stack dumps in errors making it rather nasty to show user
    # should perhaps truncate or something...
    # TODO: the newline does not help either.  Maybe need custom dialog for this...
    msgBox = Tk.messageBox(
      'type'    => "ok",  
      'icon'    => "error", 
      'title'   => "Zuora Error",
      'detail' => message
    )
end

def run_query(connection, job)
  puts "Job: job.name"
  request = job.to_json(:except=>[:id, :name], :include=>{:queries=>{:except=>[:id, :job_id]}})
  puts "Body: #{request}"

  # TODO: need way to get credentials
  #username = "rjohnson@yp.com.zdev"
  #password = "1BigFatCat"
  aqua = AQuA.new(connection)

  response = aqua.batch_query(request)
  puts "Response: #{response}"
  puts "Code: #{response.code}"
  if response.code != 200
    show_bad_request_message(response.code)
    return
  end
  job_id = response.parsed_response["id"]
  if job_id.nil?
    show_zuora_error_message(response.parsed_response)
    return
  end

  # Save the ID so it can show up in result screen
  result = Result.new
  result.result_id = job_id
  result.name = job.name
  result.save_path = job.save_path
  connection.add_result(result)
  result.save

  # Now go check results
  check_results
end

def check_results
  results = Result.all
  results.each do |r|
    if r.status == "completed" || r.result_id.nil?
      next
    end

    connection = Connection.where(:id=>r.connection_id).first
    puts "USER: #{connection.username}"

    aqua = AQuA.new(connection)

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
     
    if r.batches.length > 0
      # Just update batch results
      response["batches"].each do |batch_hash|
        batch = Batch.where(:batchId=>batch_hash["batchId"]).first
        batch.update(batch_hash)
        batch.save
      end
    else
      # Must be new
      response["batches"].each do |batch_hash|
        batch = Batch.new(batch_hash)
        r.add_batch(batch)
        batch.save
      end
    end

    # If job just became done - got download all the files
    if r.status == "completed"
      # TODO: would be better to do this as each batch completed
      # TODO: would also be nice to show completion percent of each file on job_ui for the batch
      Batch.where(:result_id=>r.id).all do |batch|
        download_query_results(batch, r.save_path)
      end

    end

    jobs_still_running = false
    if response["status"] == "executing" || response["status"] == "pending"
      jobs_still_running = true
    end

    # Now go update UI
    update_results_table
    result_ui_update_windows
    
    puts "Schedule to run in 5 seconds"
    if jobs_still_running
      Tk.after(5000) {
        check_results
      }
    end
  end
end

def download_query_results(batch, save_dir)
  result = Result.where(:id=>batch.result_id).first
  connection = Connection.where(:id=>result.connection_id).first

  if connection.environment == "prod"
    url = "https://www.zuora.com/apps/api/file/#{batch.fileId}"
  else
    url = "https://apisandbox.zuora.com/apps/api/file/#{batch.fileId}"
  end
  puts "URL: #{url}"
  uri = URI(url)

  # TODO: options for naming file (date stamp, etc)
  save_path = "#{save_dir}/#{batch.name}.#{result.format}"

  # TODO: Content type in header? - when doing zip and gzip
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #http.set_debug_output($stdout)

  request = Net::HTTP::Get.new uri.request_uri
  request.basic_auth(connection.username, connection.password)
  request["User-Agent"] = "AQuA Workbench"
  request["Accept"] = "application/csv"

  http.request request do |response|
    #puts "Got here"
    open save_path, 'w' do |io|
      response.read_body do |chunk|
        io.write chunk
      end
    end
  end
end



