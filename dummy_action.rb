class Dummy_Action

  STOP_PROCESSING = "No need to process this email more"
  CONTINUE = "No harm if you continue processing this email"

  def describe
    "Dummy_Action: Email stuff"
  end

  def process(m)
    @sender = m.from ?  m.from.join : m.from
    @recipients = "#{m.to ? m.to.join : ''} #{m.cc ? m.cc.join : '' } #{m.bcc ? m.bcc.join : ''}"
    @personal = @recipients.include?(ME)
    @subject = m.subject
    @mail = m

    puts "From #{@sender}"
    puts "To #{@recipients}"
    puts "(PERSONAL!)" if @personal
    puts "About: #{@subject}"
    puts

    return CONTINUE
  end
end
