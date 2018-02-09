require 'serverspec'
require 'selenium-webdriver'

ACCOUNT = ENV['APPVEYOR'] ? 'appveyor' : 'vagrant'

set :backend, :cmd
