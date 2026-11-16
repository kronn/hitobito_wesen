$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_wesen/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # rubocop:disable SingleSpaceBeforeFirstArg
  s.name        = 'hitobito_wesen'
  s.version     = HitobitoWesen::VERSION
  s.authors     = ['An Author']
  s.email       = ['wesen@example.org']
  # s.homepage    = 'TODO'
  s.summary     = 'Wesentliche Wesen'
  s.description = 'Im wesentlichen etwas Beispielcode, um eine Gruppenstruktur für einen kleinen Verein zu zeigen.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']
  # rubocop:enable SingleSpaceBeforeFirstArg
end
