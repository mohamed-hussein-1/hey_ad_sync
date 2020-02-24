require 'campaign'
require 'faraday'
require 'faraday_middleware'
require 'external_ad_service'
class AdSyncService

  # variable to map remote status to local ( database status )
  EXTERNAL_STATUS_MAPPER = {"enabled" => "active", "disabled" => "paused"}

  # service used to access the remote resources
  attr_reader :external_service

  def initialize(external_service: ExternalAdService.new)
    @external_service = external_service
  end

  # calls external api and get the difference between
  # local and remote state
  def call
    res = {success: true}
    ex_serv_res = external_service.call
    remote_ads = ex_serv_res[:data]
    campaigns = Campaign.campaign_with_reference(remote_ads.keys)
    diff = campaigns.map do |campaign|
      remote_data = remote_ads[campaign.id]
      discrepancies = compare_local_remote(campaign, remote_data)
      if discrepancies.length > 0
        {remote_reference: campaign.external_reference_id, discrepancies: discrepancies}
      else
        nil
      end
    end.compact
    res[:data] = diff
    res
  end

  # helper function to calculate the difference between local campaign model and remote resource
  # returns output in form of array
  # array of length 0 means no diff
  # key of hash of output will be the field that is different
  def compare_local_remote(campaign, remote_data)
    discrepancies = []
    old_description = campaign.description
    new_description = remote_data["description"]
    if old_description != new_description
      discrepancies.push({description: {remote: new_description, local: old_description}})
    end
    old_status = campaign.status
    remote_status = remote_data["status"]
    remote_status_mapped = EXTERNAL_STATUS_MAPPER[remote_status]
    if old_status != remote_status_mapped
      discrepancies.push({status: {remote: remote_status, local: old_status}})
    end
    discrepancies
  end


end