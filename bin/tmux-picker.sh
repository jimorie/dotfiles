#!/bin/bash

# customizable
LIST_DATA="🖥  #{p-2:window_index} #{p38:window_name} #{pane_current_path}"
FZF_COMMAND="fzf-tmux -p --delimiter=: --with-nth 4 --color=hl:2 --scheme=history --border-label=Goto --prompt="

# do not change
TARGET_SPEC="#{session_name}:#{window_id}:#{pane_id}:"

# select pane
LINE=$((tmux list-windows -a -F "$TARGET_SPEC$LIST_DATA";find ~/opsview ~/Projects ~ -not -name '.*' -type d -mindepth 1 -maxdepth 1|awk '{n=split($0,a,"/");printf ":::📁  %-40s %s\n", a[n], $0}')| $FZF_COMMAND) || exit 0
# split the result
args=(${LINE//:/ })
if [[ ${args[0]} == "📁" ]]; then
	tmux new-window -c ${args[2]} -n ${args[1]}
else
	tmux select-window -t ${args[1]} && tmux switch-client -t ${args[0]}
fi
