#!/bin/bash
# test: po -e

./po --init
echo "[test] add a new event"
./po --debug -e test my scripts
echo "[test] add an event from yesterday"
./po --debug -e:ytd debug
echo "[test] add a morning event 100 days later"
./po --debug -e:m+100d play Kingdom Come: Deliverance II
echo "[test] add an event with floder"
./po --debug -e:tmrw+a study English/note
echo "[test] move files into path under an event" 
touch /tmp/test/Hamilton.txt
touch /tmp/test/my_little_pony.txt
echo "(tree-before)"
tree /tmp/test/all/event
./po --debug -f "/tmp/test/*.txt" -e:tmrw study "Eng*/n*te"
echo "(tree-after)"
tree /tmp/test/all/event
echo "[test] remove an event"
./po --debug --rm -e:m+100d play Kingdom Come: Deliverance II
tree /tmp/test/all/event
echo "[test] end"
rm -rf /tmp/test



