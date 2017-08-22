raise "Configuration error" unless defined?(SCHEDULERS)

class ScheduleBaseAction < Dummy_Action
  def describe
    "Schedule Base Action"
  end
  def process(m)
    super
    @fromSchedulers = SCHEDULERS.map{ |s| @sender.include?( s )}.include?(true)
    @aboutSchedule = ( @about =~ /.*ρολ.γιο.*ρ.γραμ.*/ )
    @aboutEfimeries = ( @about =~ /.*φημερ.ε.*/ )

    notFoundFiles = [
      "EXCEL.xls",
      "TEACHERS.pdf",
      "TEACHERS_DETAILED.pdf",
      "STUDENTS.pdf",
      "STUDENTS_DETAILED.pdf",
      "ROOMS.pdf",
      "ROOMS_DETAILED.pdf",
      "KATANOMI.xls",
      "roz file (AscTimetables file)"]

    @attachments = []
    m.attachments.each do |a|
      @attachments << a.filename
    end
    

    puts @fromSchedulers
    puts @aboutSchedule
    puts @aboutEfimeries
    p @attachments

    return CONTINUE
  end
end
