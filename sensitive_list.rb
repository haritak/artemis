SENSITIVELIST = "1epal-moiron-sensitive-emails"



class MonitorSensitiveList < Dummy_Action

  def initialize
    @balance = Artemis::get_sms_balance
  end

  def describe
    "MonitorSensitiveList #{@balance} smses left"
  end

  def process(m)
    first_pass = super
    return STOP_PROCESSING if first_pass == STOP_PROCESSING

    isSensitive = false

    isSensitive = true if @sender.include?(SENSITIVELIST)
    isSensitive = true if @subject =~ /ΕΠΑΛ Ευαίσθητο/

    return CONTINUE if not isSensitive

    puts "SENSITIVE!"

    #inform through smses
    if @balance > 100 and not SKIP_SMSES
      SENSITIVE_SMS_RECIPIENTS.each do |tel|
        Artemis::send_sms(tel, "Sensitive email arrived. Please inform accordingly.")
      end
    else
      puts "Skipping smses or balance(#{@balance}) not enough or other error."
    end

    msg="<p><em>Κάποιο μήνυμα περιμένει στην λίστα των ευαίσθητων</em></p>"+
      "<p>Παρακαλώ ενημερώστε τον διευθυντή/υποδιευθυντή.</p>"+
      "<p><small>Sms balance: #{@balance}.</small></p>"
    Artemis::send_email(m, TESTING ? [ SCHEDULERS[0] ] : SCHEDULERS, msg)

    return STOP_PROCESSING
  end

  private 

end
