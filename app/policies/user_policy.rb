class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || user == record
  end

  def update?
    show?
  end

  def destroy?
    index?
  end
end
