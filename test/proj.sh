#!/bin/bash
# test: po -p
./po --init
echo "[test] add a new project and a new hidden project"
./po --debug -p master plan -p:hide love
echo "[test] add a project with floder"
./po --debug -p play/screenshots
echo ""
