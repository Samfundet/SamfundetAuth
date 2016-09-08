class Role < ActiveRecord::Base
  validates_format_of :title, :with => /\A[a-z0-9\_\-]+\z/
  validates_presence_of :name, :description

  attr_readonly :title

  #attr_accessible :title, :name, :description, :group, :role

  default_scope { order(:title) }

  has_many :members_roles, :dependent => :destroy
  has_many :members, :through => :members_roles
  has_many :roles
  belongs_to :group
  belongs_to :role

  def to_s
    title
  end
end
