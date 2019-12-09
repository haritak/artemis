class PublishScheduleAction < ScheduleBaseAction

  def describe
    "Publish the schedule"
  end

  def process(m)
    first_pass = super
    
    puts "XXX XXX debugging messages for schedule starts now"

    return first_pass if first_pass!=CONTINUE
    puts "1"
    return CONTINUE if not @fromSchedulers
    puts "2"
    return CONTINUE if not @aboutSchedule and not @aboutEfimeries
    puts "3"

    if @aboutEfimeries and not @aboutSchedule
      return CONTINUE
    end
    puts "4"

    if not @personal
      #we publish the program only if the email was specifically
      #sent to ME.
      return CONTINUE
    end
    puts "5"

    saved_filenames=[]
    if @aboutSchedule
      @attachments_contents.each do |ac|
        saved_filenames << saveLocal( ac )
      end
    end
    puts "6"

    #First figure out directory names
    now = DateTime.now
    next_week = now + 7
    current_year = now.year
    current_week = now.cweek
    next_year = next_week.year
    next_week = next_week.cweek

    pathToNextYear = "#{SCHEDULE_ARCHIVE}/#{next_year}"
    pathToNextWeek = pathToNextYear + "/w#{next_week}"

    puts "7"
    #then create the necessary target directory
    if not File.exist?(pathToNextYear)
      FileUtils.mkdir(pathToNextYear)
    end
    if not File.exist?(pathToNextWeek)
      FileUtils.mkdir(pathToNextWeek)
    end

    puts "8"
    #move the schedule files there
    saved_filenames.each do |f|
      FileUtils.mv("#{f}", pathToNextWeek)
    end
    puts "9"

    #update the links so as to have working links
    #on school webpage
    FileUtils.rm(SCHEDULE_CURRENT_LINK) if File.exist?(SCHEDULE_CURRENT_LINK)
    FileUtils.mv(SCHEDULE_NEXT_LINK, SCHEDULE_CURRENT_LINK) if File.exist?(SCHEDULE_NEXT_LINK)
    FileUtils.ln_s(pathToNextWeek, SCHEDULE_NEXT_LINK)
    FileUtils.cp("helper/index.html", SCHEDULE_NEXT_LINK)
    puts "10"

    msg="<em>Το πρόγραμμα δημοσιεύθηκε.</em>"+
      "<p>Παρακαλώ ελέγξτε ότι οι σύνδεσμοι είναι σωστοί:<br/>"+
      "<a href='http://srv-1tee-moiron.ira.sch.gr/schedule/current'>Τρέχων πρόγραμμα</a><br/>"+
      "<a href='http://srv-1tee-moiron.ira.sch.gr/schedule/next'>Επόμενης εβδομάδας πρόγραμμα</a><br/>"+
      "</p>"
    Artemis::send_email(m, SCHEDULERS, msg)
    puts "11"

    return CONTINUE
  end
end
