Gem::Specification.new do |s|
  s.name        = 'nil-passer'
  s.version     = '0.2.0'
  s.date        = '2017-04-03'
  s.summary     = "Pass nil to all the blocks in an app, catching and logging exceptions"
  s.description = "A nil-tester for blocks"
  s.authors     = ["Michael Klein"]
  s.email       = "lambdamichael@gmail.com"
  s.files       = Dir["lib/**/*.rb"]
  s.homepage    = 'https://michaeljklein.github.io/nil-passer/'
  s.license     = 'MIT'

  s.add_development_dependency "appraisal"
  s.add_development_dependency 'pry'
  s.add_development_dependency 'gemika'

end
