# encoding: utf-8

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: cbr2cbz [options] file ..."

  opts.on("-k", "--keep", "Keep original file") do |k|
    options[:keep] = k
  end

  opts.on("-v", "--verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

require 'fileutils'
require 'zip/zip'
require 'zip/zipfilesystem'

ARGV.each do |arg|
  if File.exists?(arg)
    if File.directory?(arg)
      files = Dir.glob(arg + '/**')
      puts "Processing directory #{arg}" if options[:verbose]
    else
      files = [arg]
    end
    files.each do |filename|
      if File.extname(filename).downcase == '.cbr'
        puts "Processing file #{File.basename(filename)}" if options[:verbose]
        FileUtils.cd(File.dirname(filename)) do

          filename_without_ext = File.basename(filename, '.*')
          new_filename = filename_without_ext + '.cbz'

          if File.exists?(new_filename)
            $stderr.puts "Warning -- #{new_filename} already exists! Skipping."
          else
            # Unrar CBR
            `unrar e "#{filename}" "#{filename_without_ext}"/`

            # Create CBZ
            Zip::ZipFile.open(new_filename, 'w') do |zipfile|
              Dir[filename_without_ext + "/*"].each do |file|
                zipfile.add(File.basename(file),file)
              end
            end

            # Clean up
            FileUtils.rm_rf(filename_without_ext)
            FileUtils.rm(filename) unless options[:keep]

            puts "Created new file #{new_filename}" if options[:verbose]
          end
        end
      end
    end
  else
    $stderr.puts "Warning -- #{arg} does not exist!"
  end
end
