# encoding: utf-8

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: cbr2cbz [options] file ..."

  opts.on("-k", "--keep", "Keep original file") do |k|
    options[:keep] = k
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
  files = File.directory?(arg) ? Dir.glob(arg + '/**') : [arg]
  files.each do |filename|
    if File.extname(filename).downcase == '.cbr'
      FileUtils.cd(File.dirname(filename)) do

        filename_without_ext = File.basename(filename, '.*')

        # Unrar CBR
        `unrar e "#{filename}" "#{filename_without_ext}"/`

        # Create CBZ
        new_file = filename_without_ext + '.cbz'

        Zip::ZipFile.open(new_file, 'w') do |zipfile|
          Dir[filename_without_ext + "/*"].each do |file|
            zipfile.add(File.basename(file),file)
          end
        end

        # Clean up
        FileUtils.rm_rf(filename_without_ext)
        FileUtils.rm(filename) unless options[:keep]
      end
    end
  end
end
