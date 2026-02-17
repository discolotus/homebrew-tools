# homebrew-tools

Custom Homebrew tap for Tanner/discolotus utilities.

## Install sldl

```bash
brew tap discolotus/tools
brew install sldl
```

## Upgrade

```bash
brew update
brew upgrade sldl
```


## Maintainer quick update

Bump formula to latest upstream release (auto-fetches macOS asset SHA256s):

```bash
./scripts/update-sldl.sh 2.6.1
git add Formula/sldl.rb
git commit -m "sldl 2.6.1"
git push
```
