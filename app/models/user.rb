class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :rememberable, :omniauthable, omniauth_providers: [:google_oauth2]

  include RoleModel

  has_many :competitions
  has_many :evolutions
  has_many :organizers
  has_one :player

  roles :organizer, :showrunner

  def can_edit_rulesets?
    has_any_role? :organizer, :showrunner
  end

  def can_read_roles?
    has_any_role? :organizer, :showrunner
  end

  def can_run_evolutions?
    has_any_role? :organizer, :showrunner
  end

  def can_write_roles?
    has_role? :organizer
  end

  def can_write_parts?
    has_role? :organizer
  end

  def can_grant_organizer?
    has_role? :organizer
  end

  def can_grant_showrunner?
    has_any_role? :organizer, :showrunner
  end
end
