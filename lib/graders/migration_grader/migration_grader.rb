require 'ruby-debug'
require 'open3'
require 'yaml'
require 'term/ansicolor'
require 'thread'
require 'fileutils'
require 'tempfile'
require 'tmpdir'
require './lib/util.rb'
require 'rspec'
require_relative '../../rag_logger.rb'

class MigrationGrader < AutoGrader
  include RagLogger
  def initialize(submission_archive, grading_rules={})
    @output = []
    logger.info "submission archive is #{submission_archive}"
    unless @submission_archive = submission_archive and File.file? @submission_archive and File.readable? @submission_archive
      raise ArgumentError, "Unable to find submission file #{@submission_archive.inspect}"
    end
    unless @description = (grading_rules[:spec] || grading_rules[:description]) and File.file? @description and File.readable? @description
      raise ArgumentError, "Unable to find description file #{@description.inspect}"
    end
    @temp = TempArchiveFile.new(@submission_archive)
    logger.info "submission archive is #{@submission_archive}"
  end

  def grade!
    logger.info "hw6 grading"
    begin
      #        logger.fatal "I am grading!"
      load_description
      #       logger.info "I am grading!"
      @raw_score = 0
      @raw_max = 100
      start_time = Time.now

      Dir.mktmpdir('hw6_grader', '/tmp') do |tmpdir|
        #puts tmpdir.inspect
        # Copy base app
        logger.info "about to copy base app"
        FileUtils.cp_r Dir.glob(File.join(@base_app_path,"*")), tmpdir

        # Copy submission files over base app
        ## TODO: Double check that file structure is correct
        logger.info "about to copy student file app"
        #  logger.info `ls #{File.join(@temp.path,"/")}`
        logger.info `ls #{File.join(tmpdir,"/")}`
        logger.info "#{File.join(@temp.path,"/")}"
        FileUtils.cp_r Dir.glob(File.join(@temp.path,"/*")), File.join(tmpdir, "db")
        logger.info "finished copying"
        Dir.chdir(tmpdir) do
          logger.info "changed directory"
          env = {
              'RAILS_ROOT' => tmpdir
          }
          time_operation 'setup' do
            setup_rails_app(env)
          end

          separator = '-'*40  # TODO move this
          logger.info "about to check for indices"
          score,comments=check_for_indices(File.join("db","schema.rb"))
          #  puts "Returned Score + comments are #{score} \n #{comments}"

          @raw_score=score
          self.comments=comments
        end
      end

        #log "Total score: #{@raw_score} / #{@raw_max}"
        #log "Completed in #{Time.now-start_time} seconds."
    ensure
      @temp.destroy if @temp
    end
  end

  private
  def setup_rails_app(env)
    logger.info "setup rails"
    setup_cmds = [
        "bundle install --without production",
        "bundle exec rake db:migrate",# db:test:prepare",
    ]
    setup_cmds.each do |cmd|
      logger.info "running + #{cmd}"
      Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
        exitstatus = wait_thr.value.exitstatus
        out = stdout.read
        err = stderr.read
        if exitstatus != 0
          logger.info out + " " +err
          raise out + err
        end
      end
    end
  end

  def load_description
    y = YAML::load_file(@description)

    # Load stuff we would need
    # Directory of base app to copy over
    @base_app_path = y['base_app_path']

  end
#add_index "reviews", ["movie_id"], :name => "movie_id_ix"
  def check_for_indices(schema_file)
    logger.info "checking for indices in #{schema_file}"
    required_indices={"movie_id"=> 0, "moviegoer_id" => 0}
    test_file=File.new(schema_file,"r")
    indices=[]
    test_file.each do |l|
      logger.info l
      indices << l if l=~ /add_index/
    end
    logger.info indices
    indices.each do |i|
      logger.info "inspecting #{i}"
      if(matcher=i.match /.*add_index\s*"reviews"\s*, \["(.*)"\].*/)
        column = matcher[1]
        logger.info "column is #{$1}"
        if column
          logger.info "column is #{column.to_s}"
          if required_indices.keys.include? column
            required_indices[column]=1
          end
        end
      end
    end
    puts required_indices

    score=50*(required_indices["movie_id"] + required_indices["moviegoer_id"])
    comments="Indices on database:\n"
    required_indices.each do |k,v|
      found_status= v==0 ? "not " : ""
      comments += "Required index on column #{k} was #{found_status}found #{v*50}/50 \n"
    end
    return score,comments
  end

  def time_operation(name=nil)
    start_time = Time.now.to_f
    yield
    end_time = Time.now.to_f
    # TODO: Make this a debug mode setting
    puts "#{name}: #{end_time - start_time}s"
  end
end

