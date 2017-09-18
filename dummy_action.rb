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

    @attachments = []
    @attachments_contents = []
    m.attachments.each do |a|
      @attachments << a.filename
      @attachments_contents << a
    end

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

  def saveLocal(attachment)
    filename = attachment.filename
    FileUtils.mkdir("tmp") if not File.exist?("tmp/")
    FileUtils.rm("tmp/#{filename}") if File.exist?("tmp/#{filename}")
    filename = "tmp/#{filename}"
    File.open(filename, "w+b", 0644) do |f| 
      f.write attachment.body.decoded
    end
    return filename
  end

  def findLocal(filename)
    filename = "tmp/#{filename}"
    return nil if not File.exist?( filename )
    filename
  end

  def find_and_saveLocal(filename)
    idx = @attachments.index( filename )
    return saveLocal( @attachments_contents[idx] ) if idx 
    return nil
  end
end
