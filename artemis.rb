#
#https://github.com/mikel/mail
#
require 'mail'
load "forbidden"

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

mail_actions = []

load "dummy_action.rb"
mail_actions << Dummy_Action.new

load "sensitive_list.rb"
mail_actions << MonitorSensitiveList.new

puts "Starting email processing on"
now = DateTime.now
puts "#{now.year}/#{now.month}/#{now.day} (w#{now.cweek}), #{now.hour}:#{now.minute}"

Mail.all.each do |m|

  mail_actions.each do |ma|
    ma.describe
    break if ma.process( m )
  end

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
