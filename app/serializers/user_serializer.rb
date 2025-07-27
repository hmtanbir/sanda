class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at, :updated_at, :deleted_at
end
