#####################################################################
# tc_getopt_long.rb
#
# Test suite for the getopt-long package. You should run this test
# via the 'rake test' rake task.
#####################################################################
require 'test-unit'
require 'getopt/long'
include Getopt

class TC_Getopt_Long < Test::Unit::TestCase
   def setup
      @opts = nil
   end

   def test_version
      assert_equal('1.4.2', Long::VERSION)
   end

   def test_constants
      assert_not_nil(BOOLEAN)
      assert_not_nil(OPTIONAL)
      assert_not_nil(REQUIRED)
      assert_not_nil(INCREMENT)
   end

   def test_getopts_basic
      assert_respond_to(Long, :getopts)
      assert_nothing_raised{
         Long.getopts(["--test"],["--help"],["--foo"])
      }
      assert_nothing_raised{
         Long.getopts(["--test", "-x"],["--help", "-y"],["--foo", "-z"])
      }
      assert_nothing_raised{
         Long.getopts(
            ["--test", "-x", BOOLEAN],
            ["--help", "-y", REQUIRED],
            ["--foo",  "-z", OPTIONAL],
            ["--more", "-m", INCREMENT]
         )
      }
      assert_kind_of(Hash, Long.getopts("--test"))
   end

   def test_getopts_using_equals
      ARGV.push("--foo=hello","-b","world")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--foo", "-f", REQUIRED],
            ["--bar", "-b", OPTIONAL]
         )
      }
      assert_equal("hello", @opts["foo"])
      assert_equal("hello", @opts["f"])
      assert_equal("world", @opts["bar"])
      assert_equal("world", @opts["b"])
   end

   def test_getopts_long_embedded_hyphens
      ARGV.push('--foo-bar', 'hello', '--test1-test2-test3', 'world')
      assert_nothing_raised{
         @opts = Long.getopts(
            ['--foo-bar', '-f', REQUIRED],
            ['--test1-test2-test3', '-t', REQUIRED]
         )
      }
      assert_equal('hello', @opts['foo-bar'])
      assert_equal('hello', @opts['f'])
      assert_equal('world', @opts['test1-test2-test3'])
      assert_equal('world', @opts['t'])
   end

   def test_getopts_long_embedded_hyphens_using_equals_sign
      ARGV.push('--foo-bar=hello', '--test1-test2-test3=world')
      assert_nothing_raised{
         @opts = Long.getopts(
            ['--foo-bar', '-f', REQUIRED],
            ['--test1-test2-test3', '-t', REQUIRED]
         )
      }
      assert_equal('hello', @opts['foo-bar'])
      assert_equal('hello', @opts['f'])
      assert_equal('world', @opts['test1-test2-test3'])
      assert_equal('world', @opts['t'])
   end

   def test_getopts_short_switch_squished
      ARGV.push("-f", "hello", "-bworld")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--foo", "-f", REQUIRED],
            ["--bar", "-b", OPTIONAL]
         )
      }
      assert_equal("hello", @opts["f"])
      assert_equal("world", @opts["b"])
   end

   def test_getopts_increment_type
      ARGV.push("-m","-m")
      assert_nothing_raised{
         @opts = Long.getopts(["--more", "-m", INCREMENT])
      }
      assert_equal(2, @opts["more"])
      assert_equal(2, @opts["m"])
   end

   def test_switches_exist
      ARGV.push("--verbose","--test","--foo")
      assert_nothing_raised{ @opts = Long.getopts("--verbose --test --foo") }
      assert_equal(true, @opts.has_key?("verbose"))
      assert_equal(true, @opts.has_key?("test"))
      assert_equal(true, @opts.has_key?("foo"))
   end

   def test_short_switch_synonyms
      ARGV.push("--verbose","--test","--foo")
      assert_nothing_raised{ @opts = Long.getopts("--verbose --test --foo") }
      assert_equal(true, @opts.has_key?("v"))
      assert_equal(true, @opts.has_key?("t"))
      assert_equal(true, @opts.has_key?("f"))
   end

   def test_short_switch_synonyms_with_explicit_types
      ARGV.push("--verbose", "--test", "hello", "--foo")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--verbose", BOOLEAN],
            ["--test", REQUIRED],
            ["--foo", BOOLEAN]
         )
      }
      assert(@opts.has_key?("v"))
      assert(@opts.has_key?("t"))
      assert(@opts.has_key?("f"))
   end

   def test_switches_with_required_arguments
      ARGV.push("--foo","1","--bar","hello")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--foo", "-f", REQUIRED],
            ["--bar", "-b", REQUIRED]
         )
      }
      assert_equal({"foo"=>"1", "bar"=>"hello", "f"=>"1", "b"=>"hello"}, @opts)
   end

   def test_compressed_switches
      ARGV.push("-fb")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--foo", "-f", BOOLEAN],
            ["--bar", "-b", BOOLEAN]
         )
      }
      assert_equal({"foo"=>true, "f"=>true, "b"=>true, "bar"=>true}, @opts)
   end

   def test_compress_switches_with_required_arg
      ARGV.push("-xf", "foo.txt")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--expand", "-x", BOOLEAN],
            ["--file", "-f", REQUIRED]
         )
      }
      assert_equal(
         {"x"=>true, "expand"=>true, "f"=>"foo.txt", "file"=>"foo.txt"}, @opts
      )
   end

   def test_compress_switches_with_compressed_required_arg
      ARGV.push("-xffoo.txt")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--expand", "-x", BOOLEAN],
            ["--file", "-f", REQUIRED]
         )
      }
      assert_equal(
         {"x"=>true, "expand"=>true, "f"=>"foo.txt", "file"=>"foo.txt"}, @opts
      )
   end

   def test_compress_switches_with_optional_arg_not_defined
      ARGV.push("-xf")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--expand", "-x", BOOLEAN],
            ["--file", "-f", OPTIONAL]
         )
      }
      assert_equal(
         {"x"=>true, "expand"=>true, "f"=>nil, "file"=>nil}, @opts
      )
   end

   def test_compress_switches_with_optional_arg
      ARGV.push("-xf", "boo.txt")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--expand", "-x", BOOLEAN],
            ["--file", "-f", OPTIONAL]
         )
      }
      assert_equal(
         {"x"=>true, "expand"=>true, "f"=>"boo.txt", "file"=>"boo.txt"}, @opts
      )
   end

   def test_compress_switches_with_compressed_optional_arg
      ARGV.push("-xfboo.txt")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--expand", "-x", BOOLEAN],
            ["--file", "-f", OPTIONAL]
         )
      }
      assert_equal(
         {"x"=>true, "expand"=>true, "f"=>"boo.txt", "file"=>"boo.txt"}, @opts
      )
   end

   def test_compressed_short_and_long_mixed
      ARGV.push("-xb", "--file", "boo.txt", "-v")
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--expand", "-x", BOOLEAN],
            ["--verbose", "-v", BOOLEAN],
            ["--file", "-f", REQUIRED],
            ["--bar", "-b", OPTIONAL]
         )
         assert_equal(
            { "x"=>true, "expand"=>true,
              "v"=>true, "verbose"=>true,
              "f"=>"boo.txt", "file"=>"boo.txt",
              "b"=>nil, "bar"=>nil
            },
            @opts
         )
      }
   end

   def test_multiple_similar_long_switches_with_no_short_switches
      ARGV.push('--to','1','--too','2','--tooo','3')
      assert_nothing_raised{
         @opts = Long.getopts(
            ["--to",  REQUIRED],
            ["--too", REQUIRED],
            ["--tooo", REQUIRED]
         )
      }
      assert_equal('1', @opts['to'])
      assert_equal('2', @opts['too'])
      assert_equal('3', @opts['tooo'])
   end

   def teardown
      @opts = nil
      ARGV.clear
   end
end
