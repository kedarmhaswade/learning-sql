#!/usr/bin/env ruby

def n_cur(level, n)
  level**n
end
def cur_end(cur_start, level, n)
  return cur_start + (n**level) - 1
end
def get_next(cur_end, level, n)
  next_start = cur_end + 1
  next_end = next_start + (n**level) - 1
  return next_start, next_end
end
n, n_nodes = ARGV.map {|arg| arg.to_i}
# this does not work!
puts "n: #{n}, n_nodes: #{n_nodes}"
level = 0
i = 0
cur_start = 1
cur_end = 1
catch(:done) do
  loop do # for each level
    next_start, next_end = get_next(cur_end, level+1, n)
    j = 0
    cur_start.upto cur_end do |parent| # parent = node index in current level
      1.upto n do |child| # for each child for a given parent
        i += 1
        throw :done if i >= n_nodes
        puts "#{parent}, #{next_start + j}"
        j += 1
      end
    end
    level += 1
    cur_start = next_start
    cur_end = next_end
  end
end
