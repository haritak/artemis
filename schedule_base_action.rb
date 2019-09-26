raise "Configuration error" unless defined?(SCHEDULERS)

class ScheduleBaseAction < Dummy_Action

  EFIMERIES_FILENAME = "efimeries.ods"
  EXCEL_FILENAME = "EXCEL.xls"

  def describe
    "Schedule Base Action"
  end

  def process(m)
    first_pass = super
    return STOP_PROCESSING if first_pass == STOP_PROCESSING 

    @fromSchedulers = SCHEDULERS.map{ |s| @sender.include?( s )}.include?(true)
    @aboutSchedule = ( @subject =~ /.*ρολ.γιο.*ρ.γραμ.*/i )
    @aboutEfimeries = ( @subject =~ /.*φημερ.ε.*/i )

    find_required_schedule_files(m)
    p @foundScheduleFiles
    p @notFoundScheduleFiles

    find_required_efimeries_files(m)
    p @foundEfimeriesFiles
    p @notFoundEfimeriesFiles

    if @fromSchedulers

      notFoundList = []
      notFoundList = @notFoundScheduleFiles if @aboutSchedule and @notFoundScheduleFiles.length>0
      notFoundList = @notFoundEfimeriesFiles if @aboutEfimeries and @notFoundEfimeriesFiles.length>0

      if notFoundList.length>0
        warning = 
          "<p>Λείπουν τα αρχεία:</p>" +
          "<ul>" +
          "<li>#{notFoundList.join('</li><li>')}</li>"+
          "</ul>"+
          "<p><strong>Ξαναστείλτε το email συμπεριλαμβάνοντας τα παραπάνω αρχεία.</strong></p>"
        Artemis::send_email(m, SCHEDULERS, warning) #TODO should inform everyone SCHEDULERS

        return STOP_PROCESSING
      end
    end

    puts "Done processing email:"
    puts @fromSchedulers
    puts @aboutSchedule
    puts @aboutEfimeries
    p @attachments

    return CONTINUE
  end



  private

  def find_required_schedule_files(m)
    @notFoundScheduleFiles = [
      "EXCEL.xls",
      "TEACHERS.pdf",
      "TEACHERS_DETAILED.pdf",
      "STUDENTS.pdf",
      "STUDENTS_DETAILED.pdf",
      "ROOMS.pdf",
      "ROOMS_DETAILED.pdf",
      "KATANOMI.xls",
      "roz"]

    @foundScheduleFiles = @notFoundScheduleFiles.select { |fn| @attachments.include?( fn ) }
    @notFoundScheduleFiles = @notFoundScheduleFiles - @foundScheduleFiles
    rozFile = @attachments.select { |fn| fn =~ /.*\.roz/ }
    if rozFile and rozFile.length>0 
      @notFoundScheduleFiles -= ["roz"]
      @foundScheduleFiles << rozFile[0]
    end

    if @foundScheduleFiles.length>6 and not @aboutSchedule
      puts "Warning! This seems to be an email about schedule."
      puts "However, it was not detected as such."
      puts "This is it's subject: #{@subject}"
      @aboutSchedule = true
    end
  end

  def find_required_efimeries_files(m)
    @notFoundEfimeriesFiles = [EFIMERIES_FILENAME]
    @foundEfimeriesFiles = []
    @notFoundEfimeriesFiles.each do |f|
      if @attachments.include?(f)
        @foundEfimeriesFiles << f
      end
    end
    @notFoundEfimeriesFiles -= @foundEfimeriesFiles

    if @foundEfimeriesFiles.length==1 and not @aboutEfimeries
      puts "Warning! This seems to be an email about efimeries."
      puts "However, it was not detected as such."
      puts "This is it's subject: #{@subject}"
      @aboutEfimeries = true
    end
  end

end
