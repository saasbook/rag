#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'Base64'
require 'tempfile'

require './lib/auto_grader.rb'

def parse_grade(str)
  # Used for parsing the stdout output from running grade as a shell command
  # FIXME: This feels insecure and fragile
  score_regex = /Score out of 100:\s*(\d+(?:\.\d+)?)$/
  score = str.match(score_regex, str.rindex(score_regex))[1].to_f
  comments = str.match(/^---BEGIN rspec comments---\n#{'-'*80}\n(.*)#{'-'*80}\n---END rspec comments---$/m)[1]
  comments = comments.split("\n").map do |line|
    line.gsub(/\(FAILED - \d+\)/, "(FAILED)")
  end.join("\n")
  [score, comments]
rescue
  raise "Failed to parse autograder output", str
end

ags = YAML::load(File.open('local_autograders.yml', 'r'){|f|f.read})
#p ags
subs = eval File.open('submissions_assign1.txt', 'r'){|f|f.read}

subs.each_key do |assign_part|
  subs[assign_part].each do |sub|
    spec = ags[assign_part]
    submission = Base64.strict_decode64(sub['submission'])
    Tempfile.open(['test', '.rb']) do |file|
      file.write(submission)
      file.flush
      output = `./grade #{file.path} #{spec}`
      score, comments = parse_grade(output)
      comments.gsub!(spec, 'spec.rb')
      puts "#{subs[assign_part].index sub}: #{score}"
      puts comments if score != 100
      puts submission if score == 0
    end
    #g = AutoGrader.create('1', 'RspecGrader', submission, :spec => spec)
    #g.grade!
    #puts "#{g.normalized_score}, #{g.comments}"
    #if gets =~ /a/
    #  puts "Submission:"
    #  puts submission
    #end
  end
end
