require 'nokogiri'

class CovHelper

  class << self
    def default_cov_opts
      {
        :pass_threshold => {
          :controllers => 0.9,
          :models      => 0.9
        }
      }
    end
  end

  # Nokogiri page
  attr_reader :page

  # [_Array_<_String_>] log details from the parse
  attr_reader :details

  attr_reader :results, :passes, :failures

  # :config:
  # [+:pass_threshold+] [_Hash_]
  #   { :controllers => 0.9, :models => 0.9 }
  def initialize(cov_index_html, config={})
    begin
      @page = Nokogiri::HTML(open(cov_index_html))
    rescue => e
      raise ArgumentError, "Could not open #{cov_index_html} for parsing (#{e.inspect})"
    end

    @parsed = false
    @details = []

    @results = {
      :all => 0,
      :controllers => 0,
      :models      => 0,
      :mailers     => 0,
      :helpers     => 0,
      :libraries   => 0,
      :plugins     => 0
    }

    @passes   = []      # [:controllers, :models, ...]
    @failures = []      # [:helpers, :libraries, ...]

    @config = self.class.default_cov_opts.update(config)
  end

  def correct?
    parse!
    return @failures.none?
  end

  def parse!
    return if @parsed

    groups = @page.css('.group_name').collect(&:parent)

    groups.each do |group|
      group_name, pct = %w(.group_name .covered_percent).
        collect {|s| group.at_css(s)}.collect(&:text)

      group_name = group_name.downcase.to_sym
      pct = pct.to_f / 100 # NOTE this is in normalized percent [0,1]

      @results[group_name] = pct.to_f
      @details << "#{group_name}: #{format '%.2f%%', pct*100}% coverage"
    end

    @config[:pass_threshold].each_pair do |group, thresh|
      (@results[group] >= thresh ? @passes : @failures) << group
    end

    @parsed = true
  end

end
