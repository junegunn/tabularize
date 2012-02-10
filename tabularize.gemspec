# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tabularize/version"

Gem::Specification.new do |s|
  s.name        = "tabularize"
  s.version     = Tabularize::VERSION
  s.authors     = ["Junegunn Choi"]
  s.email       = ["junegunn.c@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Formatting tabular data}
  s.description = %q{Formatting tabular data with paddings and alignments}

  s.rubyforge_project = "tabularize"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "awesome_print"
end
