#!/bin/bash

# Project directories to search
PROJECTS[0]=~/opsview
PROJECTS[1]=~/projects
PROJECTS[2]=~

# Formatting of Tmux windows
LIST_DATA="#{p-2:window_index} 🖥  #{p40:window_name} #{pane_current_path}"

# Height of FZF pane
HEIGHT=15

# FZF command options
FZF_COMMAND="fzf-tmux -b$HEIGHT --delimiter=: --with-nth=6 --scheme=history --no-hscroll --cycle --color=16,border:241"

# DO NOT CHANGE BELOW

# Tmux windows meta data
TARGET_SPEC="#{?window_active,0,1}:#{window_activity}:#{session_name}:#{window_id}:#{pane_id}:"

# Remember current layout
layout=$(tmux display-message -p "#{window_layout}")

if [[ "$layout" =~ x$HEIGHT,0,[0-9]+,[0-9]+\]$ ]]; then
	exit 0
fi

# Run FZF
selected=$((tmux list-windows -F "$TARGET_SPEC$LIST_DATA" | sort -r;find ${PROJECTS[@]} -mindepth 1 -maxdepth 1 -type d -not -name '.*'|awk '{n=split($0,a,"/");printf "@:@:@:@:@:   📁 %-40s %s\n", a[n], $0}')| $FZF_COMMAND)

exitcode=$?

# Restore previous layout (Tmux full width option can screw it up)
tmux select-layout "$layout"

if [[ $exitcode -gt 0 ]]; then
	exit 0
fi

# Get the selected args
args=(${selected//:/ })

if [[ ${args[0]} == "@" ]]; then
	# Directory selected
	tmux new-window -c ${args[7]} -n ${args[6]}
else
	# Tmux window selected
	tmux select-window -t ${args[3]} && tmux switch-client -t ${args[2]}
fi
