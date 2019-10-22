class Role < ApplicationRecord
  validates_format_of :title, :with => /\A[a-z0-9\_\-]+\z/
  validates_presence_of :name, :description

  attr_readonly :title

  default_scope { order(:title) }

  has_many :members_roles, :dependent => :destroy
  has_many :members, :through => :members_roles
  has_many :roles
  belongs_to :group, optional: true
  belongs_to :role, optional: true

  def to_s
    title
  end
end
