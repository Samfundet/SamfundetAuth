class CreateMembers < ActiveRecord::Migration[5.2]
  def up
    create_table :members, :primary_key => :medlem_id do |t|
      t.string :fornavn
      t.string :etternavn
      t.string :mail
      t.string :telefon
      t.string :passord
    end
  end

  def down
    drop_table :members
  end
end
