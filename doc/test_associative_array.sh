#!/bin/bash

# a normal associative array
declare -A array0=(["ka"]="va" ["kb"]="vb" ["kc"]="vc")
echo "% echo all elements:"
echo "${array0[@]}"

# Can we treat all the elements as a whole?
# 1) simply echo
echo "% try to echo whole associative array:"
echo "$array0"
## nothing
if [[ -n "$array0" ]]; then
  echo "true"
else
  echo "false"
fi
## false
# 2) indirect reference
array_name="array0"
echo "indirect reference of array0:"
declare -A current_array
eval current_array_value=\${$array_name[@]}
echo "current_array_value=$current_array_value"
## only the keys or the values


# Do associative arrays and variables share the same namespace?
declare -A array1=(["ka"]="va" ["kb"]="vb" ["kc"]="vc")
array1="i am a variable"
echo "array1=$array0"
echo "array1[\"ka\"]=${array0["ka"]}"
# they don't share the same namespace.
