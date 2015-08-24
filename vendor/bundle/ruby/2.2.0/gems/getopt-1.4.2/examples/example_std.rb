####################################################
# example_std.rb
#
# Some samples of how to use the Getopt::Std class.
#####################################################
require "getopt/std"
include Getopt

# Try passing different switches to this script to see what happens
opts = Std.getopts("o:ID")
p opts

# User passes "-o hello -I"
# Result: {"o" => "hello", "I" => true}

# User passes "-I -D"
# Result: {"I" => true, "D" => true}

# User passes nothing
# Result: {}

# User passes "-o hello -o world -I"
# Result: {"I" => true, "o" => ["hello", "world"]}

# User passes "-o -I"
# Result: Getopt::StdError, because -o requires an argument (and does not
#    accept -I as an argument, since it is a valid switch)

# User passes "-I -X"
# Result: Getopt::StdError, because -X was not listed as a valid switch.
