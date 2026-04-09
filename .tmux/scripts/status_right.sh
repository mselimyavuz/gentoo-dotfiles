#!/bin/bash

# ==========================================================
# Threshold Colors (Gruvbox Palette)
# ==========================================================
BG_COLOR="#3c3836"
FG_DEFAULT="#a89984"
WARN="#fabd2f"
CRIT="#fb4934"

get_disk_usage() {
    df_output=$(df -h -P /dev/nvme0n1p3 2>/dev/null | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')
    if [[ -n "$df_output" ]]; then
        echo "📊 $df_output"
    else
        echo "📊 N/A"
    fi
}

get_cpu_usage() {
    cpu_usage=$(top -b -n 1 | grep '^%Cpu(s):' | awk '{printf "%.0f", $2 + $4}' 2>/dev/null)
    
    if [[ -n "$cpu_usage" ]]; then
        local color=$FG_DEFAULT
        [ "$cpu_usage" -gt 70 ] && color=$WARN
        [ "$cpu_usage" -gt 90 ] && color=$CRIT
        echo "#[fg=$color]🖥️ ${cpu_usage}%"
    else
        echo "🖥️ N/A"
    fi
}

get_mem_usage() {
    # Extract data in one awk pass
    mem_data=$(free -b | awk 'NR==2{
        total=$2; avail=$7; used=total-avail;
        perc=((total-avail)/total)*100;
        printf "%.0f|%.1f|%.0f", perc, used/(1024^3), total/(1024^3)
    }' 2>/dev/null)

    if [[ -n "$mem_data" ]]; then
        IFS='|' read -r perc used total <<< "$mem_data"
        local color=$FG_DEFAULT
        [ "$perc" -gt 70 ] && color=$WARN
        [ "$perc" -gt 90 ] && color=$CRIT
        echo "#[fg=$color]🧠 ${used}GiB/${total}GiB (${perc}%)"
    else
        echo "🧠 N/A"
    fi
}

get_network_info() {
    local interface=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')
    [ -z "$interface" ] && interface=$(ip -o link show | awk -F': ' '$2 != "lo" {print $2; exit}')

    if [[ -n "$interface" ]]; then
        local status=$(cat /sys/class/net/"$interface"/operstate 2>/dev/null)
        local ip_addr=$(ip -4 addr show "$interface" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1)

        if [[ "$status" == "up" && -n "$ip_addr" ]]; then
            echo "#[fg=$FG_DEFAULT]🌐 $ip_addr"
        else
            echo "#[fg=$CRIT]🌐 Down"
        fi
    else
        echo "#[fg=$CRIT]🌐 No Net"
    fi
}

get_kernel_info() {
	echo -e "\uebc6 $(uname -r)"
}

# ==========================================================
# Main Execution
# ==========================================================
DISK=$(get_disk_usage)
CPU=$(get_cpu_usage)
MEM=$(get_mem_usage)
NET=$(get_network_info)
KERN=$(get_kernel_info)

# Output with consistent background to match your status bar
echo "#[bg=$BG_COLOR,fg=$FG_DEFAULT] $KERN #[fg=#504945]|#[bg=$BG_COLOR,fg=$FG_DEFAULT] $NET #[fg=#504945]| #[bg=$BG_COLOR,fg=$FG_DEFAULT]$DISK #[fg=#504945]| $CPU #[fg=#504945]| $MEM#[fg=#504945]"
	

