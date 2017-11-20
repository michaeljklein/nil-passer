
appraise 'master' do
  gem 'rake', '>= 11.1'
  gem 'rails', '>= 4.2.7'
  gem 'activerecord', '>= 3.2.22'
end

appraise "one" do
  gem 'rake', '>= 10.0'
  gem 'rails', '>= 4.0.0'
end

appraise "rails-4" do
  gem 'rake', '>= 12.0'
  gem 'rails', '>= 4.3.0'
end

appraise "3.2.22" do
  # Ruby
  ruby '< 2.4.0'

  # Runtime dependencies
  gem 'activerecord', '=3.2.22'

  # Development dependencies
  gem 'rake', '=10.0.4'
end

appraise "4.2.1" do
  ruby '>= 1.9.3'

  # Runtime dependencies
  gem 'activerecord', '~>4.2.1'

  # Development dependencies
  gem 'rake'
end

appraise "5.0.0" do
  ruby '>= 2.2'

  # Runtime dependencies
  gem 'activerecord', '~>5.0.0'

  # Development dependencies
  gem 'rake'
end

