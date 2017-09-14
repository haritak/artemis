require 'net/imap'
require 'yaml'

class CheckFreeMem < BasicOneTimeAction

  def initialize
    @settings_fn = "check_free_mem.yml"
    if not File.exists? @settings_fn
      data = 
        { "alarm_limit" => 3,
          "last_available_mem" => 100 }
      File.open(@settings_fn, "w") {|f| f.write(data.to_yaml)}
    end
    @settings = YAML.load(File.open(@settings_fn))
    #puts @settings["alarm_limit"]
    #puts @settings["last_percentage"]
  end

  def describe
    "Check free memory"
  end

  def execute
    super

    free_output = `free -g`

    available_mem = free_output.lines[1].split[-1].to_i

    if available_mem < @settings["alarm_limit"] 
      if @settings["last_available_mem"] > @settings["alarm_limit"]
        Artemis::send_sms( CHECK_QUOTA_ALERT_RECIPIENT, 
                          "Server memory low. #{available_mem}.")

        msg="<p><em>Server available RAM low (#{available_mem})</em></p>"
        Artemis::send_alert_email(CHECK_QUOTA_ALERT_EMAIL, msg)
      end
    end

    @settings["last_available_mem"] = available_mem
    File.open(@settings_fn, "w") {|f| f.write(@settings.to_yaml) }

    return "#{available_mem} G"
  end

end
