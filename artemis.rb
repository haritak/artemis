#
#https://github.com/mikel/mail
#
require 'mail'
load "forbidden"

#actions. 
#Order is important
load "dummy_action.rb"
load "sensitive_list.rb"
load "schedule_base_action.rb"
load "update_groups_db.rb"

raise "Configuration error, check TESTING" unless defined?(TESTING)
raise "Configuration error, check USERNAME" unless defined?(USERNAME)
raise "Configuration error, check PASSWORD" unless defined?(PASSWORD)
raise "Configuration error, check DONTDELETEMAILS" unless defined?(DONTDELETEMAILS)

ME = USERNAME

Mail.defaults do
  retriever_method :imap, 
    :address    => "imap.googlemail.com",
    :port       => 993,
    :user_name  => USERNAME,
    :password   => PASSWORD,
    :enable_ssl => true

  delivery_method(:smtp, 
                  address: "smtp.gmail.com", 
                  port: 587, 
                  user_name: USERNAME,
                  password: PASSWORD,
                  authentication: 'plain',
                  enable_starttls_auto: true)
end

#each mail action is executed in turn by calling the process method
#if a process method returns true, no more actions are executed for 
#the current email.
#
mail_actions = []
mail_actions << MonitorSensitiveList.new
mail_actions << UpdateScheduleGroupsAction.new

puts "Starting email processing on"
now = DateTime.now
puts "#{now.year}/#{now.month}/#{now.day} (w#{now.cweek}), #{now.hour}:#{now.minute}"

Mail.all.each_with_index do |m,i|

  puts "============ #{i} =============="

  mail_actions.each do |ma|
    puts "--- #{ma.describe} ---"
    break if ma.process( m ) == Dummy_Action::STOP_PROCESSING
  end

  puts "============================"

end

puts "Email process ended"
now = DateTime.now
puts "#{now.year}/#{now.month}/#{now.day} (w#{now.cweek}), #{now.hour}:#{now.minute}"
if not DONTDELETEMAILS
  puts "Deleting emails"
  Mail.find_and_delete
else
  puts "Keeping all emails"
end

puts "Bye!"
