#!/bin/bash
if [ ! -z $GERRIT_HTTP ]; then
	test -z $GERRIT_PATH && export GERRIT_PATH=$(\
		git config remote.origin.url | \
		python3 -c"import re, sys; m = re.match(r'ssh://.*?@(.*?)/(.*)', sys.stdin.read()); print(m.group(2) if m else '')")
	test -z $GERRIT_PATH && echo 'Failed to read repo path from git config remote.origin.url!' && exit 2
	git review -l --color=always \
		| sed -e "$ d" \
		| fzf --exact --ansi --border-label='Enter to checkout • Ctrl-O to open in browser' --border=top \
		--bind "enter:become[git review -d {1}]" \
		--bind "ctrl-o:become[open '$GERRIT_HTTP/c/$GERRIT_PATH/+/{1}' 2>/dev/null]"
else
	echo 'Set $GERRIT_HTTP to enable browser shortcuts' 1>&2
	git review -l --color=always \
		| sed -e "$ d" \
		| fzf --exact --ansi --border-label='Enter to checkout' --border=top \
		--bind "enter:become[git review -d {1}]"
fi
