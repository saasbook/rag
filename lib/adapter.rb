require 'yaml'

module Adapter
  DEFAULT_NAME = :xqueue

  # Formats autograder ouput for display in browser
  def self.format_for_html(text)
    "<pre>#{CGI.escape_html(text)}</pre>" # sanitize html
  end

  def self.load(path, config_name = 'default')
    conf = load_conf(path, config_name)
    get(conf['adapter']).new(conf)
  end

  private

  def self.load_conf(path, config_name = 'default')
    err_no_confs(path) unless File.file?(path)
    confs = YAML.load_file(path)
    confs[config_name] || err_no_conf(config_name, path)
  end

  def self.get(name = DEFAULT_NAME)
    case name.downcase.to_sym
    when :xqueue
      require_relative 'adapter/xqueue'
      Xqueue
    else
      err_no_adapter(name.inspect)
    end
  end

  private

  def self.err_no_adapter(name)
    raise "Adapter not found: #{name}"
  end

  def self.err_no_confs(path)
    raise <<-EOS
      Conf file not found: #{path}
      Please copy conf.yml.example into #{path} and configure the parameters.
    EOS
  end

  def self.err_no_conf(key, path)
    raise <<-EOS
      Conf key not found: #{key}
      In conf file: #{path}
    EOS
  end
end
