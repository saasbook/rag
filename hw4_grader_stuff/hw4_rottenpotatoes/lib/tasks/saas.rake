namespace :saas do 
  task :run_student_tests => :environment do
    desc "Runs all tasks for grading"

    errors = []
    puts "----BEGIN RSPEC----"
    puts "-"*80
    begin
      Rake::Task["spec"].invoke
    rescue SystemExit => e
      errors << e.message
    end
    puts "-"*80
    puts "----END RSPEC----"


    puts "----BEGIN CUCUMBER----"
    puts "-"*80
    begin
      Rake::Task["cucumber"].invoke
    rescue SystemExit => e
      errors << e.message
    end
    puts "-"*80
    puts "----END CUCUMBER----"

    puts errors.join("\n") if errors.any?
  end
end
