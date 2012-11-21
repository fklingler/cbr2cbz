# encoding: utf-8

require 'fileutils'
require 'zip/zip'
require 'zip/zipfilesystem'

ARGV.each do |arg|
  files = File.directory?(arg) ? Dir.glob(arg + '/**') : [arg]
  files.each do |filename|
    if File.extname(filename) == '.cbr'
      FileUtils.cd(File.dirname(filename)) do

        # Unrar CBR
        filename_without_ext = File.basename(filename, '.*')

        `unrar e "#{filename}" "#{filename_without_ext}"/`

        # Create CBZ
        archive = filename_without_ext + '.cbz'

        Zip::ZipFile.open(archive, 'w') do |zipfile|
          Dir[filename_without_ext + "/*"].each do |file|
            zipfile.add(File.basename(file),file)
          end
        end

        # Clean up
        FileUtils.rm_rf(filename_without_ext)
        FileUtils.rm(filename)
      end
    end
  end
end
