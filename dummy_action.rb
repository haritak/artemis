class Dummy_Action

  def describe
    puts "Dummy_Action: Email stuff"
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

    return false #keep parsing this email
  end
end
