require_relative './lib/main.rb'

Main{
  daemonizes!

  def run
    i = 0

    loop do
      p argv
      p i
      sleep(3 + rand)
      i += 1
    end
  end





}


__END__


a.rb daemon start
a.rb daemon stop
