# dotfiles

My dotfiles. 

#### Requirements

1. [Git aware prompt](https://github.com/jimeh/git-aware-prompt)
2. [Git completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash)
3. [FZF](https://github.com/junegunn/fz://github.com/junegunn/fzf) - Installed by vim-plug.
4. [AG (silver searcher)](https://github.com/ggreer/the_silver_searcher)

Everything in homefolder, except:
```
init.vim => ~/.config/nvim
UltiSnips => ~/.config/nvim
```

Symlink .vimrc:
```
ln -s ~/.config/nvim/init.vim ~/.vimrc
```
