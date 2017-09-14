require 'net/imap'
require 'yaml'

class CheckFreeDisk < BasicOneTimeAction

  def initialize
    @settings_fn = "check_free_disk.yml"
    if not File.exists? @settings_fn
      data = 
        { "alarm_limit" => 60,
          "last_available" => 400 }
      File.open(@settings_fn, "w") {|f| f.write(data.to_yaml)}
    end
    @settings = YAML.load(File.open(@settings_fn))
    #puts @settings["alarm_limit"]
    #puts @settings["last_percentage"]
  end

  def describe
    "Check free disk space"
  end

  def execute
    super

    free_output = `df -h /`

    available = free_output.lines[1].split[-3][0...-1].to_i

    if available < @settings["alarm_limit"] 
      if @settings["last_available"] > @settings["alarm_limit"]
        Artemis::send_sms( CHECK_QUOTA_ALERT_RECIPIENT, 
                          "Server disk space low. #{available}.")

        msg="<p><em>Server available disk space low (#{available}G)</em></p>"
        Artemis::send_alert_email(CHECK_QUOTA_ALERT_EMAIL, msg)
      end
    end

    @settings["last_available"] = available
    File.open(@settings_fn, "w") {|f| f.write(@settings.to_yaml) }

    return "#{available}G"
  end

end
