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

