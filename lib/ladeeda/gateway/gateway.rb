class Gateway
  CONFIG = YAML::load(File.open(File.join(File.dirname(File.expand_path(__FILE__)), '../../../config/authorize_net.yml')))

  def self.new
    ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
      login: CONFIG["login"],
      password: CONFIG["password"],
      test: true
    )
  end
end