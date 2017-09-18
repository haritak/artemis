class ReCreateCarPoolsAction < Dummy_Action
  def describe
    "Recreating car pools"
  end

  def process(m)
    first_pass = super
    return first_pass if first_pass!=CONTINUE

    recreate_groups_command = ( @subject =~ /.*regroup.*/ )
    return CONTINUE if not recreate_groups_command 

    xls_filename = 
      ScheduleBaseAction.findLocal( ScheduleBaseAction::EXCEL_FILENAME )
    return "FAILED to find previous EXCEL.xls" if not xls_filename

    xls_filename = File.absolute_path( xls_filename )

    whosin_filename = File.absolute_path( "whosin.db" )
    return "FAILED to find whosin.db" if not whosin_filename

    groupfixer_base_dir = File.absolute_path ( "../GroupFixer" )
    return "FAILED to find groupfixer_base_dir" if not groupfixer_base_dir

    groupfixer_versions = Dir[ groupfixer_base_dir + "/groupfixer_*" ]

    puts "Calling external script. Its output follows."
    puts "--------------------------------------------"
    groupfixer_versions.each_with_index do |dir,i|
      i+=1
      puts "External script " + i.to_s
      %x{ cd #{dir} && php groupfixer.php #{whosin_filename} #{xls_filename} > #{target_base}/READY#{dir[-2..-1]}.xls  }
    end
    puts "--------------------------------------------"
    puts "External script finished."

    results = Dir[ "#{target_base}/READY_*.xls" ]
    msg = "<p><em>"+
      "Τα αρχεία των groups δημιουργήθηκαν επιτυχώς.</em></p>"+
      "<p>Μπορείτε να ρυθμίσετε ποιοί/ες συμμετέχουν στα groups"+
      " χρησιμοποιώντας <br/>"+
      " <a href='http://srv-1tee-moiron.ira.sch.gr:4567'>αυτό το link</a>.</p>"
    Artemis::send_email(m, SCHEDULERS, msg, results)

    return CONTINUE
  end
end
