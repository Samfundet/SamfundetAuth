class CreateMembersRoles < ActiveRecord::Migration
  def up
    create_table :members_roles do |t|
      t.references :member
      t.references :role
    end
  end

  def down
    drop_table :members_roles
  end
end
