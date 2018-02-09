require 'spec_helper'

describe 'Google Chrome' do
  before(:all) do
    @selenium = Selenium::WebDriver.for(:remote, url: "http://localhost:4444/wd/hub", desired_capabilities: :chrome)
  end

  after(:all) do
    @selenium.quit
  end

  res = '1366 x 768'

  it "should return display resolution of #{res}" do
    @selenium.get 'http://www.whatismyscreenresolution.com/'
    element = @selenium.find_element(:id, 'resolutionNumber')
    expect(element.text).to eq(res)
  end
end unless ENV['APPVEYOR']
