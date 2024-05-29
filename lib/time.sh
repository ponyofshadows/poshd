#!/bin/bash
#
## time.sh
#

po_date(){
  local formatted_time=$(date +'%y%m%d%H')
  local time_code_queue=$1
  local current_time_code=""
  if [[ !( $time_code_queue == +* || $time_code_queue == -* ) ]]; then
    time_code_queue="+$time_code_queue"
  fi
  # DEBUG{
  #if [[ -n "$PO_DEBUG" ]]; then
    #echo "[DEBUG](time.po_date) \$time_code_queue=$time_code_queue" >&2
  #fi
  # }DEBUG
  while [[ -n "$time_code_queue" ]]; do
    if [[ $time_code_queue =~ ^([+-])(.*?)([+-].*|$) ]]; then
      current_time_code="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
      time_code_queue="${BASH_REMATCH[3]}"  
    else
      current_time_code="$string"
      time_code_queue=""
    fi
    case "$current_time_code" in
      ?now)
        local formatted_now=$(date +'%y%m%d%H')
        formatted_time=$formatted_now
        ;;
      ?td)
        local formatted_td=$(date +'%y%m%d')
        formatted_time="$formatted_td${formatted_time:6}"
        ;;
      ?ytd)
        local formatted_ytd=$(date -d 'yesterday' +'%y%m%d')
        formatted_time="$formatted_ytd${formatted_time:6}"
        ;;
      ?tmrw)
        local formatted_tmrw=$(date -d 'tomorrow' +'%y%m%d')
        formatted_time="$formatted_tmrw${formatted_time:6}"
        ;;
      ?em)
        formatted_time="${formatted_time:0:6}03"
        ;;
      ?sr)
        formatted_time="${formatted_time:0:6}06"
        ;;
      ?m)
        formatted_time="${formatted_time:0:6}09"
        ;;
      ?noon)
        formatted_time="${formatted_time:0:6}12"
        ;;
      ?a)
        formatted_time="${formatted_time:0:6}15"
        ;;
      ?ss)
        formatted_time="${formatted_time:0:6}18"
        ;;
      ?n|?twi)
        formatted_time="${formatted_time:0:6}21"
        ;;
      ?mn)
        formatted_time="${formatted_time:0:6}24"
        ;;
      [^0-9][0-9][0-9])
        formatted_time="${formatted_time:0:6}${current_time_code:1}"
        ;;
      [^0-9][0-9][0-9][0-9][0-9])
        formatted_time="${formatted_time:0:4}${current_time_code:1}"
        ;;
      [^0-9][0-9][0-9][0-9][0-9][0-9][0-9])
        formatted_time="${formatted_time:0:2}${current_time_code:1}"
        ;;
      [^0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
        formatted_time="${current_time_code:1}"
        ;;
      [+-][0-9]*[dh]*)
        local change_day=$(echo "$current_time_code" | grep -oP '\d+(?=d)')
        local change_hour=$(echo "$current_time_code" | grep -oP '\d+(?=h)')
        local change_time_by_hour=$((change_day * 24 + change_hour)) 
        if [[ "$current_time_code" == -* ]]; then
          change_time_by_hour=$((- change_time_by_hour))
        fi
        formatted_time=$(date -u -d "20${formatted_time:0:2}-${formatted_time:2:2}-${formatted_time:4:2} ${formatted_time:6:2}:00 UTC + $change_time_by_hour hours" +"%y%m%d%H")
        ;;
    esac
    # DEBUG{
    #if [[ -n "$PO_DEBUG" ]]; then
      #echo "[DEBUG](time.po_date) \$current_time_code=$current_time_code" >&2
      #echo "[DEBUG](time.po_date) \$formatted_time=$formatted_time" >&2
    #fi
    # }DEUBG
  done
  echo "$formatted_time"
}

po_period(){
  local current_time=$(po_date "")
  local period
  case "$1" in
    H)
      period="$current_time" 
      ;;
    d)
      period="${current_time:0:6}"
      ;;
    ""|m)
      period="${current_time:0:4}"
      ;;
    y)
      period="${current_time:0:2}"
      ;;
    [0-9][0-9]|[0-9][0-9]0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
      period="$1"
      ;;
    *)
      period=""
      ;;
  esac
  echo "$period"
}

