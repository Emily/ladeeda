class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first
      t.string :last
      t.string :email

      t.string :profile_id
      t.string :payment_profile_id

      t.timestamps
    end
  end
end