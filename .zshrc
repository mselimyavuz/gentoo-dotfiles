export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/home/mselimyavuz/lilypond/bin/"
export PATH="$PATH:/home/mselimyavuz/.cargo/bin"
export PATH="$PATH:/home/mselimyavuz/.local/bin"
export BEMENU_BACKEND="wayland"
export MANPAGER="nvim +Man!"
export PAGER="nvim -R -M -c 'runtime! macros/less.vim'"
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

export VISUAL="$EDITOR"
export WLR_NO_HARDWARE_CURSORS=1
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

ZSH_THEME=""
plugins=(git ssh-agent fzf zsh-autosuggestions zsh-syntax-highlighting)

zstyle :omz:plugins:ssh-agent identities id_ed25519

source $ZSH/oh-my-zsh.sh

alias se='doas env XDG_CONFIG_HOME=$HOME/.config XDG_DATA_HOME=$HOME/.local/share XDG_STATE_HOME=$HOME/.local/state nvim'
alias fix-phone='adb shell settings put global force_fsg_nav_bar 1 && adb shell settings put global hide_gesture_line 1'
alias ls="eza --icons --git --group-directories-first"
alias less="nvim -u NORC -R -M -c 'runtime! macros/less.vim'"

eval "$(oh-my-posh init zsh --config /home/mselimyavuz/gentoo-dotfiles/oh-my-posh-theme.json)"
fastfetch

yt-playlist() {
    yt-dlp -x --audio-format mp3 --audio-quality 0 --yes-playlist \
    --embed-metadata --embed-thumbnail \
    -o "%(playlist_index)s-%(title)s.%(ext)s" \
    --exec "post_process:echo '%(playlist_index)s-%(title)s.mp3' >> '%(playlist_title)s.m3u'" \
    "$1"
}

borg-backup() {
   sudo borg create --stats --progress --compression lz4 \
    --exclude-from /home/mselimyavuz/gentoo-dotfiles/borg-excludes.txt \
    /mnt/backup::gentoo-backup-$(date +%F) \
    /
}

