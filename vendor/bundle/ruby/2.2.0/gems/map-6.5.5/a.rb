
m = Map.new

p m

m.unshift(:a => :b)
m.unshift(:c => :d)
m.unshift(:e => :f)

p m
p(pair = m.shift)
p m

m.push(pair)
p m

p(pair = m.pop)
p m

m.unshift(pair)
p m

