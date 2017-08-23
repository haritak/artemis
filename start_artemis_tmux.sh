#!/bin/sh
tmux new-session -s artemis -d
tmux send-keys -t artemis 'cd /home/administrator/artemis' C-m
tmux send-keys -t artemis 'ruby sinatra_whosin.rb' C-m
tmux new-window -t artemis
tmux send-keys -t artemis 'cd /home/administrator/artemis' C-m
tmux send-keys -t artemis 'while true; do ruby artemis.rb ; done' C-m
tmux new-window -t artemis
tmux send-keys -t artemis 'cd /home/administrator/artemis' C-m
tmux send-keys -t artemis 'ruby processEmails.rb' C-m
