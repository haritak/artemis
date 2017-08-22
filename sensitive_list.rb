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
    return CONTINUE unless @sender.include?(SENSITIVELIST)

    puts "SENSITIVE!"

    #inform through smses
    if @balance > 100 and not SKIP_SMSES
      SENSITIVE_SMS_RECIPIENTS.each do |tel|
        Artemis::send_sms(tel, "Γειά !")
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

end
