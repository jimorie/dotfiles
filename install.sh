rm -f ~/.bash_profile
ln -s `pwd`/bash_profile ~/.bash_profile

rm -f ~/.bashrc
ln -s `pwd`/bashrc ~/.bashrc

rm -f ~/.git-completion.bash
ln -s `pwd`/git-completion.bash ~/.git-completion.bash

rm -f ~/.inputrc
ln -s `pwd`/inputrc ~/.inputrc

rm -f ~/.tmux.conf
ln -s `pwd`/tmux.conf ~/.tmux.conf

rm -f ~/.vim
ln -s `pwd`/vim  ~/.vim

rm -f ~/.vimrc
ln -s `pwd`/vim/vimrc ~/.vimrc
