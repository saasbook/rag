##########################################################################
# example_long.rb
#
# A series of examples to demonstrate the different ways that you can
# handle command line options.
##########################################################################
require "getopt/long"
include Getopt

# The truly lazy way.  This creates two valid command line switches,
# automatically creates single letter switches (-f, -b), and sets each
# switch type to BOOLEAN.
#opts = Getopt::Long.getopts("--foo --bar")

# Here's a comprehensive example that uses all types and options.
opts = Getopt::Long.getopts(
   ["--foo"],                    # --foo, -f, BOOLEAN
   ["--bar",  "-z"],             # --bar, -z, BOOLEAN
   ["--baz",  "-b", OPTIONAL],   # --baz, -b, OPTIONAL
   ["--name", "-n", REQUIRED],   # --name, -n, REQUIRED
   ["--more", "-m", INCREMENT],  # --more, -m, INCREMENT
   ["--verbose", "-v", BOOLEAN], # --verbose, -v, BOOLEAN
   ["--my-name", "-x", REQUIRED] # --my-name, -x, REQUIRED
)

p opts

# Using the above example:

# User passes "-f"
# opts -> { "f" => true, "foo" => true }

# User passes "-z"
# opts -> { "z" => true, "bar" => true }

# User passes "--verbose"
# opts -> { "v" => true, "verbose" => true }

# User passes "-m"
# opts -> { "m" => 1, "more" => 1 }

# User passes "-m -m"
# opts -> { "m" => 2, "more" => 2 }

# User passes "--name Dan" or "--name=Dan" or "-n Dan" or "-nDan"
# opts -> { "n" => "Dan", "name" => "Dan" }

# User passes "--my-name Dan" or "--my-name=Dan" or "-x Dan" or "-xDan"
# opts -> { "x" => "Dan", "my-name" => "Dan" }

# User passes "--name Dan --name Matz"
# opts -> { "n" => ["Dan","Matz"], "name" => ["Dan","Matz"] }

# User passes "--baz" with no argument
# opts -> { "b" => nil, "baz" => nil }

# User passes "--baz hello"
# opts =-> { "b" => "hello", "baz" => "hello" }

# User passes "-n" with no argument
# Getopt::LongError is raised, since an argument is REQUIRED.

# User passes "-f hello"
# Getopt::LongError is raised, since a BOOLEAN switch does not take an argument

# User passes "--warning"
# Getopt::LongError is raised, since "--warning" was not specified as a valid
# switch in the call to Getopt::Long.getopts
