load "../efimeries_parser.rb"

ep = EfimeriesParser.new "efimeries.ods"
puts ep.parse
