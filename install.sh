#!/usr/bin/env bash

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make sure we have the required folders
mkdir -p ~/.config/nvim/

# Create symbolic links
ln -sf $DIR/vim/init.vim ~/.vimrc
ln -sf $DIR/vim/init.vim ~/.config/nvim/init.vim
ln -sf $DIR/tmux/tmux.conf ~/.tmux.conf
ln -sf $DIR/bash/bash_profile ~/.bash_profile

# Link snippets
mkdir -p ~/.config/nvim/UltiSnips
SNIPPETS=$(find ${DIR}/vim/UltiSnips/*.snippets -type f | sort);
for snippet in $SNIPPETS; do
    echo $snippet ~/.config/nvim/UltiSnips/$( basename $snippet )
    # ln -sf $snippet ~/.config/nvim/UltiSnips/$( basename $snippet )
done

# Link tmux configs
mkdir -p ~/.tmux
TMUXCONF=$(find ${DIR}/tmux/*.config -type f | sort);
for conf in $TMUXCONF; do
    echo $conf ~/.tmux/$( basename $conf )
    # ln -sf $conf ~/.tmux/$( basename $conf )
done

