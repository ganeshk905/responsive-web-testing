require 'selenium-webdriver'
require 'eyes_selenium'
require_relative '../lib/batch_info'

RSpec.configure do |config|

  config.before(:suite) do
    Thread.current[:batch] = Applitools::Base::BatchInfo.new('Responsive Web Batch')
    Thread.current[:batch].set_id(ENV['batch_id'])
  end

  config.before(:each) do |example|
    # Set Capabilities for Selenium
    caps                      = Selenium::WebDriver::Remote::Capabilities.send(ENV['browser'])
    caps.version              = ENV['browser_version']
    caps.platform             = ENV['platform']
    caps[:name]               = example.metadata[:full_description]
    caps['screenResolution'] = '1280x1024'

    # Get a browser from Sauce Labs
    @browser                  = Selenium::WebDriver.for(
      :remote,
      url: "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub",
      desired_capabilities: caps)

    # Connect to Appltools for Visual Comparison
    @eyes                     = Applitools::Eyes.new
    @eyes.api_key             = ENV['APPLITOOLS_API_KEY']
    @eyes.batch               = Thread.current[:batch]
    @driver                   = @eyes.open(
                                  app_name:       'the-internet',
                                  test_name:      example.metadata[:full_description],
                                  viewport_size:  { width:  ENV['viewport_width'].to_i,
                                                    height: ENV['viewport_height'].to_i },
                                  driver:         @browser)
  end

  config.after(:each) do
    begin
      @eyes.close
    ensure
      @browser.quit
    end
  end

end
