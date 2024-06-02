#!/bin/bash
# generate a example path

./po --init
touch /tmp/test/a_book.txt
./po -e:-10d3h read a book/book -f /tmp/test/a_book.txt
./po -e cry
touch /tmp/test/main
./po -f /tmp/test/main -e test my program/src -p poshd test
./po -p miao miao -p:hide niu niu
touch /tmp/test/kk.png
./po -f /tmp/test/kk.png -p miao miao -p niu niu

./po -l
tree -a /tmp/test 




