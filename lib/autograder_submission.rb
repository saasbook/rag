class AutograderSubmission
  def initialize conf_file_name, submission_name, student_info
  end

  def load_spec(conf_file_name, part_id)
    if not @autograders.include? assignment_part_sid
      logger.fatal "Assignment part #{assignment_part_sid} not found!"
      raise "Assignment part #{assignment_part_sid} not found!"
    end
    if not @autograders[assignment_part_sid][:parts].include? part_id
      logger.fatal "Assignment part #{part_id} not found!"
      raise "Assignment part #{part_id} not found!"
    end
  
    autograder = @autograders[assignment_part_sid][:parts][part_id]#prettify later
    
    return [autograder["uri"],autograder["type"]] if autograder["uri"] !~ /^http/ # Assume that if uri doesn't start with http, then it is a local file path

    # If not in cache, download and add to cache
    if autograder[:cache].nil?
      spec_file = Tempfile.new('spec')
      response = Net::HTTP.get_response(URI(autograder[:uri]))
      if response.code !~ /2\d\d/
        logger.fatal "Could not load the spec at #{autograder[:uri]}"
        raise EdXClient::SpecNotFound, "Could not load the spec at #{autograder[:uri]}"
      end
      spec_file.write(response.body)
      spec_file.close
      autograder[:cache] = spec_file
    end
    autograder[:cache].path
  end
end