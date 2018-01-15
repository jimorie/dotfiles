rm -i ~/.bash_profile
ln -s `pwd`/bash_profile ~/.bash_profile

rm -i ~/.git-completion.bash
ln -s `pwd`/git-completion.bash ~/.git-completion.bash

rm -i ~/.inputrc
ln -s `pwd`/inputrc ~/.inputrc

rm -i ~/.tmux.conf
ln -s `pwd`/tmux.conf ~/.tmux.conf

rm -ir ~/.vim
ln -s `pwd`/vim  ~/.vim

rm -i ~/.vimrc
ln -s `pwd`/vim/vimrc ~/.vimrc
