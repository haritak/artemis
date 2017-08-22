class Dummy_Action

  STOP_PROCESSING = "Do not process this email more."
  CONTINUE = "OK" #No harm if you continue processing this email"

  def describe
    "Dummy_Action: Email stuff"
  end

  def process(m)
    @sender = m.from ?  m.from.join : m.from
    @recipients = "#{m.to ? m.to.join : ''} #{m.cc ? m.cc.join : '' } #{m.bcc ? m.bcc.join : ''}"
    @personal = @recipients.include?(Artemis::ME)
    @subject = m.subject
    @mail = m

    puts "From #{@sender}"
    puts "To #{@recipients}"
    puts "(PERSONAL!)" if @personal
    puts "About: #{@subject}"
    puts

    if @sender.include?(Artemis::ME)
      puts "Warning, this email was send by me and is being processed by me!"
      return STOP_PROCESSING
    end

    return CONTINUE
  end
end
