require 'test_helper'
require 'external_ad_service'

class ExternalAddServiceSpec < Minitest::Test
  DEMO_JSON = <<~JSON
  { "ads": 
    [ { "reference": "1", "status": "enabled", "description": "Description for campaign 11" },
      { "reference": "2", "status": "disabled", "description": "Description for campaign 12" },
      { "reference": "3", "status": "enabled", "description": "Description for campaign 13" }
    ] 
  }
  JSON

  describe "external service sync" do

    it "request external ads service" do
      stub_get = stub_http_request(:get, ExternalAdService::URL).to_return(body: DEMO_JSON)
      ExternalAdService.new.call
      assert_requested(stub_get)
    end

    it "hash response using reference id" do
      stub_http_request(:get, ExternalAdService::URL).to_return(body: DEMO_JSON)
      expected_data = {
          1 => { "reference" => "1", "status" => "enabled", "description" => "Description for campaign 11" },
          2 => { "reference" => "2", "status" => "disabled", "description" => "Description for campaign 12" },
          3 => { "reference" => "3", "status" => "enabled", "description" => "Description for campaign 13" }
      }
      res = ExternalAdService.new.call
      _(res[:data].keys.length).must_equal 3
      assert_equal(expected_data, (res[:data]))
    end

    it "raise exception when not success" do
      stub_http_request(:get, ExternalAdService::URL).to_return(status: 403)
      _(lambda {ExternalAdService.new.call}).must_raise StandardError
    end
  end
end