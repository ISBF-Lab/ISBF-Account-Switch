# frozen_string_literal: true

module IsbfAccountSwitch
  class AuditEvent < ActiveRecord::Base
    self.table_name = "isbf_account_switch_audit_events"

    belongs_to :account_link, optional: true
    belongs_to :actor, class_name: "User", optional: true

    def self.record!(action:, link: nil, actor: nil, request: nil, metadata: {})
      safe_metadata = metadata.stringify_keys
      if request
        safe_metadata["ip"] = request.remote_ip
        safe_metadata["user_agent"] = request.user_agent.to_s.first(255)
      end

      create!(
        action: action,
        account_link: link,
        actor: actor,
        metadata: safe_metadata
      )
    end
  end
end
