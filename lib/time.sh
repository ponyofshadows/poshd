#
## time.sh
#

po_date(){
  PO_FORMATTED_TIME=$(date +'%y%m%d%h')
  DATE_CODE_QUEUE=$1
  if [[ !( $DATE_CODE_QUEUE == +* || $DATE_CODE_QUEUE == -* ) ]]; then
    DATE_CODE_QUEUE="+$DATE_CODE_QUEUE"
  fi
  # DEBUG{
  if [[ -n "$PO_DEBUG" ]]; then
    echo "[DEBUG] function:po_date"
    echo "[DEBUG] \$DATE_CODE_QUEUE=$DATE_CODE_QUEUE"
  fi
  # }DEBUG
  while [[ -n "$DATE_CODE_QUEUE" ]]; do
    if [[ $DATE_CODE_QUEUE =~ ^([+-])(.*?)([+-].*|$) ]]; then
      CURRENT_DATE_CODE="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
      DATE_CODE_QUEUE="${BASH_REMATCH[3]}"  
    else
      CURRENT_DATE_CODE="$string"
      DATE_CODE_QUEUE=""
    fi
    case "$CURRENT_DATE_CODE" in
      ?now)
        PO_FORMATTED_NOW=$(date +'%y%m%d%h')
        PO_FORMATTED_TIME=$PO_FORMATTED_NOW
        ;;
      ?td)
        PO_FORMATTED_TD=$(date +'%y%m%d')
        PO_FORMATTED_TIME="$PO_FORMATTED_TD${PO_FORMATTED_TIME:6}"
        ;;
      ?ytd)
        PO_FORMATTED_YTD=$(date -d 'yesterday' +'%y%m%d')
        PO_FORMATTED_TIME="$PO_FORMATTED_YTD${PO_FORMATTED_TIME:6}"
        ;;
      ?tmrw)
        PO_FORMATTED_TMRW=$(date -d 'tomorrow' +'%y%m%d')
        PO_FORMATTED_TIME="$PO_FORMATTED_TMRW${PO_FORMATTED_TIME:6}"
        ;;
      ?em)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}03"
        ;;
      ?sr)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}06"
        ;;
      ?m)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}09"
        ;;
      ?noon)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}12"
        ;;
      ?a)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}15"
        ;;
      ?ss)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}18"
        ;;
      ?n|?twi)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}21"
        ;;
      ?mn)
        PO_FORMATTED_TIME="${PO_FORMATTED_TIME:0:6}24"
        ;;
      [\+\-]?[0-9]+[dh])
        ;;
      [^0-9][0-9][0-9])
        ;;
      [^0-9][0-9][0-9][0-9][0-9])
        ;;
      [^0-9][0-9][0-9][0-9][0-9][0-9][0-9])
        ;;
      [^0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
        ;;
    esac
    # DEBUG{
    if [[ -n "$PO_DEBUG" ]]; then
      echo "[DEBUG] \$CURRENT_DATE_CODE=$CURRENT_DATE_CODE"
      echo "[DEBUG] \$PO_FORMATTED_TIME=$PO_FORMATTED_TIME"
    fi
    # }DEUBG
  done
  return $PO_UNIX_TIME
}

po_period(){

}


