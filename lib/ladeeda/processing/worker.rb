class Worker
  def initialize
    @die_count = 0
  end

  def work
    ActiveRecord::Base.connection_pool.with_connection do
      #TODO: THIS. BETTER.
      while true
        if @die_count == 10
          return
        end
        if do_job
          @die_count = 0
        else
          @die_count += 1
        end
      end
    end
  end

  def do_job
    billing_collections = BillingCollection.need_processing

    billing_collections.each do |id|
      BillingCollection.transaction do
        begin
          bc = BillingCollection.where(id: id).first.lock!("FOR UPDATE NOWAIT")

          if bc.billing_at < Time.now
            bc.bill
            return true
          end
        rescue ActiveRecord::StatementInvalid => e
          raise e if not e.message.include?("obtain lock")
        end
      end
    end

    return false
  end

  def self.spawn_workers(count = 1)
    ActiveRecord::Base.establish_connection( :adapter => "postgresql",  :host => "localhost", :database => "billing_test", :pool => count + 1 )

    @workers = []

    count.times do
      @workers << Thread.new do
        w = Worker.new
        w.work
      end
    end

    @workers.each { |t|  t.join }
  end
end