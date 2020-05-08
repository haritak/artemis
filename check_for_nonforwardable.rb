require 'net/imap'
require 'yaml'

class CheckForNonForwardable < BasicOneTimeAction

#emails from minedu.gov.gr are not forwardable
#see deltio texnikis ypostiriksis me arithmo 395820 apo 1epal-moiron

  def initialize
    @settings_fn = "check_for_nonforwardable.yml"
    if not File.exists? @settings_fn
      data = 
        { "last_non_forwardable" => 0 }
      File.open(@settings_fn, "w") {|f| f.write(data.to_yaml)}
    end
    @settings = YAML.load(File.open(@settings_fn))
  end

  def describe
    "Check for non forwardable emails"
  end

  def execute
    super
    imap = Net::IMAP.new("mail.sch.gr", open_timeout: 5)
    imap.authenticate("LOGIN", CHECK_QUOTA_USERNAME, CHECK_QUOTA_PASSWORD)
    imap.select("INBOX")
    emails = imap.search(["FROM", "minedu.gov.gr"])
    alarm = ""
    if emails.size != @settings["last_non_forwardable"]
        p "Emails that need to be manually forwarded = #{emails.size}"
        msg = ""
        emails.each do |message_id|
            m = imap.fetch( message_id, "ENVELOPE")[0].attr["ENVELOPE"]
            p m.subject
            msg += m.subject + "<br>\n"
            p m.from
            msg += m.from.to_s + "<br>\n"
            msg += "<br><br>\n\n\n"
        end
	Artemis::send_alert_email(SENSITIVE_EMAIL_RECIPIENTS, "Υπάρχουν #{emails.size} που δεν προωθούνται αυτόματα.<br><br>\n\n"+msg)
	@settings["last_non_forwardable"] = emails.size
	File.open(@settings_fn, "w") {|f| f.write(@settings.to_yaml) }
     end

    return alarm + emails.size.to_s
  end

end
