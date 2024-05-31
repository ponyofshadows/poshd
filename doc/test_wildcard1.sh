#!/bin/bash
ls ~/tmp/*a

echo "*** ()1 ***"
tmp_path1=~/tmp
string_list1=( ${tmp_path1}/*a )
ls "${string_list1[@]}" 
echo "*** ()2 ***"
tmp_path2="~/tmp"
string_list2=( ${tmp_path2}/*a )
ls "${string_list2[@]}" 

