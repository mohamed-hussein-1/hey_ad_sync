require 'json'
require 'test_helper'
require 'ad_sync_service'
require 'external_ad_service'

class AdSyncServiceSpec < Minitest::Test
  describe "Ad Sync Service" do

    it "output correct number of changed" do
      external_service_output = {
          1 => { "reference" => "1", "status" => "enabled", "description" => "Description for campaign 11" },
          2 => { "reference" => "2", "status" => "disabled", "description" => "Description for campaign 12" },
          3 => { "reference" => "3", "status" => "enabled", "description" => "Description for campaign 13" }
      }
      campaigns = [Campaign.new(id: 3, external_reference_id: 3, description: "Hi Man", status: 0)]
      ExternalAdService.new.stub :call, {data: external_service_output, success: true} do |external_mock|
        Campaign.stub :campaign_with_reference, campaigns do
          ad_sync = AdSyncService.new(external_service: external_mock)
          res = ad_sync.call
          _(res[:success]).must_equal true
          _(res[:data].length).must_equal 1
        end
      end
    end

    it "output empty array when no diff" do
      external_service_output = {
          3 => { "reference" => "3", "status" => "enabled", "description" => "Description for campaign 13" }
      }
      campaigns = [Campaign.new(id: 3, external_reference_id: 3, description: "Description for campaign 13", status: 0)]
      ExternalAdService.new.stub :call, {data: external_service_output, success: true} do |external_mock|
        Campaign.stub :campaign_with_reference, campaigns do
          ad_sync = AdSyncService.new(external_service: external_mock)
          res = ad_sync.call
          _(res[:success]).must_equal true
          _(res[:data].length).must_equal 0
        end
      end
    end

    it "detects status and description change" do
      external_service_output = {
          3 => { "reference" => "3", "status" => "enabled", "description" => "Description for campaign 13 New" }
      }
      campaigns = [Campaign.new(id: 3, external_reference_id: 3, description: "Description for campaign 13", status: 1)]
      ExternalAdService.new.stub :call, {data: external_service_output, success: true} do |external_mock|
        Campaign.stub :campaign_with_reference, campaigns do
          ad_sync = AdSyncService.new(external_service: external_mock)
          res = ad_sync.call
          _(res[:success]).must_equal true
          assert_equal([{
                            remote_reference: 3,
                            discrepancies: [
                                {description: {remote: "Description for campaign 13 New", local: "Description for campaign 13"}},
                                {status: {remote: "enabled", local: "paused"}}
                            ]}
                       ], (res[:data]))
        end
      end
    end
  end
end