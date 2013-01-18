require 'spec_helper'

describe BillingCollection do
  specify "self#need_processing" do
    BillingCollection.transaction do
      BillingCollection.create(user_id: 1, period: 1.month, bill_at: 1.hour.from_now)
      BillingCollection.create(user_id: 1, period: 1.month, bill_at: 1.hour.ago)
      BillingCollection.need_processing.count.should eq(1)

      raise ActiveRecord::Rollback
    end

    BillingCollection.transaction do
      BillingCollection.create(user_id: 1, period: 1.month, bill_at: 1.hour.ago, active: false)
      BillingCollection.create(user_id: 1, period: 1.month, bill_at: 1.hour.ago)
      BillingCollection.create(user_id: 1, period: 1.month, bill_at: 1.hour.ago, failure_count: 1, retry_at: 1.hour.from_now)
      BillingCollection.need_processing.count.should eq(1)

      raise ActiveRecord::Rollback
    end

    BillingCollection.transaction do
      BillingCollection.create(user_id: 1, period: 1.month, bill_at: 1.hour.from_now, failure_count: 0, retry_at: 1.hour.ago)
      BillingCollection.need_processing.count.should eq(0)

      raise ActiveRecord::Rollback
    end
  end

  specify "#success" do
    BillingCollection.transaction do
      time = Time.now
      bc = BillingCollection.create(user_id: 1, period: 1.month, bill_at: time)
      bc.bill_at.should be < Time.now
      bc.send(:success)
      bc.bill_at.should eq(time + 1.month)

      raise ActiveRecord::Rollback
    end
  end

  specify "#failed" do
    BillingCollection.transaction do
      time = Time.now
      bc = BillingCollection.create(user_id: 1, period: 1.month, bill_at: time)
      bc.send(:failed)
      bc.retry_at.should > (Time.now + 1.day - 1.hour)
      bc.retry_at.should < (Time.now + 1.day)
      bc.failure_count.should eq(1)

      raise ActiveRecord::Rollback
    end
  end

  specify "#rebuild_amount" do
    BillingCollection.transaction do
      time = Time.now
      bc = BillingCollection.create(user_id: 1, period: 1.month, bill_at: time)
      bc.billings.create(amount: 100, callback_url: "http://localhost/")
      bc.billings.create(amount: 100, callback_url: "http://localhost/")
      bc.billings.create(amount: 400, callback_url: "http://localhost/")

      bc.reload
      bc.amount.should eq(600)

      raise ActiveRecord::Rollback
    end
  end
end