eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
fastfetch --logo-type file-raw --logo <(fortune -s | cowsay -f eyes)
export GOPATH=$HOME/.local/share/go
export PATH="$HOME/.cargo/bin:$PATH"
alias lvim='NVIM_APPNAME=lazyvim nvim'
