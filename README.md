# dotfiles

My dotfiles/dev environments.

## Prerequisities

### Terminal

Install [iterm2](https://www.iterm2.com/downloads.html),
[powerline-fonts](https://github.com/powerline/fonts) and
[spacemacs-theme](https://github.com/colepeters/spacemacs-theme.vim) for iterm2.

### Homebrew
Install [Homebrew](http://brew.sh/index_no.html) and run the following:

```bash
# TMUX
# (https://tmux.github.io/)
brew install tmux

# NVIM
# (https://github.com/neovim/neovim))
brew install neovim/neovim/neovim

# Plug.vim
# (https://github.com/junegunn/vim-plug)
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# FZF
# (https://github.com/junegunn/fzf)
brew install fzf

# Ag (Silver searcher)
# (https://github.com/ggreer/the_silver_searcher)
brew install the_silver_searcher

# ShellCheck - code analysis for shell
# (https://github.com/koalaman/shellcheck)
brew install shellcheck

# Git aware prompt
# (https://github.com/jimeh/git-aware-prompt)
mkdir ~/.bash && cd ~/.bash
git clone git://github.com/jimeh/git-aware-prompt.git

# Git completion
# (https://github.com/git/git/blob/master/contrib/completion/git-completion.bash)
curl -o ~/.bash/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# Optional: Spacemacs
# (https://github.com/syl20bnr/spacemacs)
brew tap d12frosted/emacs-plus
brew install emacs-plus
brew linkapps emacs-plus
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
```

## Languages/tools

```bash
# Node.js
brew install node

# AWS CLI
# (http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-bundle-other-os)
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Postgres.app
# (https://postgresapp.com/)

# Rust (Nightly)
# (https://www.rustup.rs/)
curl https://sh.rustup.rs -sSf | sh

# After installing rustup:
rustup install nightly
rustup default nightly

# Python 2.7/3.5
# (https://www.continuum.io/downloads#osx)

# After installing anaconda:
conda create -n python2 python=2.7 anaconda
conda create -n python3 python=3.5 anaconda

# R/Rstudio
# (https://cran.r-project.org/)
# (https://www.rstudio.com/products/rstudio/download/)
```

## Dotfiles

Clone the repository and run the install script:

```bash
sudo chmod a+x ./install.sh
./install.sh
```

## Finishing touch

For nvim python support:

```bash
pip install neovim
```

Launch nvim/dev, ignore any errors and type :PlugInstall. Restart nvim and you should be good to go.

