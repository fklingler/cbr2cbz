# encoding: utf-8
require 'fileutils'
require 'zip/zip'
require 'zip/zipfilesystem'

module Cbr2cbz
  class Converter
    def initialize(options = {})
      @options = options
    end

    def convert(entries = [])
      entries.each do |entry|
        if File.exists?(entry)
          if File.directory?(entry)
            convert_dir(entry)
          else
            convert_file(entry)
          end
        else
          $stderr.puts "Warning -- #{entry} does not exist!"
        end
      end
    end

    def convert_dir(dirname)
      puts "Processing directory #{dirname}" if @options[:verbose]
      Dir.glob(dirname + '/**').each do |filename|
        convert_file(filename)
      end
    end

    def convert_file(filename)
      filename = File.expand_path(filename)
      if File.extname(filename).downcase == '.cbr'
        puts "Processing file #{File.basename(filename)}" if @options[:verbose]
        FileUtils.cd(File.dirname(filename)) do

          filename_without_ext = File.basename(filename, '.*')
          new_filename = filename_without_ext + '.cbz'

          if File.exists?(new_filename)
            $stderr.puts "Warning -- #{new_filename} already exists! Skipping."
          else
            # Check if it's actually a CBZ file
            if is_cbz?(filename)
              puts "#{File.basename(filename)} is already a CBZ file. Renaming..."
              FileUtils.mv(filename, new_filename)
              next
            end

            # Unrar CBR
            unrar(filename, filename_without_ext)

            # Create CBZ
            Zip::ZipFile.open(new_filename, 'w') do |zipfile|
              Dir[filename_without_ext + "/*"].each do |file|
                zipfile.add(File.basename(file), file)
              end
            end

            # Clean up
            FileUtils.rm_rf(filename_without_ext)
            FileUtils.rm(filename) unless @options[:keep]

            puts "Created new file #{new_filename}" if @options[:verbose]
          end
        end
      end
    end

    def unrar(filename, folder)
      `unrar e "#{filename}" "#{folder}/"`
    end

    def is_cbz?(filename)
      Zip::ZipFile.open(filename) do |zipfile|
        zipfile.entries.any? { |entry| entry.name.downcase.end_with?('.jpg', '.jpeg', '.png', '.gif') }
      end
    rescue
      false
    end
  end
end
