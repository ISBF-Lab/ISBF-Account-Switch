# frozen_string_literal: true

module IsbfAccountSwitch
  class DeviceGrant < ActiveRecord::Base
    self.table_name = "isbf_account_switch_device_grants"

    belongs_to :account_link
    belongs_to :user

    scope :active,
          -> { where(revoked_at: nil).where("expires_at > ?", Time.zone.now) }
  end
end
