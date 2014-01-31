class MembersRole < ActiveRecord::Base
  validates_presence_of :member_id
  validates_presence_of :role_id

  belongs_to :member
  belongs_to :role
end
