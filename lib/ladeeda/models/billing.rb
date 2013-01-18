class Billing < ActiveRecord::Base
  belongs_to :billing_collection
  has_one :user, through: :billing_collection

  validates :billing_collection_id, presence: true
  validates :callback_url, presence: true
  validates :amount, presence: true, numericality: {greater_than: 0}

  after_save :update_billing_collection

  def failed
    require 'net/http'

    uri = URI.parse(self.callback_url)
    Net::HTTP.post_form(uri, {})
  end

private

  def update_billing_collection
    self.billing_collection.rebuild_amount
  end
end