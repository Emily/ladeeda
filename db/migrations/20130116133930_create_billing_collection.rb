class CreateBillingCollection < ActiveRecord::Migration
  def change
    create_table :billing_collections do |t|
      t.integer :amount, default: 0
      t.string :period, null: false
      t.integer :failure_count, default: 0

      t.datetime :bill_at, null: false
      t.datetime :bill_until
      t.datetime :retry_at

      t.boolean :active, default: true

      t.references :user

      t.timestamps
    end
  end
end