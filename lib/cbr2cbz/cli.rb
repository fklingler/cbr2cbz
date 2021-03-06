require 'optparse'

module Cbr2cbz
  class CLI
    def self.start
      options = {}
      opts = OptionParser.new do |opts|
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
      end
      opts.parse!

      if ARGV.empty? 
        puts opts
      else
        Converter.new(options).convert(ARGV)
      end
    end
  end
end