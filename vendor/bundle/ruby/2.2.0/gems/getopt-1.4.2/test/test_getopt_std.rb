###################################################################
# test_getopt_std.rb
#
# Test suite for the Getopt::Std class. You should run this test
# via the 'rake test' task.
###################################################################
require 'test-unit'
require 'getopt/std'
include Getopt

class TC_Getopt_Std < Test::Unit::TestCase

   def test_version
      assert_equal('1.4.2', Std::VERSION)
   end

   def test_getopts_basic
      assert_respond_to(Std, :getopts)
      assert_nothing_raised{ Std.getopts("ID") }
      assert_kind_of(Hash, Std.getopts("ID"))
   end

   def test_getopts_separated_switches
      ARGV.push("-I", "-D")
      assert_equal({"I"=>true, "D"=>true}, Std.getopts("ID"))
   end

   # Inspired by RF bug #23477
   def test_getopts_arguments_that_match_switch_are_ok
      ARGV.push("-d", "d")
      assert_equal({"d" => "d"}, Std.getopts("d:"))

      ARGV.push("-d", "ad")
      assert_equal({"d" => "ad"}, Std.getopts("d:"))

      ARGV.push("-a", "ad")
      assert_equal({"a" => "ad"}, Std.getopts("d:a:"))

      ARGV.push("-a", "da")
      assert_equal({"a" => "da"}, Std.getopts("d:a:"))

      ARGV.push("-a", "d")
      assert_equal({"a" => "d"}, Std.getopts("d:a:"))

      ARGV.push("-a", "dad")
      assert_equal({"a" => "dad"}, Std.getopts("d:a:"))

      ARGV.push("-d", "d", "-a", "a")
      assert_equal({"d" => "d", "a" => "a"}, Std.getopts("d:a:"))
   end

   def test_getopts_joined_switches
      ARGV.push("-ID")
      assert_equal({"I"=>true, "D"=>true}, Std.getopts("ID"))
   end

   def test_getopts_separated_switches_with_mandatory_arg
      ARGV.push("-o", "hello", "-I", "-D")
      assert_equal({"o"=>"hello", "I"=>true, "D"=>true}, Std.getopts("o:ID"))
   end

   def test_getopts_joined_switches_with_mandatory_arg
      ARGV.push("-IDo", "hello")
      assert_equal({"o"=>"hello", "I"=>true, "D"=>true}, Std.getopts("o:ID"))
   end

   def test_getopts_no_args
      assert_nothing_raised{ Std.getopts("ID") }
      assert_equal({}, Std.getopts("ID"))
      assert_nil(Std.getopts("ID")["I"])
      assert_nil(Std.getopts("ID")["D"])
   end

   # If a switch that accepts an argument appears more than once, the values
   # are rolled into an array.
   def test_getopts_switch_repeated
      ARGV.push("-I", "-I", "-o", "hello", "-o", "world")
      assert_equal({"o" => ["hello","world"], "I"=>true}, Std.getopts("o:ID"))
   end

   # EXPECTED ERRORS

   def test_getopts_expected_errors_passing_switch_to_another_switch
      ARGV.push("-d", "-d")
      assert_raise(Getopt::Std::Error){ Std.getopts("d:a:") }

      ARGV.push("-d", "-a")
      assert_raise(Getopt::Std::Error){ Std.getopts("d:a:") }

      ARGV.push("-a", "-d")
      assert_raise(Getopt::Std::Error){ Std.getopts("d:a:") }

      ARGV.push("-d", "-d")
      assert_raise_message("cannot use switch '-d' as argument to another switch"){ Std.getopts("d:a:") }
   end

   def test_getopts_expected_errors_missing_arg
      ARGV.push("-ID")
      assert_raises(Std::Error){ Std.getopts("I:D") }

      ARGV.push("-ID")
      assert_raises(Std::Error){ Std.getopts("ID:") }
   end

   def test_getopts_expected_errors_extra_arg
      ARGV.push("-I", "-D", "-X")
      assert_raises(Std::Error){ Std.getopts("ID") }

      ARGV.push("-IDX")
      assert_raises(Std::Error){ Std.getopts("ID") }

      ARGV.push("-IDX")
      assert_raise_message("invalid option 'X'"){ Std.getopts("ID") }
   end

   def test_getopts_expected_errors_basic
      assert_raises(ArgumentError){ Std.getopts }
      assert_raises(NoMethodError){ Std.getopts(0) }
      assert_raises(NoMethodError){ Std.getopts(nil) }
   end

   def teardown
      ARGV.clear
   end
end
