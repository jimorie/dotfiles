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
FZF_SCRIPT=~/bin/fzf-tmux
FZF_COMMAND="$FZF_SCRIPT -b$HEIGHT --delimiter=: --with-nth=6 --scheme=history --no-hscroll --cycle --color=16,border:241,bg:-1,bg+:-1"

# DO NOT CHANGE BELOW

# Tmux windows meta data
TARGET_SPEC="#{?window_active,0,1}:#{window_activity}:#{session_name}:#{window_id}:#{pane_id}:"

# Prevent multiple launchers
if tmux show-environment IN_TMUX_LAUNCHER > /dev/null; then
	tmux display-message "One tmux-launcher is enough!"
	exit 0
fi

tmux set-environment IN_TMUX_LAUNCHER 1

# Remember current layout
layout=$(tmux display-message -p "#{window_layout}")
zoomed=$(tmux display-message -p "#{window_zoomed_flag}")

# Run FZF
selected=$((tmux list-windows -F "$TARGET_SPEC$LIST_DATA" | sort -r;find ${PROJECTS[@]} -mindepth 1 -maxdepth 1 -type d -not -name '.*'|awk '{n=split($0,a,"/");printf "@:%s:%s:@:@:   📁 %-40s %s\n", a[n], $0, a[n], $0}') | $FZF_COMMAND)

exitcode=$?

# Clear is running flag
tmux set-environment -u IN_TMUX_LAUNCHER

# Restore previous layout (Tmux full width option can screw it up)
newlayout=$(tmux display-message -p "#{window_layout}")
if [[ "$newlayout" != "$layout" ]]; then
	tmux select-layout "$layout"
	if [[ $zoomed -gt 0 ]]; then
		tmux resize-pane -Z
	fi
fi

# Abort if FZF didn't exit cleanly
if [[ $exitcode -gt 0 ]]; then
	exit 0
fi

# Get the selected args
IFS=':'
args=($selected)
unset IFS

if [[ ${args[0]} == "@" ]]; then
	# Directory selected
	tmux new-window -c "${args[2]}" -n "${args[1]}"
else
	# Tmux window selected
	tmux select-window -t ${args[3]} && tmux switch-client -t ${args[2]}
fi
