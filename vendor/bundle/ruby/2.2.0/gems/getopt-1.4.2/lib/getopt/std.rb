# The Getopt module serves as a namespace only
module Getopt

   # The Getopt::Std class serves as a base class for the getopts method.
   class Std

      # The Getopt::Std::Error class is raised if there are any illegal
      # command line arguments.
      #
      class Error < StandardError; end

      # The version of the getopt library
      VERSION = '1.4.2'

      # Processes single character command line options with option
      # clustering.  This information is parsed from ARGV and returned
      # as a hash, with the switch (minus the "-") as the key.  The value
      # for that key is either true/false (boolean switches) or the argument
      # that was passed to the switch.
      #
      # Characters followed by a ":" require an argument.  The rest are
      # considered boolean switches.  If a switch that accepts an argument
      # appears more than once, the value for that key becomes an array
      # of values.
      #
      # Example:
      #
      #  # Look for -o with argument, and -I and -D boolean arguments
      #  opt = Getopt::Std.getopts("o:ID")
      #
      #  if opt["I"]
      #    # Do something if -I passed
      #  end
      #
      #  if opt["D"]
      #     # Do something if -D passed
      #  end
      #
      #  if opt["o"]
      #     case opt["o"]
      #        # Do something
      #     end
      #  end
      #
      def self.getopts(switches)
         args = switches.split(/ */)
         hash = {}

         while !ARGV.empty? && ARGV.first =~ /^-(.)(.*)/s
            first, rest = $1, $2
            pos = switches.index(first)

            # Switches on the command line must appear among the characters
            # declared in +switches+.
            raise Error, "invalid option '#{first}'" unless pos

            if args[pos+1] == ":"
               ARGV.shift
               if rest.empty?
                  rest = ARGV.shift

                  # Ensure that switches requiring arguments actually
                  # receive a (non-switch) argument.
                  if rest.nil? || rest.empty?
                     raise Error, "missing argument for '-#{args[pos]}'"
                  end

                  # Do not permit switches that require arguments to be
                  # followed immediately by another switch.
                  temp_args = args.map{ |e| "-#{e}" }

                  if temp_args.include?(rest) || temp_args.include?(rest[1..-1])
                     err = "cannot use switch '#{rest}' as argument "
                     err << "to another switch"
                     raise Error, err
                  end

                  # For non boolean switches, arguments that appear multiple
                  # times are converted to an array (or pushed onto an already
                  # existant array).
                  if hash.has_key?(first)
                     hash[first] = [hash[first], rest].flatten
                  else
                     hash[first] = rest
                  end
               else
                  # Do not permit switches that require arguments to be
                  # followed immediately by another switch.
                  if args.include?(rest) || args.include?(rest[1..-1])
                     err = "cannot use switch '#{rest}' as argument "
                     err += "to another switch"
                     raise Error, err
                  end
               end
            else
               hash[first] = true # Boolean switch
               if rest.empty?
                  ARGV.shift
               else
                  ARGV[0] = "-#{rest}"
               end
            end
         end

         hash
      end
   end
end
