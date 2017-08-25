#
#https://github.com/mikel/mail
#
require 'mail'
require 'http'
require 'json'
require 'uri'
load "forbidden"

#one time actions
load "basic_one_time_action.rb"
load "check_quota.rb"

#email actions. 
#Order is important
load "dummy_action.rb"
load "sensitive_list.rb"
load "schedule_base_action.rb"
load "update_groups_db.rb"
load "create_carpools_action.rb"
load "publish_schedule_action.rb"


raise "Configuration error, check TESTING" unless defined?(TESTING)
raise "Configuration error, check USERNAME" unless defined?(USERNAME)
raise "Configuration error, check PASSWORD" unless defined?(PASSWORD)
raise "Configuration error, check DONTDELETEMAILS" unless defined?(DONTDELETEMAILS)

class Artemis

  ME = USERNAME
  
  def initialize

    initialize_email
    initialize_sms

    #one time actions are executed at the start
    #Then the email processing follows
    @one_time_actions = []
    @one_time_actions << CheckQuota.new

    #each mail action is executed in turn by calling the process method
    #if a process method returns true, no more actions are executed for 
    #the current email.
    #
    @mail_actions = []
    @mail_actions << MonitorSensitiveList.new
    @mail_actions << UpdateScheduleGroupsAction.new
    @mail_actions << CreateCarPoolsAction.new
    @mail_actions << PublishScheduleAction.new
  end

  def start_processing

    puts "Starting one time actions"
    @one_time_actions.each do |a|
      result = a.execute()
      puts "--- #{a.describe} return #{result}"
    end

    puts "Starting email processing on"
    now = DateTime.now
    puts "#{now.year}/#{now.month}/#{now.day} (w#{now.cweek}), #{now.hour}:#{now.minute}"

    Mail.all.each_with_index do |m,i|

      puts "============ #{i} =============="

      @mail_actions.each do |ma|
        result = ma.process( m )
        puts "--- #{ma.describe} returned #{result}"
        #TODO: if result unusual then send an email
        break if result == Dummy_Action::STOP_PROCESSING
      end

      puts "============================"

    end

    puts "Email process ended"
    now = DateTime.now
    puts "#{now.year}/#{now.month}/#{now.day} (w#{now.cweek}), #{now.hour}:#{now.minute}"
    if not DONTDELETEMAILS
      puts "Deleting emails"
      Mail.find_and_delete
    else
      puts "Keeping all emails"
    end
  end

  def self.send_email(trigering_email, recipients, text, attachments=nil)
    Mail.deliver do
      charset = "UTF-8"
      content_transfer_encoding="8bit"
      from "Άρτεμις <#{ME}>"
      to recipients.join(",")
      if attachments
        attachments.each do |f|
          add_file f
        end
      end
      now = DateTime.now
      subject "Ενημέρωση #{now.day}/#{now.month}/#{now.year} #{now.hour}:#{now.minute}.#{now.second}"
      html_part do
        content_type "text/html; charset=utf-8"
        body "<p>Γειά σας,</p>"+
          "<p>Πολύ πρόσφατα έλαβα ένα email με τίτλο:</p>"+
          "<strong>#{trigering_email.subject}</strong><br/>"+
          "<br/>"+
          "το οποίο έχει σταλεί:<br/>"+
          "από: #{trigering_email.from}<br/>"+
          "προς: #{trigering_email.to}<br/>"+
          "cc: #{trigering_email.cc}<br/>"+
          ""+
          "<p>Κατά ή μετά την επεξεργασία του email προέκυψε το μήνυμα:<br/>"+
          "=========================================================</p>"+
          "#{text}"+
          "<p>=========================================================</p>"+
          ""+
          "<p>Να είστε καλά,</p>"+
          "<p><em>Άρτεμις</em></p>"+
          "<p><small>υγ: Το email περιλαμβάνει στους παραλήπτες όλους όσους"+
          "ασχολούνται με το ωρολόγιο πρόγραμμα ή/και τις εφημερίες.</small></p>"
      end
    end
  end

  def self.get_sms_balance
    return @@balance
  end

  def self.send_sms(phones, msg)
    return if SKIP_SMSES

    return if @@balance < 100 #TODO : make a one time action to check for that number

    phones.each do |tel|
      url = "https://easysms.gr/api/sms/send?"+
        URI.encode_www_form("key"=>@@api_key,
                            "from"=>"Artemis", 
                            "to"=>tel, 
                            "text"=>msg,
                            "type"=>"json")
      resp = HTTP.get url
      rj = JSON.parse resp.body
      @@balance = rj["balance"].to_i
      puts "New balance is #{@@balance}"
    end
  end


  private

  def initialize_email
    Mail.defaults do
      retriever_method :imap, 
        :address    => "imap.googlemail.com",
        :port       => 993,
        :user_name  => USERNAME,
        :password   => PASSWORD,
        :enable_ssl => true

      delivery_method(:smtp, 
                      address: "smtp.gmail.com", 
                      port: 587, 
                      user_name: USERNAME,
                      password: PASSWORD,
                      authentication: 'plain',
                      enable_starttls_auto: true)
    end
  end

  def initialize_sms

    if SKIP_SMSES
      puts "Skipping SMSes"
    end

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
      @@balance = 0
      return
    end

    @@api_key = rj["key"]
    if not @@api_key
      puts "Failed to obtain api_key"
      @@balance = 0
      return
    end

    #get balance
    #
    resp = HTTP.get "https://easysms.gr/api/balance/get?"+
      URI.encode_www_form("key"=>@@api_key,"type"=>"json")
    rj = JSON.parse resp.body
    @@balance = rj["balance"].to_i
    puts resp.body
  end
end


artemis = Artemis.new
artemis.start_processing

puts "Bye!"


waitTime = 400 + rand(900)
puts "Will wait for #{waitTime} seconds before quiting for good."
sleep waitTime
