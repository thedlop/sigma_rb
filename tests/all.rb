require 'test/unit'

def is_ruby_test_file(filename)
  filename[-8..-1] == "_test.rb"
end

IGNORE = %w(
  all.rb . ..
)

dirs_to_walk = ["./tests"]
test_files = []

module DirWalker
  def self.walk_files(dirs_to_walk, ignore_list:[".", ".."], &block)
    loop do
      break if dirs_to_walk.empty?
      current_dir = dirs_to_walk.shift
      Dir.chdir(current_dir)
      Dir.foreach(".") do |f|
        next if ignore_list.include?(f)
        if File.directory?(f)
          dirs_to_walk.push(File.expand_path(f))
        else
          block.call(f)
        end
      end
    end
  end
end

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

