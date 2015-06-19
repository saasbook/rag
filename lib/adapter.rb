require 'yaml'

module Adapter
  DEFAULT_NAME = :xqueue

  ADAPTER_NOT_FOUND = "Adapter not found: %s"
  CONF_FILE_NOT_FOUND = <<-EOS
    Conf file not found: %s
    Please copy conf.yml.example into %s and configure the parameters.
  EOS
  CONF_KEY_NOT_FOUND = <<-EOS
    Conf key not found: %s
    In conf file: %s
  EOS

  # Formats autograder ouput for display in browser
  def format_for_html(text)
    "<pre>#{CGI.escape_html(text)}</pre>" # sanitize html
  end

  def create_adapter(path, config_name = 'default')
    conf = load_conf(path, config_name)
    get(conf['adapter']).new(conf)
  end

  private

  def load_conf(path, config_name = 'default')
    raise CONF_FILE_NOT_FOUND % path, path unless File.file?(path)
    config = YAML.load_file(path)
    config[config_name] || config[config.keys.first] || (raise CONF_KEY_NOT_FOUND % config_name, path)
  end

  def get(name = DEFAULT_NAME)
    case name.downcase.to_sym
    when :xqueue
      require_relative 'adapter/xqueue'
      Xqueue
    else
      raise ADAPTER_NOT_FOUND % name.inspect
    end
  end
end
