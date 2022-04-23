require 'test/unit'
require_relative '../lib/dir_walker.rb'

def is_ruby_test_file(filename)
  filename[-8..-1] == "_test.rb"
end

IGNORE = %w(
  all.rb . ..
)

dirs_to_walk = ["./tests"]
test_files = []

DirWalker.walk_files(dirs_to_walk, ignore_list: IGNORE) do |f|
  if is_ruby_test_file(f)
    test_files << File.expand_path(f)
  end
end

puts test_files.inspect

# Require test files
test_files.each do |f|
  require f
end

