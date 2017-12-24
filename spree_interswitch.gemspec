Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_interswitch'
  s.version     = '0.1'
  s.summary     = 'Spree payment integration with Interswitch.'
  s.description = 'Spree payment integration with Interswitch.'

  s.author    = 'Santosh Singh'
  s.email     = 'santosh.singh@freshmonk.com'
  s.homepage  = 'https://github.com/kesid/spree_interswitch'

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0'
  s.add_dependency 'offsite_payments'
end