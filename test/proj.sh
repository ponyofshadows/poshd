#!/bin/bash
# test: po -p
./po --init
echo "[test] add a new project and a new hidden project"
./po --debug -p:active master plan -p:hide love
echo "[test] add a project with floder"
./po --debug -p play/screenshots
echo "[test] active a hidden project; move file into two projects"
touch /tmp/test/s1.png
touch /tmp/test/s2.png
echo "------------tree before-----------------"
tree -a /tmp/test
echo "----------------------------------------"
./po --debug -f "/tmp/test/s*.png" -p:active love/images/screenshots -p "play/s*s"
echo "------------tree after-----------------"
tree -a /tmp/test
echo "----------------------------------------"
echo "[test] hide a project; remove a project"
./po --debug -p:hide master plan -p --rm love 
echo "------------tree-----------------"
tree -a /tmp/test
echo "---------------------------------"
echo "[test] link project files to event"
./po --debug -p:file "play/screenshots/*" -e play screenshots
echo "------------tree-----------------"
tree -a /tmp/test
echo "---------------------------------"
echo "[test] mv a file into projects and events"
touch /tmp/test/info.yaml
./po --debug -f /tmp/test/info.yaml -e play screenshots/doc -p play/doc -p master plan/doc
echo "------------tree-----------------"
tree -a /tmp/test
echo "---------------------------------"

echo "[test] done"
rm -rf  /tmp/test


