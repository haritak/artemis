class PublishScheduleAction < ScheduleBaseAction

  def describe
    "Publish the schedule"
  end

  def process(m)
    first_pass = super

    return first_pass if first_pass!=CONTINUE
    return CONTINUE if not @fromSchedulers
    return CONTINUE if not @aboutSchedule and not @aboutEfimeries

    if @aboutEfimeries and not @aboutSchedule
      return CONTINUE
    end

    if not @personal
      #we publish the program only if the email was specifically
      #sent to ME.
      return CONTINUE
    end

    saved_filenames=[]
    if @aboutSchedule
      @attachments_contents.each do |ac|
        saved_filenames << saveLocal( ac )
      end
    end

    #First figure out directory names
    now = DateTime.now
    next_week = now + 7
    current_year = now.year
    current_week = now.cweek
    next_year = next_week.year
    next_week = next_week.cweek

    pathToNextYear = "#{SCHEDULE_ARCHIVE}/#{next_year}"
    pathToNextWeek = pathToNextYear + "/w#{next_week}"

    #then create the necessary target directory
    if not File.exist?(pathToNextYear)
      FileUtils.mkdir(pathToNextYear)
    end
    if not File.exist?(pathToNextWeek)
      FileUtils.mkdir(pathToNextWeek)
    end

    #move the schedule files there
    saved_filenames.each do |f|
      FileUtils.mv("#{f}", pathToNextWeek)
    end

    #update the links so as to have working links
    #on school webpage
    FileUtils.rm(SCHEDULE_CURRENT_LINK) if File.exist?(SCHEDULE_CURRENT_LINK)
    FileUtils.mv(SCHEDULE_NEXT_LINK, SCHEDULE_CURRENT_LINK) if File.exist?(SCHEDULE_NEXT_LINK)
    FileUtils.ln_s(pathToNextWeek, SCHEDULE_NEXT_LINK)
    FileUtils.cp("helper/index.html", SCHEDULE_NEXT_LINK)

    msg="<em>Το πρόγραμμα δημοσιεύθηκε.</em>"+
      "<p>Παρακαλώ ελέγξτε ότι οι σύνδεσμοι είναι σωστοί:<br/>"+
      "<a href='http://srv-1tee-moiron.ira.sch.gr/schedule/current'>Τρέχων πρόγραμμα</a><br/>"+
      "<a href='http://srv-1tee-moiron.ira.sch.gr/schedule/next'>Επόμενης εβδομάδας πρόγραμμα</a><br/>"+
      "</p>"
    Artemis::send_email(m, TESTING ? [ SCHEDULERS[0] ] : SCHEDULERS, msg)

    return CONTINUE
  end
end
