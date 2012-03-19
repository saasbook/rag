namespace :saas do 
  task :run_student_tests => :environment do
    desc "Runs all tasks for grading"

    errors = []

    puts "----BEGIN CUCUMBER----"
    puts "-"*80
    begin
      Rake::Task["cucumber"].invoke
    rescue StandardError => e
      errors << e.message
    end
    puts "-"*80
    puts "----END CUCUMBER----"

    puts "----BEGIN RSPEC----"
    puts "-"*80
    begin
      Rake::Task["spec"].invoke
    rescue StandardError => e
      errors << e.message
    end
    puts "-"*80
    puts "----END RSPEC----"

    raise StandardError, errors.join("\n") if errors.size > 0
  end
end
