#!/bin/bash
ls ~/tmp/*a
ls "~/tmp/*a"
tmp_path="~/tmp"
string="${tmp_path}/*a"
echo "string=$string"
ls $string
