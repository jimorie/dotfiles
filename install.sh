dir=${1:-~}

rm -f $dir/.bash_profile
ln -s `pwd`/bash_profile $dir/.bash_profile

rm -f $dir/.bashrc
ln -s `pwd`/bashrc $dir/.bashrc

rm -f $dir/.git-completion.bash
ln -s `pwd`/git-completion.bash $dir/.git-completion.bash

rm -f $dir/.inputrc
ln -s `pwd`/inputrc $dir/.inputrc

rm -f $dir/.tmux.conf
ln -s `pwd`/tmux.conf $dir/.tmux.conf

rm -f $dir/.vim
ln -s `pwd`/vim  $dir/.vim

rm -f $dir/.vimrc
ln -s `pwd`/vim/vimrc $dir/.vimrc
