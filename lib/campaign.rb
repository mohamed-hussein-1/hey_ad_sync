require 'active_record'
class Campaign < ActiveRecord::Base
  STATUS_HASH = {active: 0, paused: 1, deleted: 2}
  enum status: STATUS_HASH, _prefix: :status

  def self.campaign_with_reference(ex_ref_ids)
    Campaign.where(external_reference_id: ex_ref_ids)
  end
end