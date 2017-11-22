require 'sinatra'
require 'sqlite3'

set :bind, '0.0.0.0'

db = SQLite3::Database.open "whosin.db"

allTeachers={}
def refreshAllTeachers(db, allTeachers)
  allTeachers.clear
  stm = db.prepare "SELECT * FROM teachers"
  rs = stm.execute

  row = rs.next
  while row
    #0:id, 1:name, 2:using_groups, 3:driver
    allTeachers[ row[0] ] = [ row[1], row[2], row[3] ]
    row = rs.next
  end
end

refreshAllTeachers(db, allTeachers)
allTeachers.each do |k,v|
  puts "#{k} - #{v}"
end

get '/' do
  if not params[:password]
    return "Please provide as password 111"
  end
  refreshAllTeachers(db, allTeachers)
  
  toReturn="<ul>"
  allTeachers.each do |i, t|
    toReturn += "<li><a href='/teacher/#{i}'>"
    color = 'red'
    included = 'excluded'
    color = 'green' if t[1]==1
    included = 'included' if t[1]==1
    toReturn += "<font color=#{color}>#{t[0]} is #{included}</font>"
    toReturn += "</a>"

    toReturn += "______ <a href='/teacher/driver/#{i}'>"
    color = 'red'
    included = 'not a driver'
    color = 'green' if t[2]==1
    included = 'a driver' if t[2]==1
    toReturn += "<font color=#{color}>is #{included}</font>"
    toReturn += "</a>"

    toReturn += "</li>"
  end

  toReturn+="</ul>"
  toReturn+="<h2>Following clicks are irreversible.</h2>"
  toReturn+="<ul>"
  allTeachers.each do |i, t|
    toReturn += "<li><a href='/teacher/#{i}/delete'>"
    toReturn += "delete #{t[0]}"
    toReturn += "</a>"
  end
  return toReturn
end

get '/teacher/driver/:teacher_id' do
  t = params[:teacher_id]
  redirect '/?password=111' unless t
  db.execute("UPDATE teachers SET driver=not(driver) where id='#{t}'")
  redirect '/?password=111'
end

get '/teacher/:teacher_id' do
  t = params[:teacher_id]
  redirect '/?password=111' unless t
  db.execute("UPDATE teachers SET using_groups=not(using_groups) where id='#{t}'")
  redirect '/?password=111'
end


get '/teacher/:teacher_id/delete' do
  t = params[:teacher_id]
  redirect '/?password=111' unless t
  db.execute("DELETE FROM teachers where id='#{t}'")
  redirect '/?password=111'
end

