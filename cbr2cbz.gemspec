# encoding: utf-8
$:.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name              = "cbr2cbz"
  s.version           = '0.1.3'
  s.license           = 'MIT'
  s.author            = "François Klingler"
  s.email             = "francois@fklingler.com"
  s.homepage          = "http://github.com/fklingler/cbr2cbz"
  s.summary           = "CBR to CBZ converter"
  s.description       = "Utility to convert Comic Book Rar archives to Zip equivalent"

  s.files             = Dir.glob("lib/**/*")
  s.executables       = %w( cbr2cbz )

  s.add_runtime_dependency 'rubyzip', '~> 0.9', '>= 0.9.8'
end
