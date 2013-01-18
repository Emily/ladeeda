$:.unshift File.dirname(__FILE__)

require 'lib/ladeeda'
require 'json'
require 'sinatra'

ActiveRecord::Base.establish_connection( :adapter => "postgresql",  :host => "localhost", :database => "billing", :pool => 5 )

post "/users" do
  content_type :json
  user = User.new(JSON.parse(request.body.read))

  if user.save
    return {reference: user.id}.to_json
  else
    return 400
  end
end

post "/users/:id/destroy" do
  content_type :json
  user = User.find(params[:id])

  if user
    user.destroy
    return {destroyed: params[:id]}.to_json
  end

  return 400
end

post "/users/:id/billings" do
  content_type :json
  data = JSON.parse(request.body.read)
  user = User.find(params[:id])

  billing_collection = user.billing_collections.where(:period => data["period"]).first
  billing_collection ||= user.billing_collections.create(:period => data["period"])

  billing = billing_collection.billings.new(amount: data["amount"].to_i, callback_url: data["callback_url"], description: data["description"])

  if billing.save
    return {reference: billing.id}.to_json
  else
    return 400
  end
end

post "/users/:user_id/billings/:id/destroy" do
  content_type :json

  user = User.find(params[:user_id])
  billing = user.billings.where(id: params[:id]).first

  if billing
    billing.destroy
    return {destroyed: params[:id]}.to_json
  end

  return 400
end