#!/bin/bash
#==========================================#
#                 poshd                    #
#  https://github.com/ponyofshadows/poshd  #
#              version 1.1                 #
#==========================================#
PO_PATH="${HOME}/all"
mkdir -p "$PO_PATH"

#
## object func
#
_po_complete_object(){
  if [[ -n "$current_content" ]]; then
    if [[ "${current_object["type"]}" == "event" || "${current_object["type"]}" == "project" ]]; then
      # title
      current_object["content"]="${current_content%%/*}"
      # path
      if [[ "$current_content" == */* ]]; then
        current_object["path"]="${current_content#*/}"
      fi
    else
      current_object["content"]="$current_content"
    fi
  fi
  if [[ (-n "$current_content") || "${current_object[type]}" == "keywords" ]]; then
    current_content=""
    local object_count=${#object_key_list[@]}
    # DEBUG{
    #if [[ -n PO_DEBUG ]]; then
      #echo "[DEBUG](po) *** A New Object ***"
      #echo "[DEBUG](po) type: ${current_object["type"]}"
      #echo "[DEBUG](po) key: ${!current_object[@]}"
      #echo "[DEBUG](po) value: ${current_object[@]}"
      #echo "[DEBUG](po) object_count=$object_count"
    #fi
    # }DEBUG
    object_key_list[object_count]="${!current_object[@]}"
    object_value_list[object_count]="${current_object[@]}"
    unset current_object
    declare -g -A current_object
    current_object["type"]="event"
  fi
}

#
## time func
#
_po_date(){
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

_po_period(){
  local current_time=$(_po_date "")
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
  local period_text_length=${#period}
  while (( $period_text_length < 8 )); do
    period="${period}[0-9]"
    let period_text_length++
  done
  echo "$period"
}

#
## main: po
#
po() {
  # ----------------
  ## Strategies for Parsing Parameters
  # 
  # - Adjacent non-option parameters will be concatenated into one object
  # |__ objects starting with "-e" or without preceding options -> (type:event, content, path, time, remove)
  # |__ objects starting with "-p" -> (type:project, content, path, status, remove)
  # |__ objects starting with "-f" -> (type:file, content, remove)
  # |__ objects starting with "-b" or "-r" -> (type:disk, content, action)
  # |__ objects starting with "-l" -> (type:keyword, content, period)
  # - Objects call specfic functions
  # |__ event -> update_event
  # |__ project -> update_project
  # |__ event & project -> link
  # |__ disk -> backup || recover
  # |__ keywords -> search
  # - Some special options
  # |__ "--init" 
  # |__ "--debug"
  # |__ "--rm"
  # ----------------
  current_content=""
  declare -A current_object
  current_object["type"]="event"
  object_key_list=()
  object_value_list=()
  PO_DEBUG=""

  if [[ "$#" == 0 ]]; then
    # equivalent to option "po -l:m"
    current_object["type"]="keywords"
    current_object["period"]=$(_po_period "m")
    object_count=${#object_key_list[@]}
    object_key_list[$object_count]="${!current_object[@]}"
    object_value_list[$object_count]="${current_object[@]}"
  else
    for arg in "$@"; do
      if [[ ! "$arg" == -* ]]; then
        # 1. If current arg is not a option
        if [[ -n "$current_content" ]]; then
          current_content+="_$arg"
        else
          current_content="$arg"
        fi
      else  
        # 2. If current arg is a option
        # |__ 1) complete last object
        _po_complete_object
        # |__ 2) Specific operations
        case "$arg" in
          -e*)
            current_object["type"]="event"
            current_object["time"]="${arg#*-e}"
            current_object["time"]="${current_object["time"]#*:}"
            current_object["time"]=$(_po_date "${current_object["time"]}")
            ;;
          -p*)
            current_object["type"]="project"
            current_object["status"]="${arg#*-p}"
            current_object["status"]="${current_object["status"]#*:}"
            if [[ "${current_object["status"]}" == "rm" ]]; then
              current_object["remove"]="y"
            fi
            ;;
          -f)
            current_object["type"]="file"
            ;;
          -l*)
            current_object["type"]="keywords"
            raw_period="${arg#*-l}"
            raw_period="${raw_period#*:}"
            current_object["period"]=$(_po_period "$raw_period")
            ;;
          --rm)
            current_object["remove"]="y"
            ;;
          -b)
            current_object["type"]="disk"
            current_object["action"]="backup"
            ;;
          -r)
            current_object["type"]="disk"
            current_object["action"]="recover"
            ;;
          --init)
            mkdir -p $PO_PATH/event
            mkdir -p $PO_PATH/proj
            mkdir -p $PO_PATH/.hidden_proj
            echo "The path to archive files is '$PO_PATH'"
            ;;
          --debug)
            if [[ -n "$PO_DEBUG" ]]; then
              PO_DEBUG=""
              echo "[DEBUG] debug off"
            else
              PO_DEBUG="on"
              echo "[DEBUG] debug on"
            fi
            ;;
        esac
      fi
      # DEBUG{
      #if [[ -n "$PO_DEBUG" ]]; then
      #echo "[DEBUG](po) \$arg=$arg" >&2
      #echo "[DEBUG](po) \$current_content=$current_content" >&2
      #fi
      # }DEBUG
    done
    # one more thing
    _po_complete_object
  fi
  # DEBUG{
  if [[ -n "$PO_DEBUG" ]]; then
    echo "[DEBUG](po) *** Object List ***"
    object_count=${#object_key_list[@]} 
    object_index=0
    while (( object_index < object_count )); do
      echo "--------$object_index"
      echo "${object_key_list[object_index]}"
      echo "${object_value_list[object_index]}"
      let object_index+=1
    done
    echo "--------"
  fi
  # }DEBUG

  # ----------------
  ## Operate on Objects
  # ----------------
  declare -a current_object_keys
  declare -a current_object_values

  declare -a event_paths
  declare -a proj_paths
  declare -a proj_file_paths
  declare -a file_paths

  object_count=${#object_key_list[@]} 
  object_index=0
  while (( object_index < object_count )); do
    IFS=' ' read -r -a current_object_keys <<< "${object_key_list[object_index]}"
    IFS=' ' read -r -a current_object_values <<< "${object_value_list[object_index]}"
    let object_index+=1
    unset current_object
    declare -A current_object
    declare key_count=${#current_object_keys[@]}
    declare key_index=0
    while (( key_index < key_count )); do
      current_object["${current_object_keys[$key_index]}"]="${current_object_values[$key_index]}"
      let key_index+=1
    done
    # DEBUG{
    #if [[ -n "$PO_DEBUG" ]]; then
      #echo "[DEBUG](po) cur_key: ${!current_object[@]}"
      #echo "[DEBUG](po) cur_value: ${current_object[@]}"
    #fi
    # }DEBUG
    case "${current_object["type"]}" in 
      event)
        # Time
        if [[ "${current_object["time"]}" == "" ]]; then
          current_object["time"]=$(_po_date "")
        fi
        # Does this event exist? 
        event_floders=( ${PO_PATH}/event/${current_object["time"]:0:6}[0-9][0-9]${current_object["content"]} )
        event_floder=${event_floders[0]}
        if [[ -d "$event_floder" ]]; then
          current_object["time"]=$(echo "$event_floder" | sed -n 's/.*event\/\([0-9]\{8\}\).*/\1/p')
          if [[ -n "${current_object["remove"]}" ]]; then
            rm -rf "$event_floder"
            echo "event deleted: ${event_floder}"
          else
            echo "event was created earlier today: ${event_floder}"
            if [[ -n "${current_object["path"]}" ]]; then
              declare -a current_event_paths=( $(eval echo ${event_floder}/${current_object["path"]}) )
              mkdir -p "${current_event_paths[@]}"
            fi
            event_paths+=("${current_event_paths[@]}")
          fi
        else 
          if [[ "${current_object["remove"]}" == "" ]]; then
            declare -a current_event_paths=( $(eval echo ${PO_PATH}/event/${current_object["time"]}${current_object["content"]}/${current_object["path"]}) )
            mkdir -p "${current_event_paths[@]}"
            echo "new event: ${current_object["time"]}${current_object["content"]}"
            event_paths+=("${current_event_paths[@]}")
          fi
        fi
        ;;
      project)
        proj_floder="${PO_PATH}/proj/${current_object["content"]}"
        hidden_proj_floder="${PO_PATH}/.hidden_proj/${current_object["content"]}"
        declare proj_current_status

        if [[ -d "$proj_floder" ]]; then
          proj_current_status="active"
          echo "project exists: ${current_object["content"]}"
          if [[ "${current_object["remove"]}" ==  "y" ]]; then
            rm -rf "$proj_floder"
            proj_current_status=""
            echo "deleted project: ${current_object["content"]}"
          elif [[ "${current_object[status]}" == "hide" ]]; then
            mv "$proj_floder" "$hidden_proj_floder"
            proj_current_status="hide"
            echo "hide project: ${current_object["content"]}"
          fi
        elif [[ -d "$hidden_proj_floder" ]]; then
          proj_current_status="hide"
          echo "hidden project exists: ${current_object["content"]}"
          if [[ "${current_object["remove"]}" ==  "y" ]]; then
            rm -rf "$hidden_proj_floder"
            proj_current_status=""
            echo "deleted hidden project: ${current_object["content"]}"
          elif [[ "${current_object[status]}" == "active" ]]; then
            mv "$hidden_proj_floder" "$proj_floder"
            proj_current_status="active"
            echo "active project: ${current_object["content"]}"
          fi
        elif [[ "${current_object["remove"]}" == "y" ]]; then
          proj_current_status=""
        elif [[ "${current_object["status"]}" == "hide" ]]; then
          mkdir -p "$hidden_proj_floder"
          proj_current_status="hide"
          echo "create hidden project: ${current_object["content"]}"
        else
          mkdir -p "$proj_floder"
          proj_current_status="active"
          echo "create project: ${current_object["content"]}"
        fi
        if [[ -n "$proj_current_status" ]]; then
          if [[ "$proj_current_status" == "active" ]]; then
            if [[ "${current_object["status"]}" == "file" ]]; then
              declare -a current_proj_files=( $(eval echo ${proj_floder}/${current_object["path"]}) )
              proj_file_paths+=( "${current_proj_files[@]}" )
            else
              declare -a current_proj_paths=( $(eval echo ${proj_floder}/${current_object["path"]}) )
              mkdir -p "${current_proj_paths[@]}"
              proj_paths+=( "${current_proj_paths[@]}" )
            fi
          else # == hide
            if [[ "${current_object["status"]}" == "file" ]]; then
              declare -a current_proj_files=( $(eval echo ${hidden_proj_floder}/${current_object["path"]}) )
              proj_file_paths+=( "${current_proj_files[@]}" )
            else
              declare -a current_proj_paths=( $(eval echo ${hidden_proj_floder}/${current_object["path"]}) )
              mkdir -p "${current_proj_paths[@]}"
              proj_paths+=( "${current_proj_paths[@]}" )
            fi
          fi
        fi
        ;;
      file)
        declare does_file_exist=""
        current_files=( $(eval echo ${current_object["content"]}) )
        for current_file in "${current_files[@]}"; do
          if [[ -f "$current_file" ]]; then
            does_file_exist="y"
            if [[ "${current_object["remove"]}" == "y" ]]; then
              rm -rf "$current_file"
              echo "deleted file: $current_file"
            else
              file_paths+=("$current_file")
            fi
          fi
        done
        if [[ "$does_file_exist" == "" ]]; then
          echo "file doesn't exist: ${current_object["content"]}"
        fi
        ;;
      keywords)
        kw_event_pattern="${PO_PATH}/event/${current_object["period"]}*${current_object["content"]}*"
        event_results=( $(eval echo $kw_event_pattern) )
        if [[ -d "${event_results[0]}" ]]; then
          for event_result in "${event_results[@]}"; do
            echo "$event_result"
          done
        fi
        ;;
      disk)
        if [[ -d "${current_object["content"]}" ]]; then
          if [[ "${current_object["action"]}" == "backup" ]]; then
            # `-a` = `-rlptgoD`; you can't use `-g`,`-o` or `D` unless you are root 
            rsync -rlpt -uHE --progress --delete --exclude=".hidden_proj/"  "$PO_PATH" "${current_object["content"]}"    
            rsync -rlpt -uHE --progress "${PO_PATH}/.hidden_proj" "${current_object["content"]}/.hidden_proj" 
            echo "BACKUP COMPLETE: ${PO_PATH}->${current_object[content]}/"
          else # == "recover"
            mkdir -p ~/all/.hidden_proj
            rsync -rlpt -uHE --progress --exclude=".hidden_proj/" "${current_object["content"]}" $(dirname "$PO_PATH")
            echo "RECOVER COMPLETE: ${current_object[content]}/->${PO_PATH}"
          fi
        else
          echo "path doesn't exist: ${current_object["content"]}" >&2 
        fi
        ;;
    esac
  done

  # DEBUG{
  if [[ -n "$PO_DEBUG" ]]; then
    echo "*** File Paths ***"
    for file_path in "${file_paths[@]}"; do
      echo "$file_path"
    done
    echo "*** Event Paths ***"
    for event_path in "${event_paths[@]}"; do
      echo "$event_path"
    done
    echo "*** Proj Paths ***"
    for proj_path in "${proj_paths[@]}"; do
      echo "$proj_path"
    done
  fi
  # }DEBUG

  if [[ -n "${file_paths[@]}" ]]; then
    if [[ -n "${event_paths[@]}" ]]; then
      if [[ -n "${proj_paths[@]}" ]]; then
        # file->proj/--(hard link)--event/
        unset moved_files
        declare -a moved_files
        for file_path in "${file_paths[@]}"; do
        mv "$file_path" "${proj_paths[0]}" 
        moved_file="${proj_paths[0]}/$(basename "$file_path")"
        moved_files+=( "$moved_file" )
        done
        for moved_file in "${moved_files[@]}"; do
          for proj_path in "${proj_paths[@]:1}"; do
            ln "$moved_file" "$proj_path"
          done
          for event_path in "${event_paths[@]}"; do
            ln "$moved_file" "$event_path"
          done
        done
      else
        # file->event/
        unset moved_files
        declare -a moved_files
        for file_path in "${file_paths[@]}"; do
          mv "$file_path" "${event_paths[0]}" 
          moved_file="${event_paths[0]}/$(basename "$file_path")"
          moved_files+=( "$moved_file" )
        done
        for moved_file in "${moved_files[@]}"; do
          for event_path in "${event_paths[@]:1}"; do
            ln "$moved_file" "$event_path"
          done
        done
      fi
    elif [[ -n "${proj_paths[@]}" ]]; then
      # file->proj/
      unset moved_files
      declare -a moved_files
      for file_path in "${file_paths[@]}"; do
        mv "$file_path" "${proj_paths[0]}" 
        moved_file="${proj_paths[0]}/$(basename "$file_path")"
        moved_files+=( "$moved_file" )
      done
      for moved_file in "${moved_files[@]}"; do
        for proj_path in "${proj_paths[@]:1}"; do
          ln "$moved_file" "$proj_path"
        done
      done
    fi
  elif [[ -n "${event_paths[@]}" && -n "${proj_file_paths[@]}" ]]; then
    # proj_file--(hard link)--event/
    for proj_file_path in "${proj_file_paths[@]}"; do
      for event_path in "${event_paths[@]}"; do
        ln "$proj_file_path" "$event_path"
      done
    done
  fi

}
