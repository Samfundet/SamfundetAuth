class CreateMembersRoles < ActiveRecord::Migration[5.2]
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
