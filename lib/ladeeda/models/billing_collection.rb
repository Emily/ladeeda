class BillingCollection < ActiveRecord::Base
  has_many :billings
  belongs_to :user

  has_duration :period

  validates :period, presence: true
  validates :user_id, presence: true

  before_create :set_default_values

  def bill
    if self.user.bill(amount)
      success
    else
      failed
    end
  end

  def rebuild_amount
    self.amount = 0
    self.billings.each { |b| self.amount += b.amount }
    self.save
  end

  def self.need_processing
    where(active: true).where("(bill_at < ? and failure_count = 0) or (retry_at < ? and failure_count != 0)", Time.now, Time.now).limit(100).pluck(:id)
  end

private
  def set_default_values
    self.bill_at ||= Time.now
  end

  def success
    self.bill_at += self.period
    self.failure_count = 0
    self.save
  end

  def failed
    if failure_count < 3
      self.retry_at = Time.now + 1.day
      self.failure_count += 1
      self.save
    else
      deactivate
    end
  end

  def deactivate
    self.billings.each do |billing|
      billing.failed
    end

    self.active = false
    self.save
  end
end