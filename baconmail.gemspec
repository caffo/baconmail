$:.unshift File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name             = 'baconmail'
  s.version          = Baconmail::VERSION
  s.platform         = Gem::Platform::RUBY

  s.authors          = ["rodrigo franco (caffo)"]
  s.email            = ['baconmail@caffo.me']
  s.homepage         = 'http://github.com/caffo/baconmail'
  s.summary          = 'gmail based otherinbox defender alternative'
  s.description      = 'The original Otherinbox Defender is no more. Sadly, the newest version is subpar and do not meet my needs. This project attempts to reproduce the core functionalities of OIB Defender using a GMail account.'

  s.files            = `git ls-files`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = %w[ LICENSE.txt README.rdoc ]
  s.require_paths    = %w[ lib ]

  s.add_runtime_dependency 'gmail', ">= 0.4.0"
  s.add_runtime_dependency 'aws-s3'
  s.add_development_dependency 'rake'
end

