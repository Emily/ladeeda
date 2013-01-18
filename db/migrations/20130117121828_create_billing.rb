class CreateBilling < ActiveRecord::Migration
  def change
    create_table :billings do |t|
      t.integer :amount, default: 0

      t.string :callback_url
      t.string :description

      t.references :billing_collection

      t.timestamps
    end
  end
end