Gem::Specification.new do |s|
  s.name        = 'PhantomAnimationEditor'
  s.version     = '0.1.0'
  s.license     = 'GPL-3.0+'
  s.summary     = "Animation editor that generates frame animated SVG and animated PNG files"
  s.description = "Animation editor primarily targeted at making small but high quality animations."
  s.authors     = ['Rei Kagetsuki', 'Rika Yoshida']
  s.email       = 'info@phantom.industries'
  s.homepage    = 'https://github.com/PhantomCreation/PhantomAnimationEditor'
  
  s.files       = Dir.glob('bin/*.rb') +
                  Dir.glob('lib/**/*.rb') +
                  Dir.glob('lib/**/*.glade') +
                  ['PhantomAnimationEditor.gemspec']
  s.require_paths = ['lib']
  s.executables << 'PhantomAnimationEditor'

  s.add_dependency 'phantom_svg', '~> 1.2', '>= 1.2.3'
  s.add_dependency 'gtk3', '~> 3.0', '>= 3.0.9'
end
