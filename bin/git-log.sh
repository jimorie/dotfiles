#!/bin/bash

terminal_columns=$(tput cols 2>/dev/null || printf '0')
if (( terminal_columns >= 200 )); then
    preview_window=right,50%,border-rounded
else
    preview_window=up,50%,border-rounded
fi

git log --graph --all --color=always --abbrev-commit \
    --format='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' |
fzf --ansi --no-sort --track --tiebreak=index --bind=ctrl-s:toggle-sort \
    --border-label $(basename `git rev-parse --show-toplevel`) \
    --bind "ctrl-p:down,ctrl-n:up,pgup:preview-page-up,pgdn:preview-page-down" \
    --bind "ctrl-m:execute:printf '%s\\n' {} | grep -o '[a-f0-9]\\{7\\}' | head -1 | xargs -I % git show --color=always % | delta" \
    --layout=reverse \
    --preview-window="$preview_window" \
    --preview "printf '%s\\n' {} | grep -o '[a-f0-9]\\{7\\}' | head -1 | xargs -I % git show --color=always % | delta"
