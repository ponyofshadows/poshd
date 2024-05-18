# poshd
A simple way to record life and archive files based on Linux Shell

## Notion
- Save all valuable files under `~/all/`
- Archive files as projects under `all/proj`
- Under `all/list/`, record life and archive files in chronological order, and you can associate files under `all/proj/` in the form of hard links.
- Under `all/.bak`, store the necessary information when backing up files. Use rsync to back up to paths on other disks according to certain rules.
- In addition to rsync, it only relies on some commands that come with the Linux shell, such as `cd` and `ls`.
- File and pathnames contain almost all archive information.

## Example Path Tree
```
all/
|__ list/                            ##
    |__ 24051809event1/              ## Date&Time + EventTitle
    |__ 24051813event2@proj1/        ## There is a hard link to the file under a specific proj
    |__ 24051821event3@proj1@proj2/  ##
    |__ .24051911event4/             ## Use "." to mark events that will occur in the relatively distant future. 
|__ proj/                            ##
    |__ proj1/                       ##
    |__ .proj2/                      ## If there are two or more backups, 
                                     ## the original proj marked with "." will be deleted.
    |__ ..proj3/                     ## The proj marked with ".." will be deleted from 
                                     ## the original and backup files, but the empty path will be retained.
|__ .bak/                            ##
    |__ backup_info.yaml             ##
    |__ mnt/                         ##
        |__ .disk1/                  ## Disks that are no longer in use are marked with "."
        |__ disk2/                   ##
```

## Configuratin
Look for "$XDG\_CONFIG\_HOME/poshd/config.yaml", "~/.config/poshd/config.yaml" and "/etc/poshd/config.yaml" in turn as the user's configuration file.

Below is the default configuration.
```yaml
archive_path: "~/all"
minimum_cold_backups: 2
days_near_future: 7
past_days_under_consideration: 7
minimum_backup_interval: 1
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
po -t:24051810 event two
## create events using time words:[td,m,noon,a,n,now; ytd,tmrw,+7d,-6h]
po -t:noon play vedio games
po -t:tmrw+now play vedio games
po -t:-3d2h play vedio games
## delete a event(Match the most recent event. The default search time range is the past 7 days)
po -rm study math
po -rm:30 study physics
po -rm:whole study English

#
# View Events
#
## list events from $past_days_under_consideration days ago to $days_near_future days after. 
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
## Create a new project or set status of a project
po -p master plan
po -p:active master plan
po -p:cold master plan
po -p:deleted master plan

#
# Archive Files
#
## from normal path, move the file
po -a ~/Downloads/example.png play vedio game
po -a ~/Downloads/example.png -t:-2h play vedio game/screentshots/
po -a ~/Downloads/example.png -p master plan/resources/img/
## from projects to events, create hard link
po play vedio game -p master plan/resources/img/*

#
# Backup
#
## add or give up a new disk directory
po -d disk0
po -d:hide disk0
## Process backup for all mounted backup directories
po -b
## Process backup regardless of minimum interval of each disks.
po -b:all
## Recover form a disk
po -r disk0
```
