class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || user.id == record.id
  end

  def update?
    show?
  end

  def destroy?
    index?
  end
end
