require 'rails'
module CodeMetrics
  class Railtie < Rails::Railtie
    railtie_name :code_metrics

    rake_tasks do
      load "tasks/statistics.rake"
    end
  end
end
