# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'tabularize/version'

Gem::Specification.new do |s|
  s.name        = 'tabularize'
  s.version     = Tabularize::VERSION
  s.authors     = ['Junegunn Choi']
  s.email       = ['junegunn.c@gmail.com']
  s.homepage    = 'https://github.com/junegunn/tabularize'
  s.summary     = 'Formatting tabular data'
  s.description = 'Formatting tabular data with paddings and alignments'

  s.rubyforge_project = 'tabularize'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_development_dependency 'minitest'
  s.add_runtime_dependency 'unicode-display_width', '>= 1.3.0'
end
