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

wifi-menu() {
    echo "Scanning for networks..."
    wpa_cli scan > /dev/null
    sleep 2

    local selected_line
    selected_line=$(wpa_cli scan_results | tail -n +3 | \
        fzf --header="[WIFI SCAN] Select SSID to connect" \
            --reverse --height=40% --ansi)

    [ -z "$selected_line" ] && return

    local ssid=$(echo "$selected_line" | awk '{print $NF}')
    local security=$(echo "$selected_line" | awk '{print $4}')

    local net_id=$(wpa_cli list_networks | grep -w "$ssid" | awk '{print $1}')

    if [ -n "$net_id" ]; then
        echo "Switching to known network: $ssid (ID: $net_id)"
        wpa_cli select_network "$net_id"
    else
        echo "New network detected: $ssid"
        
        net_id=$(wpa_cli add_network | tail -1)
        
        if [[ "$security" == *"[WPA"* ]]; then
            read -rs -p "Enter Password for $ssid: " pass
            echo
            wpa_cli set_network "$net_id" ssid "\"$ssid\""
            wpa_cli set_network "$net_id" psk "\"$pass\""
        else
            wpa_cli set_network "$net_id" ssid "\"$ssid\""
            wpa_cli set_network "$net_id" key_mgmt NONE
        fi
        
        wpa_cli select_network "$net_id"
        wpa_cli enable_network "$net_id"
        wpa_cli save_config
    fi
}

