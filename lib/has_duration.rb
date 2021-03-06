#has_duration from http://github.com/nubis/has_duration
#included directly because has_duration gem unnecessarily depends on rails
require 'active_record'

# The DurationValidator checks that a given field has an {ActiveSupport::Duration} or nil
# If you also need presence checks you should use ActiveSupport's built in presence validator.
# @note
#   Although this method is available to you, you should use
#   {HasDuration::ActiveRecordExtension::has_duration} which also adds serialization.
class DurationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a?(ActiveSupport::Duration) || value.nil?
      record.errors[attribute] << 'must be an ActiveSupport::Duration (1.month, 2.years, etc)'
    end
  end
end

module HasDuration
  # The DurationSerializer is a custom ActiveRecord serializer that stores durations in a text
  # field in your model.
  # @note
  #   Although this method is available to you, you should use
  #   {HasDuration::ActiveRecordExtension::has_duration} which also adds validation.
  class DurationSerializer
    def self.dump(duration)
      duration.inspect.gsub(' ','.') if duration.is_a?(ActiveSupport::Duration)
    end

    def self.load(duration)
      return if duration.nil?
      if duration =~ /^(\d{0,10})\.(year|month|week|day|hour|minute|second)s?$/
        $1.to_i.send($2)
      end
    end
  end

  module ActiveRecordExtension
    # Adds a field to your ActiveRecord model that validates and serializes ActiveSupport::Duration objects, like: '1 year', '2 seconds', etc.
    #
    # For example:
    #       class VisitDuration < ActiveRecord::Base
    #         has_duration :doctor
    #         validates :doctor, presence: true
    #         has_duration :club
    #       end
    #
    #       # ruby > durations = VisitDuration.create(doctor: 1.hour, club: 4.hours)
    #       # ruby > Time.now
    #       # => 2012-09-16 12:12:22 -0300
    #       # ruby > durations.doctor.from_now
    #       # => 2012-09-16 13:12:22 -0300
    def has_duration(field_name)
      serialize field_name, DurationSerializer
      validates field_name, duration: true
    end
  end
end

ActiveRecord::Base.send(:extend, HasDuration::ActiveRecordExtension)