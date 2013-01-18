class User < ActiveRecord::Base
  has_many :billing_collections

  attr_accessor :street_address, :zip, :brand, :number, :expiration_year, :expiration_month, :csc

  before_create :create_customer_profile
  before_destroy :destroy_customer_profile

  def bill(amount, gateway = Gateway.new)
    response = gateway.create_customer_profile_transaction(
      transaction: {
        type: :auth_capture,
        amount: (amount/100.00).to_s,
        customer_profile_id: self.profile_id,
        customer_payment_profile_id: self.payment_profile_id
      }
    )

    return response.success?
  end

private
  def create_customer_profile(gateway = Gateway.new)
    cc = ActiveMerchant::Billing::CreditCard.new(
      first_name: self.first,
      last_name:  self.last,
      month:      self.expiration_month,
      year:       self.expiration_year,
      brand:      self.brand,
      number:     self.number
    )

    response = gateway.create_customer_profile(
      profile: {
        email: self.email,
        payment_profiles: {
          bill_to: {
            first_name: self.first,
            last_name: self.last,
            address: self.street_address,
            zip: self.zip
          },
          payment: {
            credit_card: cc
          }
        }
      },
      validation_mode: :live
    )

    if response.success?
      self.profile_id = response.params["customer_profile_id"]
      self.payment_profile_id = response.params["customer_payment_profile_id_list"]["numeric_string"]
      return true
    end

    return false
  end

  def destroy_customer_profile(gateway = Gateway.new)
    gateway.delete_customer_profile(customer_profile_id: self.profile_id)
  end
end