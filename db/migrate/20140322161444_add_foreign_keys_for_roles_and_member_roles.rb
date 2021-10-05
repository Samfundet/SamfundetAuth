# frozen_string_literal: true

class AddForeignKeysForRolesAndMemberRoles < ActiveRecord::Migration
  def up
    add_foreign_key :roles, :roles
    add_foreign_key :roles, :groups
    add_foreign_key :members_roles, :roles
  end

  def down
    remove_foreign_key :roles, :roles
    remove_foreign_key :roles, :groups
    remove_foreign_key :members_roles, :roles
  end
end
