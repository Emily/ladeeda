$:.unshift File.dirname(__FILE__)

require 'pg'
require 'active_record'
require 'has_duration'
require 'activemerchant'
require 'logger'
require 'yaml'

module Ladeeda
  # def self.logger
  #   if not @logger
  #     @logger = Logger.new('log/billing.log')
  #     @logger.formatter = proc { |severity, datetime, progname, msg|
  #       "#{msg}\n"
  #     }
  #   end

  #   @logger
  # end

end

require 'ladeeda/gateway/gateway'
require 'ladeeda/models'
require 'ladeeda/processing/worker'