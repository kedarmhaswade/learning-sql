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
def visit_nary_tree(n = 2, n_nodes = 10) 
  #puts "n: #{n}, n_nodes: #{n_nodes}"
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
          yield parent, next_start + j
          j += 1
        end
      end
      level += 1
      cur_start = next_start
      cur_end = next_end
    end
  end
end
if ARGV.length < 2
  $stderr.puts "Usage: #{$0} n_children n_total" 
  $stderr.puts "e.g. #{$0} 10 1000 > emp.csv"
  exit 1
end
def id_names n_nodes
  idn = {}
  1.upto n_nodes do |id|
    idn[id] = Faker::Name.name
  end
  idn
end
require 'faker'
n, n_nodes = ARGV.map {|s| s.to_i}
puts "An Employee Database"
puts "id, emp_id, emp_name, mgr_id"
id = 1
puts "1, 1, #{Faker::Name.name}, NULL"
idn = id_names(n_nodes);
visit_nary_tree(n, n_nodes) do |mgr, emp|
  printf "%d, %d, %s, %d\n", id + 1, emp, idn[emp], mgr 
  id += 1
end

# use this script to create a temporary table for csv import into MySQL
