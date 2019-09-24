dir=${1:-~}

verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
    [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

rm -f $dir/.bash_profile
ln -s `pwd`/bash_profile $dir/.bash_profile

rm -f $dir/.bashrc
ln -s `pwd`/bashrc $dir/.bashrc

rm -f $dir/.git-completion.bash
ln -s `pwd`/git-completion.bash $dir/.git-completion.bash

rm -f $dir/.inputrc
ln -s `pwd`/inputrc $dir/.inputrc

rm -f $dir/.tmux.conf
if $(verlt "`tmux -V|awk -F'[^0-9.]*' '$0=$2'`" "2.9"); then
    ln -s `pwd`/tmux-pre-2.9.conf $dir/.tmux.conf
else
    ln -s `pwd`/tmux.conf $dir/.tmux.conf
fi

rm -f $dir/.vim
ln -s `pwd`/vim  $dir/.vim

rm -f $dir/.vimrc
ln -s `pwd`/vim/vimrc $dir/.vimrc

if [ ! -f "$dir/.gitconfig" ]; then
    echo "[include]" >> $dir/.gitconfig
    echo "    path = $(pwd)/gitconfig" >> $dir/.gitconfig
else
    echo "Found existing $dir/.gitconfig -- will not overwrite"
fi
