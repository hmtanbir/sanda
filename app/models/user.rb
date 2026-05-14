class User < ApplicationRecord
  enum :role, YAML.load_file(Rails.root.join("config/data/roles.yml")).symbolize_keys.freeze, default: :user
  enum :status, YAML.load_file(Rails.root.join("config/data/statuses.yml")).symbolize_keys.freeze, default: :active
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, allow_nil: true, on: :update
  validates :role, presence: true
  validates :status, presence: true

  scope :all_users, ->(deleted = false) { deleted ? where.not(deleted_at: nil) : where(deleted_at: nil) }
  scope :role_users, ->(role, deleted = false) {
    scope = where(role: role)
    deleted ? scope.where.not(deleted_at: nil) : scope.where(deleted_at: nil)
  }


  def inactive?
    deleted_at.present? || status == "inactive"
  end
end
