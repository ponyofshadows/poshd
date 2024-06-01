#!/bin/bash
ls ~/tmp/*a
pattern="~/tmp/*a"
matched=( $(eval echo $pattern) )
ls "$pattern"
ls "${matched[@]}"
