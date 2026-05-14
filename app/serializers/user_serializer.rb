class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role, :status, :created_at, :updated_at, :deleted_at
end
