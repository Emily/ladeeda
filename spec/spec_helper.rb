$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'ladeeda'
ActiveRecord::Base.establish_connection( :adapter => "postgresql",  :host => "localhost", :database => "billing_test", :pool => 5 )
