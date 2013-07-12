class Grader
  def self.cli(args)
     return self.help if args.length != 2
  end
  def self.help
    "You are too stupid!"
  end
end