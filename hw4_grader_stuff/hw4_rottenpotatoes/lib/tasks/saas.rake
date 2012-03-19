namespace :saas do 
  task :grade => :environment do
    desc "Runs all tasks for grading"
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:test:prepare"].invoke
    begin
      Rake::Task["cucumber"].invoke
    rescue StandardError => e
      puts e
    end
    Rake::Task["spec"].invoke
  end
end
