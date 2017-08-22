class CreateCarPoolsAction < ScheduleBaseAction
  def describe
    "Creating pools of cars using GroupFixer"
  end

  def process(m)
    first_pass = super
    return first_pass if first_pass!=CONTINUE
    return CONTINUE if not @fromSchedulers
    return CONTINUE if not @aboutSchedule and not @aboutEfimeries

    xls_filename = find_and_saveLocal("EXCEL.xls")
    if not xls_filename
      return "Error saving EXCEL.xls"
    end

    xls_filename = File.absolute_path( xls_filename )
    puts xls_filename

    whosin_filename = File.absolute_path( "whosin.db" )
    puts whosin_filename

    groupfixer_base_dir = File.absolute_path ( "../GroupFixer" )
    puts groupfixer_base_dir

    checks = ""
    checks += "EXCEL.xls not found" if not File.exist?( xls_filename )
    checks += "whosin.db not found" if not File.exist?( whosin_filename )
    checks += "GroupFixer directory not found" if not File.exist?( groupfixer_base_dir )
    groupfixer_versions = Dir[ groupfixer_base_dir + "/groupfixer_*" ]
    checks += "No groupfixer versions found" if groupfixer_versions.length==0

    if checks != ""
      puts checks
      return STOP_PROCESSING
    end

    target_base = File.dirname( xls_filename )
    Dir[ "#{target_base}/READY_*.xls" ].each do |t|
      begin
        FileUtils.rm( t )
      rescue
      end
    end

    puts "Calling external script. Its output follows."
    puts "--------------------------------------------"
    groupfixer_versions.each_with_index do |dir,i|
      i+=1
      puts "External script " + i.to_s
      %x{ cd #{dir} && php groupfixer.php #{whosin_filename} #{xls_filename} > #{target_base}/READY_#{i}.xls  }
    end
    puts "--------------------------------------------"
    puts "External script finished."

    results = Dir[ "#{target_base}/READY_*.xls" ]
    msg = "<p><em>"+
      "Τα αρχεία των groups δημιουργήθηκαν επιτυχώς.</em></p>"+
      "<p>Μπορείτε να ρυθμίσετε ποιοί/ες συμμετέχουν στα groups"+
      " χρησιμοποιώντας <br/>"+
      " <a href='http://srv-1tee-moiron.ira.sch.gr:4567'>αυτό το link</a>.</p>"
    Artemis::send_warning_email(m, ["charitakis.ioannis@gmail.com"], msg, results)

    return CONTINUE
  end
end
