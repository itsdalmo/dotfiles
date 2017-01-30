#!/usr/bin/env bash

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

link_dot_files() {
    echo "Linking dot files..."
    mkdir -p ~/.config/nvim/
    ln -sf $DIR/vim/init.vim ~/.vimrc
    ln -sf $DIR/vim/init.vim ~/.config/nvim/init.vim
    ln -sf $DIR/git/gitconfig ~/.gitconfig
    ln -sf $DIR/tmux/tmux.conf ~/.tmux.conf
    ln -sf $DIR/bash/bash_profile ~/.bash_profile
}

link_vim_snippets() {
    echo "Linking vim snippets..."
    mkdir -p ~/.config/nvim/UltiSnips
    SNIPPETS=$(find ${DIR}/vim/UltiSnips/*.snippets -type f | sort);
    for snippet in $SNIPPETS; do
        ln -sf $snippet ~/.config/nvim/UltiSnips/$( basename $snippet )
    done
}

link_spacemacs_config() {
    echo "Linking spacemacs config..."
    ln -sf $DIR/spacemacs/spacemacs ~/.spacemacs
}

link_tmux_config() {
    echo "Linking tmux config..."
    mkdir -p ~/.tmux
    TMUXCONF=$(find ${DIR}/tmux/*.config -type f | sort);
    for conf in $TMUXCONF; do
        ln -sf $conf ~/.tmux/$( basename $conf )
    done
}

link_git_hooks() {
    echo "Linking tmux config..."
    mkdir -p ~/Work
    GITFOLDERS=$(ls -d ~/Work/*/ );
    for folder in $GITFOLDERS; do
      if [ -d "$folder/.git" ]; then
        ln -sf $DIR/git/hooks/pre-push $folder.git/hooks/pre-push
        ln -sf $DIR/git/hooks/commit-msg $folder.git/hooks/commit-msg
      fi
    done
}

# Install
link_dot_files
link_vim_snippets
link_tmux_config
link_git_hooks
link_spacemacs_config
echo "Done!"

