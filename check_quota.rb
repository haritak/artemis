require 'net/imap'
require 'yaml'

class CheckQuota < BasicOneTimeAction

  def initialize
    @settings_fn = "check_quota.yml"
    if not File.exists? @settings_fn
      data = 
        { "alarm_limit" => 80,
          "last_percentage" => 0 }
      File.open(@settings_fn, "w") {|f| f.write(data.to_yaml)}
    end
    @settings = YAML.load(File.open(@settings_fn))
    #puts @settings["alarm_limit"]
    #puts @settings["last_percentage"]
  end

  def describe
    "Check disk email quota"
  end

  def execute
    super
    imap = Net::IMAP.new("mail.sch.gr")
    imap.authenticate("LOGIN", CHECK_QUOTA_USERNAME, CHECK_QUOTA_PASSWORD)
    a = imap.getquotaroot("INBOX")
    usage = a[1]["usage"]
    quota = a[1]["quota"]
    percentage = ((usage.to_f / quota.to_f)*100)

    alarm = ""
    if percentage > @settings["alarm_limit"] 
      if @settings[last_percentage] < @settings["alarm_limit"]
        Artemis::send_sms( TESTING ?
                          [ CHECK_QUOTA_ALERT_RECIPIENT[0] ] :
                          CHECK_QUOTA_ALERT_RECIPIENT, 
                          "Mail box #{CHECK_QUOTA_USERNAME} almost full.")

        msg="<p><em>Σχεδόν γεμάτο το γραμματοκιβώτιο του #{CHECK_QUOTA_USERNAME}</em></p>"+
          "<p>Παρακαλώ ενημερώστε τον διευθυντή/υποδιευθυντή.</p>"
        Artemis::send_alert_email(TESTING ? [ CHECK_QUOTA_ALERT_EMAIL[0] ] : CHECK_QUOTA_ALERT_EMAIL, msg)
      end
    end

    @settings["last_percentage"] = percentage
    File.open(@settings_fn, "w") {|f| f.write(@settings.to_yaml) }

    return percentage.to_s + alarm
  end

end
