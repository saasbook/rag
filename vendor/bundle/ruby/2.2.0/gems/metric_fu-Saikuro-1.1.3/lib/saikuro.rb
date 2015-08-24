# Saikruo uses the BSD license.
#
# Copyright (c) 2005, Ubiquitous Business Technology (http://ubit.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#
#    * Neither the name of Ubiquitous Business Technology nor the names
#      of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written
#      permission.
#
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# == Author
# Zev Blut (zb@ubit.com)

require 'irb/ruby-lex'
require 'yaml'

# States to watch for
# once in def get the token after space, because it may also
# be something like + or << for operator overloading.

require 'saikuro/token_counter'
require 'saikuro/parse_state'
require 'saikuro/parse_comment'
require 'saikuro/parse_symbol'
require 'saikuro/endable_parse_state'
require 'saikuro/parse_class'
require 'saikuro/parse_module'
require 'saikuro/parse_def'
require 'saikuro/parse_cond'
require 'saikuro/parse_do_cond'
require 'saikuro/parse_block'
#
# ------------ END Analyzer logic ------------------------------------

require 'saikuro/filter'
require 'saikuro/base_formatter'
require 'saikuro/token_counter_formatter'
require 'saikuro/html_stylesheet'
require 'saikuro/html_token_counter_formatter'
require 'saikuro/parse_state_formatter'
require 'saikuro/state_html_complexity_formatter'
require 'saikuro/result_index_generator'


module Saikuro

  #Returns the path without the file
  def Saikuro.seperate_file_from_path(path)
    res = path.split("/")
    if res.size == 1
      ""
    else
      res[0..res.size - 2].join("/")
    end
  end

  def Saikuro.analyze(files, state_formater, token_count_formater, output_dir)

    idx_states = Array.new
    idx_tokens = Array.new

    # parse each file
    files.each do |file|
      begin
        STDOUT.puts "Parsing #{file}"
        # create top state
        top = ParseState.make_top_state
        STDOUT.puts "TOP State made" if $VERBOSE
        token_counter = TokenCounter.new
        ParseState.set_token_counter(token_counter)
        token_counter.set_current_file(file)

        STDOUT.puts "Setting up Lexer" if $VERBOSE
        lexer = RubyLex.new
        # Turn of this, because it aborts when a syntax error is found...
        lexer.exception_on_syntax_error = false
        lexer.set_input(File.new(file,"rb"))
        top.lexer = lexer
        STDOUT.puts "Parsing" if $VERBOSE
        top.parse


        fdir_path = seperate_file_from_path(file)
        FileUtils.makedirs("#{output_dir}/#{fdir_path}")

        if state_formater
          # output results
          state_io = StringIO.new
          state_formater.start(state_io)
          top.compute_state(state_formater)
          state_formater.end

          fname = "#{file}_cyclo.html"
          puts "writing cyclomatic #{file}" if $VERBOSE
          File.open("#{output_dir}/#{fname}","w") do |f|
            f.write state_io.string
          end
          idx_states<< [
            fname,
            state_formater.warnings.dup,
            state_formater.errors.dup,
          ]
        end

        if token_count_formater
          token_io = StringIO.new
          token_count_formater.start(token_io)
          token_counter.list_tokens_per_line(token_count_formater)
          token_count_formater.end

          fname = "#{file}_token.html"
          puts "writing token #{file}" if $VERBOSE
          File.open("#{output_dir}/#{fname}","w") do |f|
            f.write token_io.string
          end
          idx_tokens<< [
            fname,
            token_count_formater.warnings.dup,
            token_count_formater.errors.dup,
          ]
        end

      rescue RubyLex::SyntaxError => synerr
        STDOUT.puts "Lexer error for file #{file} on line #{lexer.line_no}"
        STDOUT.puts "#{synerr.class.name} : #{synerr.message}"
      rescue StandardError => err
        STDOUT.puts "Error while parsing file : #{file}"
        STDOUT.puts err.class,err.message,err.backtrace.join("\n")
      rescue Exception => ex
        STDOUT.puts "Error while parsing file : #{file}"
        STDOUT.puts ex.class,ex.message,ex.backtrace.join("\n")
      end
    end

    [idx_states, idx_tokens]
  end
end
require 'saikuro/saikuro_cmd_line_runner'
