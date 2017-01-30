## Spacemacs setup

#### Install emacs

Use brew to install and launch the daemon on login etc.

```bash
brew tap d12frosted/emacs-plus
brew install emacs-plus
brew linkapps emacs-plus
brew services start d12frosted/emacs-plus/emacs-plus
```

#### Clone spacemacs

```bash
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
```


