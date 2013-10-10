# Courtesy of https://gist.github.com/1032297
require 'open3'
require 'timeout'
require 'ruby-debug'

# Runs a specified shell command in a separate thread.
# If it exceeds the given timeout in seconds, kills it.
# Returns any output produced by the command (stdout or stderr) as a String.
# Uses Kernel.select to wait up to the tick length (in seconds) between 
# checks on the command's status
#
# If you've got a cleaner way of doing this, I'd be interested to see it.
# If you think you can do it with Ruby's Timeout module, think again.

def run_with_timeout(command, timeout, tick=1, buffer_size=1024)
  # I wonder if 'tick' this is the problem - that we don't wait long enough to get output/error data, but we loop
  # is it possible that we accidentally overwrite the output somehow ... however we are just appending to output ...
  output = ''
  erroutput = ''
  begin
    # Start task in another thread, which spawns a process
    stdin, stdout, stderrout, thread = Open3.popen3(command)
    # Get the pid of the spawned process
    pid = thread[:pid]
    start = Time.now
    stderr_empty = false

    while (Time.now - start) < timeout #and thread.alive?
      # Wait up to `tick` seconds for output/error data
      Kernel.select([stdout, stderrout], nil, nil, tick)
      # Try to read the data
      begin
        output << stdout.read_nonblock(buffer_size)
      rescue IO::WaitReadable => e
        # A read would block, so loop around for another select
        # TODO lets have some logging in here ...
        #RagLogger.logger.info "waiting for IO: #{e.to_s}; #{command}"
      rescue EOFError => e
        # Command has completed, not really an error...
        #RagLogger.logger.info "command completed: #{e.to_s}; #{command}"
        break
      end
      begin
        erroutput << stderrout.read_nonblock(buffer_size) unless stderr_empty
      rescue IO::WaitReadable => e
        # A read would block, so loop around for another select
        # TODO lets have some logging in here ...
        #RagLogger.logger.info "waiting for IO: #{e.to_s}; #{command}"
      rescue EOFError => e
        stderr_emtpy = true
        # Command has completed, not really an error...
        #RagLogger.logger.info "command completed: #{e.to_s}; #{command}"
      end
    end
    # Give Ruby time to clean up the other thread
    sleep 1

    if thread.alive?
      # We need to kill the process, because killing the thread leaves
      # the process alive but detached, annoyingly enough.
      Process.kill('KILL', pid)
      raise Timeout::Error.new
    end
  ensure
    stdin.close if stdin
    stdout.close if stderrout
  end
  #debugger
  return [output, erroutput, thread.value.exitstatus]
end

