#!/bin/bash
#
## object.sh
#

po_complete_object(){
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

