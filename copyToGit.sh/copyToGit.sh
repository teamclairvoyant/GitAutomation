#!/bin/bash


SCRIPT_NAME=$(basename $0)
LOG_FILE="./paypal.${SCRIPT_NAME}.$(date '+%Y%m%d%H%M%S').log"
ERROR_LOG_FILE="./paypal.${SCRIPT_NAME}.$(date '+%Y%m%d%H%M%S').error"

find ./ -name "*.error" -exec rm -rf {} \;
find ./ -name "*.log" -exec rm -rf {} \;

f_write_log()
{
  local to_be_logged="$(date '+%Y%m%d %H:%M:%S') | $1"
  echo -e "${to_be_logged}" | tee -a ${LOG_FILE}
}

f_write_error_log()
{
  #write error logs into a separate file.
  local to_be_logged="$(date '+%Y%m%d %H:%M:%S') | $1"
  echo -e "${to_be_logged}" | tee -a ${ERROR_LOG_FILE}
}

if [ $# -gt 2 -o $# -lt 2 ]; then
    f_write_error_log "XML file consisting of all paths and file containing all that needs to be copied must be provided as arguments"
    f_write_error_log "Usage: sh copyToGit.sh <xml_file> <file_having_details of copy>"
    exit 1
fi

xml_file=$1
input_file=$2


if [[ ! -s input.txt ]]
then
	f_write_error_log "Input file is empty.Exiting"
	exit 1
else
	grep -q '[^[:space:]]' ./input.txt
	if [ $? -eq 1 ]; then
        	f_write_error_log "File only has empty lines or whitespaces"
        	exit 1
	fi
fi

sshLogin=$(ssh -T git@github.com 2>&1 | grep "Permission denied")
echo $sshLogin
if [ -z "$sshLogin" ]
then
     	f_write_log "User has succesfully authenticated.Proceeding with the script"	
else
	f_write_error_log "Please setup ssh key in your github account"
        exit 1
fi


CURR_DIR=`pwd`
BRANCH=`awk '/<name>BRANCH/{getline;print $3}' FS="[<>]" $xml_file`
echo "$BRANCH"
REPO=`awk '/<name>REPO/{getline;print $3}' FS="[<>]" $xml_file`
TARGET_DIR=`awk '/<name>TARGET_DIR/{getline;print $3}' FS="[<>]" $xml_file`
HOME_DIR=`awk '/<name>HOME_DIR/{getline;print $3}' FS="[<>]" $xml_file`


f_write_log "HOME DIR : $HOME_DIR"
f_write_log "TARGET DIR : $TARGET_DIR"



if [ ! -d "$HOME_DIR" ]
then
	f_write_error_log "$HOME_DIR does not exist"
	exit 1
fi
if [ ! -d "$TARGET_DIR" ]
then
	f_write_error_log "$TARGET_DIR does not exist"
	exit 1
	
fi

if [ -d "$TARGET_DIR"/.git ]; then
	# repo already exists
	cd "$TARGET_DIR"
	cat "$TARGET_DIR"/.git/config | grep $REPO > /dev/null
	if [ $? -ne 0 ]; then
		f_write_error_log "The repo given in xml is different from the one in config. Try setting the url with command 'git remote ser-url origin $REPO in the $TARGET_DIR'"
		exit 1
	fi
        
	git remote set-url origin $REPO 	
	git fetch #fetches new branches if any

	branch_yes=`git rev-parse --verify --quiet $BRANCH`
	if [ ! "$branch_yes" ]; then
		f_write_error_log "Branch does not exist.exiting"
		exit 1
	fi
	

	git checkout $BRANCH #checking out branch for copying changes
	cd "$CURR_DIR"
else
	f_write_error_log "There is no repository on the target dir.Exiting"
	exit 1
fi

while read d;
do

        dir_name=`echo ${d%/*}`
	[ ! -d "$TARGET_DIR"/"$dir_name" ] && mkdir -p "$TARGET_DIR"/"$dir_name"
        /bin/cp -r "$HOME_DIR"/$d "$TARGET_DIR"/$d

done < $input_file 

#Git commands to push all the changes

cd "$TARGET_DIR"

while read f;
do
	git add "$TARGET_DIR"/$f
done < $input_file

echo -n "Please enter your commit message:"
read commit
git commit -m "$commit"

git push -u $REPO $BRANCH
if [ $? -eq 0 ]; then
        f_write_log "Changes are successfully pushed"
        exit 0
fi


