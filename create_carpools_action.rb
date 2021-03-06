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
      puts "External script " + i.to_s + " working with #{dir}"
      %x{ cd #{dir} && php groupfixer.php #{whosin_filename} #{xls_filename} > #{target_base}/READY#{dir[dir.index("_")..-1]}.xls  }
      puts "executing: { cd #{dir} && php groupfixer.php #{whosin_filename} #{xls_filename} > #{target_base}/READY#{dir[dir.index("_")..-1]}.xls  }"
    end
    puts "--------------------------------------------"
    puts "External script finished."

    results = Dir[ "#{target_base}/READY*.xls" ]
    msg = "<p><em>"+
      "Τα αρχεία των groups δημιουργήθηκαν επιτυχώς.</em></p>"+
      "<p>Μπορείτε να ρυθμίσετε ποιοί/ες συμμετέχουν στα groups"+
      " χρησιμοποιώντας <br/>"+
      " <a href='http://srv-1tee-moiron.ira.sch.gr:4567/?password=111'>αυτό το link</a>.<br/>" +
      "Σε περίπτωση που κάνετε αλλαγές στην σύνθεση των group, στείλτε μου ένα email<br/>" +
      "με θέμα : regroup και μοναδικό συνημμένο το αρχείο EXCEL.xls του τελευταίου προγράμματος.</p>"
    Artemis::send_email(m, SCHEDULERS, msg, results)

    return CONTINUE
  end
end
