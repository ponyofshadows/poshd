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
## create events using time words:[m,noon,a,n,now, td, ytd,tmrw,+7d,-6h, etc..]
po -e:noon play vedio games
po -e:tmrw+now play vedio games
po -e:-3d2h play vedio games
## delete a event(Match the most recent event.
po -rm study math

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
po -p:hide shadow plan
## Deleting an active project will cause all copies of it to be deleted during backup; however, for a hidden project, it will be confirmed that at least one copy exists before deleting the original. 
po -rm -p master plan
po -p:rm shadow plan
## Deleted hidden projects can be restored. The original will be restored when a copy is found on the backup disk
po -p:restore shadow plan

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
## Process backup for mounted backup disks
po -b "/mnt"
## Recover form a disk
po -r "/mnt"
```
