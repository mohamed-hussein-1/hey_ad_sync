require 'json'
require 'test_helper'
require 'factory_bot'
require 'campaign'



class CampaignSpec < Minitest::Test
  include FactoryBot::Syntax::Methods

  FactoryBot.define do
    factory :campaign, class: "Campaign" do
    end
  end


  describe "campaign_with_reference" do
    # integration test to check that query to
    # get campaign with ids works
    before :each do
      DatabaseCleaner.start
    end

    after :each do
      DatabaseCleaner.clean
    end
    it "output ids passed" do
      campaign_1 = FactoryBot.create(:campaign, external_reference_id: 1)
      campaign_2 = FactoryBot.create(:campaign, external_reference_id: 2)
      campaign_3 = FactoryBot.create(:campaign, external_reference_id: 3)
      res = Campaign.campaign_with_reference([1,2])
      _(res.length).must_equal 2
      _(res.include? campaign_1).must_equal true
      _(res.include? campaign_2).must_equal true
      _(res.include? campaign_3).must_equal false
    end
  end
end

