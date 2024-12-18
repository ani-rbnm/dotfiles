#!/usr/bin/env bash

readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Icon path
readonly ICON="${DIR}/icons/network/globe.svg"

# Displays network interface dengan ipv4 (local)
readonly TOOLTIP=$(ip -f inet a | perl -nle 'print "$2 $1" if /^(?=.*wlp)\s+inet\s+(\S+).*?(\S+)$/')

# Getting wireless interface details
readonly WIRELESS_INT=$(ip -f inet a | perl -nle 'print "$2" if /^(?=.*wlp)\s+inet\s+(\S+).*?(\S+)$/')

# Offline
ip route | grep ^default &>/dev/null || \
  echo -ne "<txt> Offline</txt>" || \
    echo -ne "<tool> Offline</tool>" || \
      exit

# Interface unknown
test -d "/sys/class/net/${WIRELESS_INT}" || \
  echo -ne "<txt>Invalid</txt>" || \
    echo -ne "<tool>Interface not found</tool>" || \
      exit
# PRX=$(awk '{print $0}' "/sys/class/net/${INTERFACE}/statistics/rx_bytes")
PTX=$(awk '{print $0}' "/sys/class/net/${WIRELESS_INT}/statistics/tx_bytes")
sleep 1
# CRX=$(awk '{print $0}' "/sys/class/net/${INTERFACE}/statistics/rx_bytes")
CTX=$(awk '{print $0}' "/sys/class/net/${WIRELESS_INT}/statistics/tx_bytes")

# BRX=$(( CRX - PRX ))
BTX=$(( CTX - PTX ))

function hasil_untuk_panel () {
  
  local BANDWIDTH="${1}"
  local P=1
  
  while [[ $(echo "${BANDWIDTH}" '>' 1024 | bc -l) -eq 1 ]]; do
    BANDWIDTH=$(awk '{$1 = $1 / 1024; printf "%.2f", $1}' <<< "${BANDWIDTH}")
    P=$(( P + 1 ))
  done
  
  case "${P}" in
    0) BANDWIDTH="${BANDWIDTH} B/s" ;;
    1) BANDWIDTH="${BANDWIDTH} KB/s" ;;
    2) BANDWIDTH="${BANDWIDTH} MB/s" ;;
    3) BANDWIDTH="${BANDWIDTH} GB/s" ;;
  esac
  
  echo -e "${BANDWIDTH}"
  
  return 1
}

# RX=$(hasil_untuk_panel ${BRX})
TX=$(hasil_untuk_panel ${BTX})

# Panel
if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
  INFO="<img>${ICON}</img>"
  if hash xfce4-taskmanager &> /dev/null; then
    INFO+="<click>xfce4-taskmanager</click>"
  fi
  INFO+="<txt>"
else
  INFO="<txt>"
fi
INFO+=" ${TX}"
INFO+="</txt>"

# Tooltip
MORE_INFO="<tool>"
MORE_INFO+="${TOOLTIP}"
MORE_INFO+="</tool>"

# Panel Print
echo -e "${INFO}"

# Tooltip Print
echo -e "${MORE_INFO}"
