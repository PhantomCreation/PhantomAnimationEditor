Gem::Specification.new do |s|
  s.name        = 'phantom-animation-editor'
  s.version     = '0.0.1'
  s.license     = 'GNU GPL v3'
  s.summary     = ""
  s.description = ""
  s.authors     = ['Rika Yoshida', 'Rei Kagetsuki']
  s.email       = 'info@genshin.org'
  s.files        = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/Genshin/PhantomAnimationEditor'

  s.executables << 'phantom-animation-editor'

  s.add_dependency 'phantom_svg'
  s.add_dependency 'gtk3'
end
