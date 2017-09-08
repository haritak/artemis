require 'sinatra'

#
#set port in command line by supplying -p port
#
set :bind, '0.0.0.0'
set :port, 5000

get '/' do
  "<h2>" + "<a href='/wake_hy1'>" + "Wake up lab1" + "</a>" + "</h2>" +
  "<h2>" + "<a href='/wake_hy2'>" + "Wake up lab2" + "</a>" + "</h2>" +
  "<h2>" + "<a href='/wake_hy3'>" + "Wake up lab3" + "</a>" + "</h2>" +
  "<h2>" + "<a href='/wake_hy4'>" + "Wake up lab4" + "</a>" + "</h2>"
  "<h2>" + "<a href='/wake_hy4'>" + "Wake up a2" + "</a>" + "</h2>"
end

get '/wake_hy1' do
  `ssh administrator@10.1.1.220 artemis_helper/wake_hy1.sh`
  redirect '/?message=not_implemented'
end

get '/wake_hy2' do
  `ssh administrator@10.1.1.220 artemis_helper/wake_hy2.sh`
  redirect '/'
end

get '/wake_hy3' do
  `ssh administrator@10.1.1.220 artemis_helper/wake_hy3.sh`
  redirect '/'
end

get '/wake_hy4' do
  `ssh administrator@10.1.1.220 artemis_helper/wake_hy4.sh`
  redirect '/'
end
