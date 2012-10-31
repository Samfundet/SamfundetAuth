class MembersRole < ActiveRecord::Base
  validates_presence_of :member_id
  validates_presence_of :role_id

  belongs_to :member, :dependent => :destroy
  belongs_to :role, :dependent => :destroy
end
