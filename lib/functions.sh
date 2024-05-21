#
## functions.sh
#

po_init(){
   mkdir -p $PO_PATH/list
   mkdir -p $PO_PATH/proj
   mkdir -p $PO_PATH/.hidden_proj
   mkdir -p $PO_PATH/.tmp
   echo "The path to archive files is '$PO_PATH'"
}

po_date(){
  PO_UNIX_TIME=$(date +'%s')
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
        PO_UNIX_TIME=$(date +'%s')
        ;;
      ?td)
        CURRENT_DAY=$(date +'%Y-%m-%d')
        PO_UNIX_TIME=$(date -d "$CURRENT_DAY $(date -d "@$PO_UNIX_TIME" +'%H:%M:%S')" +'%s')
        ;;
      ?m)
        PO_UNIX_TIME=$(date -d "$(date -d "@$PO_UNIX_TIME" +'%Y-%m-%d') 09:00:00" +'%s')
        ;;
      ?noon)
        PO_UNIX_TIME=$(date -d "$(date -d "@$PO_UNIX_TIME" +'%Y-%m-%d') 12:00:00" +'%s')
        ;;
      ?a)
        PO_UNIX_TIME=$(date -d "$(date -d "@$PO_UNIX_TIME" +'%Y-%m-%d') 15:00:00" +'%s')
        ;;
      ?n)
        PO_UNIX_TIME=$(date -d "$(date -d "@$PO_UNIX_TIME" +'%Y-%m-%d') 21:00:00" +'%s')
        ;;
      ?ytd)
        PO_UNIX_TIME=$((PO_UNIX_TIME - 86400))
        ;;
      ?tmrw)
        PO_UNIX_TIME=$((PO_UNIX_TIME + 86400))
        ;;
      [\+\-]?[0-9]+[dh])
        CHANGE_TIME=0
        MATCH_NUMBER=$(echo "$CURRENT_DATE_CODE" | grep -oP '\d+(?=d)')
        CHANGE_TIME=$((CHANGE_TIME + MATCH_NUMBER * 86400))
        MATCH_NUMBER=$(echo "$CURRENT_DATE_CODE" | grep -oP '\d+(?=h)')
        CHANGE_TIME=$((CHANGE_TIME + MATCH_NUMBER * 3600))
        if [[ "$CURRENT_DATE_CODE" == -* ]]; then
          CHANGE_TIME=$((- CHANGE_TIME))
        fi
        PO_UNIX_TIME=$((PO_UNIX_TIME + CHANGE_TIME))
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
      PO_FORMATTED_TIME=$(date -d "@$PO_UNIX_TIME" "+%y%m%d%H")
      echo "[DEBUG] \$PO_FORMATTED_TIME=$PO_FORMATTED_TIME"
    fi
    # }DEUBG
  done
  return $PO_UNIX_TIME
}

po_period(){

}


