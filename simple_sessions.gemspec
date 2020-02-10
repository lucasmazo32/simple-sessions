# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'simple_sessions/version'

Gem::Specification.new do |s|
  s.name        = 'simple_sessions'
  s.version     = SimpleSessions::VERSION
  s.date        = '2020-02-06'
  s.summary     = 'This is a gem for creating simple sessions (without a permanent cookie) and sessions with permanent cookies'
  s.description = 'I created this gem to simplify my life (and hopefully, your life) when creating sessions in rails, in the README file is more information. As always, my recommendation is to learn how to create sessions by yourself and then use the gem. More information about this gem in https://github.com/lucasmazo32/simple-sessions'
  s.authors     = ['Lucas Mazo']
  s.email       = 'lucasmazo32@gmail.com'
  s.files       = Dir['lib/**/*', 'MIT-LICENSE', 'README.md']
  s.homepage =
    'https://github.com/lucasmazo32/simple-sessions'
  s.license = 'MIT'
end
