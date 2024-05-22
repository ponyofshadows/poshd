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
  if [[ -n "$PO_DEBUG" ]]; then
    echo "[DEBUG] function:po_date"
    echo "[DEBUG] \$time_code_queue=$time_code_queue"
  fi
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
        local formatted_now=$(date +'%y%m%d%h')
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
      [\+\-]?[0-9]+[dh])
        local change_day=$(echo "$current_time_code" | grep -oP '\d+(?=d)')
        local change_time=$(echo "$current_time_code" | grep -oP '\d+(?=h)')
        if [[ "$current_time_code" == -* ]]; then
          change_day=$((- change_day))
          change_time=$((- change_time))
        fi
        formatted_time=$(date -d "20${formatted_time:0:2}-${formatted_time:2:2}-${formatted_time:4:2} ${formatted_time:6:2}:00 + $change_day day + $change_time hours" +"%y%m%d%H")
        ;;
    esac
    # DEBUG{
    if [[ -n "$PO_DEBUG" ]]; then
      echo "[DEBUG] \$current_time_code=$current_time_code"
      echo "[DEBUG] \$formatted_time=$formatted_time"
    fi
    # }DEUBG
  done
  return "$formatted_time"
}

po_period(){
  local period_input="$1"
  local time_from=""
  local time_to=""
  if [[ period_input == "whole" ]]; then
    time_from="00010100"
    time_to="99123123"
  else
    time_from=$(po_date ${period_input%%,*})
    time_to=$(po_date ${period_input#*,})
  fi
  return "$time_from,$time_to"
}


