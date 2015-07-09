# Ruby intro part 1 solutions

# Returns the sum of all the numbers in `collection`, which must be
# enumerable
def sum(collection)
  collection.inject(0) do |total, n|
    total + n
  end
end

# Return the sum of the 2 largest elements in a collection
def max_2_sum(collection)
end

# Return true iff exactly 2 elements of collection sum to the given number
# Uses the handy `permutation` instance method of `Array`.
def sum_to_n?(collection, total)
end