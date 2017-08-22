require "sqlite3"

load "efimeries_parser.rb"

class UpdateScheduleGroupsAction < ScheduleBaseAction

  def initialize
    FileUtils.touch('emails.db')
    db = SQLite3::Database.open "emails.db"
    db.execute "CREATE TABLE IF NOT EXISTS " +
      "teachers(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, email TEXT)"
    db.close


    FileUtils.touch('whosin.db')
    db = SQLite3::Database.open "whosin.db"
    db.execute "CREATE TABLE IF NOT EXISTS "+
      "teachers(id INTEGER PRIMARY KEY AUTOINCREMENT, timetables_name TEXT UNIQUE, using_groups TINYINT)"
    db.close

    begin
      FileUtils.ln_s('../whosin.db', 'helper/whosin.db')
    rescue
    end
  end

  def describe
    "Updating schedule related databases"
  end

  def process(m)
    first_pass = super
    return first_pass if first_pass!=CONTINUE
    return CONTINUE if not @fromSchedulers
    return CONTINUE if not @aboutSchedule and not @aboutEfimeries

    # at this point:
    # the email has been checked against attachments
    # has been sent by the schedulers
    # and it is about the schedule or efimeries
    #
    if @aboutSchedule
      return process_schedule(m)
    else
      return process_efimeries(m)
    end
  end

  private

  def process_schedule(m)
    filename = find_and_saveLocal( EXCEL_FILENAME )

    %x{ cd helper && php update_whosin.php #{"../"+filename} }

    return CONTINUE
  end

  def process_efimeries(m)
    filename = find_and_saveLocal( EFIMERIES_FILENAME )

    parser = EfimeriesParser.new filename
    parser.beSilent

    result = parser.parse
    if result != "OK"
      m = "Error while parsing: " + result
      Artemis::send_warning_email(m, ['charitakis.ioannis@gmail.com'], warning) #TODO should inform everyone SCHEDULERS
      return STOP_PROCESSING
    end

    db = SQLite3::Database.open "emails.db"
    parser.each_teacher do |t|
      t.strip!
      sql = "SELECT * FROM teachers WHERE name LIKE '%#{t}%' "
      stm = db.prepare sql
      rs = stm.execute
      if not row=rs.next
        db.execute "INSERT INTO teachers VALUES(NULL, '#{t}','')"
      end
      stm.close
    end
    db.close

    return CONTINUE
  end

end
