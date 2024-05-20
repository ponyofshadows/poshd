# poshd
A simple way to record life and archive files based on Linux Shell

## Abstract
- Save all valuable files under `~/all/`
- Archive files as projects under `all/proj`
- Under `all/list/`, record life and archive files in chronological order, and you can associate files under `all/proj/` in the form of hard links.
- In addition to `rsync` for backup, it only relies on some commands that come with the Linux shell, such as `cd`, `ls` and `date`.

## Example Path Tree
```
all/
|__ list/                            ##
    |__ 24051809event1/              ## Date&Time + EventTitle
    |__ 24051813event2@proj1/        ## There exist hard links
    |__ 24051821event3@proj1@proj2/  ##
|__ proj/                            ##
    |__ proj1/                       ##
|__ .hidden_proj/                    ##
    |__ proj2/                       ## Deleting a hidden proj will not affect its backups on other disks
|__ .mnt/                            ##
    |__ .disk1/                      ## Disks that are no longer in use are marked with "."
    |__ disk2/                       ##
```

## Usage
```bash
#
# Begin
#
## create necessary paths and files
po -init

#
# New Events
#
## ' ' will be replaced by '_'
po event one 
po -e:24051810 event two
## create events using time words:[td,m,noon,a,n,now; ytd,tmrw,+7d,-6h]
po -e:noon play vedio games
po -e:tmrw+now play vedio games
po -e:-3d2h play vedio games
## delete a event(Match the most recent event. The default search time range is this month)
po -rm study math
po -rm:whole study English

#
# View Events
#
## list recent events. 
po
po -l
## list events during certain dates
po -l:whole
po -l:0512,0519
po -l:231024,0519
po -l:ytd,tmrw+n
## find events using keywords
po -l vedio games
po -l:whole vedio games

#
# Projects
#
## Create a new project or do something on a project
po -p master plan
po -p:active master plan
po -p:hide master plan
po -rm -p master plan

#
# Archive Files
#
## from normal path, move the file
po -f ~/Downloads/example.png -e:play vedio game
po -f ~/Downloads/example.png -e:-2h play vedio game/screentshots/
po -f ~/Downloads/example.png -p master plan/resources/img/
## from projects to events, create hard link
po play vedio game -p master plan/resources/img/*

#
# Backup
#
## add or give up a new disk directory
po -d disk0
po -rm -d disk0
## Process backup for all mounted backup directories
po -b
## Process backup regardless of minimum interval of each disks.
po -b:all
## Recover form a disk
po -r -d disk0
```
