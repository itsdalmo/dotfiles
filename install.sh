#!/usr/bin/env bash

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make sure we have the required folders
mkdir -p ~/.config/nvim/

# Create symbolic links
ln -sf $DIR/vim/init.vim ~/.vimrc
ln -sf $DIR/vim/init.vim ~/.config/nvim/init.vim
ln -sf $DIR/git/gitconfig ~/.gitconfig
ln -sf $DIR/tmux/tmux.conf ~/.tmux.conf
ln -sf $DIR/bash/bash_profile ~/.bash_profile

# Link snippets
mkdir -p ~/.config/nvim/UltiSnips
SNIPPETS=$(find ${DIR}/vim/UltiSnips/*.snippets -type f | sort);
for snippet in $SNIPPETS; do
    ln -sf $snippet ~/.config/nvim/UltiSnips/$( basename $snippet )
done

# Link tmux configs
mkdir -p ~/.tmux
TMUXCONF=$(find ${DIR}/tmux/*.config -type f | sort);
for conf in $TMUXCONF; do
    ln -sf $conf ~/.tmux/$( basename $conf )
done

# Add git hooks
mkdir -p ~/Telia/
GITFOLDERS=$(ls -d ~/Telia/*/ );
for folder in $GITFOLDERS; do
  if [ -d "$folder/.git" ]; then
    ln -sf $DIR/git/hooks/pre-push $folder.git/hooks/pre-push
    ln -sf $DIR/git/hooks/commit-msg $folder.git/hooks/commit-msg
  fi
done
