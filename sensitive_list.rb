SENSITIVELIST = "1epal-moiron-sensitive-emails"

require 'http'
require 'json'
require 'uri'

SKIP_SMSES = true

class MonitorSensitiveList < Dummy_Action

  def initialize
    #acquire api key
    url = "https://easysms.gr/api/key/get?"+
      URI.encode_www_form("username"=>SMS_USERNAME,
                          "password"=>SMS_PASSWORD,
                          "type"=>"json")
    resp = HTTP.get url
    rj = JSON.parse resp.body

    if rj["error"] != "0" 
      puts "Failed to get sms api key"
      puts resp.body
      @balance = 0
      return
    end

    @api_key = rj["key"]
    if not @api_key
      puts "Failed to obtain api_key"
      @balance = 0
      return
    end

    #get balance
    #
    resp = HTTP.get "https://easysms.gr/api/balance/get?"+
      URI.encode_www_form("key"=>@api_key,"type"=>"json")
    rj = JSON.parse resp.body
    @balance = rj["balance"].to_i
    puts resp.body
  end

  def describe
    "MonitorSensitiveList #{@balance} smses left"
  end

  def process(m)
    super
    return CONTINUE unless @sender.include?(SENSITIVELIST)

    puts "SENSITIVE!"

    #inform through smses
    if @balance > 100 and not SKIP_SMSES
      SENSITIVE_SMS_RECIPIENTS.each do |tel|
        send_sms(tel, "Γειά !")
      end
    else
      puts "Skipping smses or balance(#{@balance}) not enough or other error."
    end

    SENSITIVE_EMAIL_RECIPIENTS.each do |email|
      puts "Will send an email to #{email}"
    end

    return STOP_PROCESSING
  end

  private 

  def send_sms(tel, msg)
    url = "https://easysms.gr/api/sms/send?"+
    URI.encode_www_form("key"=>@api_key, "from"=>"Artemis", "to"=>tel, "text"=>msg, "type"=>"json")
    resp = HTTP.get url
    rj = JSON.parse resp.body
    @balance = rj["balance"].to_i
    puts "New balance is #{@balance}"
  end

end
