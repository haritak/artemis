load "../efimeries_parser.rb"

ep = EfimeriesParser.new "efimeries.ods"
result = ep.parse 

if result=="OK"
  puts "All OK"
  ep.each_teacher do |t|
    puts t
  end
else
  puts "Something happed!"
  print result
end
