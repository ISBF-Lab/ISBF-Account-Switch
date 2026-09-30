# frozen_string_literal: true

module IsbfAccountSwitch
  class AccountLink < ActiveRecord::Base
    self.table_name = "isbf_account_links"

    enum :status,
         {
           pending_target: 0,
           pending_admin: 1,
           approved: 2,
           rejected: 3,
           revoked: 4
         }

    belongs_to :user_a, class_name: "User"
    belongs_to :user_b, class_name: "User"
    belongs_to :requester, class_name: "User"
    belongs_to :approved_by, class_name: "User", optional: true
    belongs_to :rejected_by, class_name: "User", optional: true
    belongs_to :revoked_by, class_name: "User", optional: true

    has_many :device_grants, dependent: :delete_all
    has_many :audit_events, dependent: :nullify

    validates :user_a_id, uniqueness: { scope: :user_b_id }
    validate :ordered_distinct_users

    scope :for_user,
          ->(user_id) do
            where("user_a_id = :id OR user_b_id = :id", id: user_id)
          end

    def self.ordered_ids(first_id, second_id)
      [first_id, second_id].sort
    end

    def other_user(user)
      user.id == user_a_id ? user_b : user_a
    end

    def participant?(user)
      user && (user.id == user_a_id || user.id == user_b_id)
    end

    def target_user
      requester_id == user_a_id ? user_b : user_a
    end

    private

    def ordered_distinct_users
      return if user_a_id && user_b_id && user_a_id < user_b_id

      errors.add(:base, "users must be distinct and ordered")
    end
  end
end
