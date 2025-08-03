# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding users..."

admin = User.find_or_create_by!(email: "admin@sanda.project") do |user|
  user.password = "sanda-admin-123"
  user.name = "Admin User"
  user.role = :admin
end

user = User.find_or_create_by!(email: "user@sanda.project") do |user|
  user.password = "sanda-user-123"
  user.name = "Regular User"
  user.role = :user
end

# remove old users data from redis database
keys = $redis_user_db.keys("users:*")
$redis_user_db.del(*keys) unless keys.empty?

# Store in Redis DB
[ admin, user ].each do |u|
  RedisUserService.new(u).save
end

puts "Done seeding for admin and user"
