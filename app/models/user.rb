class User < ApplicationRecord
  enum :role, YAML.load_file(Rails.root.join("config/roles.yml")).symbolize_keys.freeze
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :role, presence: true

  scope :all_users, -> { where(deleted_at: nil) }
  scope :role_users, ->(role) { where(role: role) }
end
