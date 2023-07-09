#!/bin/sh
#backup and restore config files

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# add file names to a file specified in CONFIGS_LIST

# Initallize variables
#
BACKUP_PATH="/mnt/v1/backup/ssh"
BACKUP_NAME="ssh.tar.gz"
RESTORE_PATH="/usr/local/etc/ssh"
#
#

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/backupssh-config
RELEASE=$(freebsd-version | cut -d - -f -1)"-RELEASE"

# Check for backupssh-config and set configuration
if ! [ -e $SCRIPTPATH/backupssh-config ]; then
  echo "$SCRIPTPATH/backupssh-config must exist."
  exit 1
fi
if [ -z $BACKUP_PATH ]; then
  echo 'Configuration error: BACKUP_PATH must be set'
  exit 1
fi
if [ -z $BACKUP_NAME ]; then
  echo 'Configuration error: BACKUP_NAME must be set'
  exit 1
fi


#
# Ask to Backup or restore, if run interactively
#
if ! [ -t 1 ] ; then
  # Not run interactively
  choice="B"
else
 read -p "Enter '(B)ackup' to backup Nextcloud or '(R)estore' to restore Nextcloud: " choice
fi

echo

if [ "${cron}" == "yes" ]; then
    choice="B"
fi

echo
if [ ${choice} == "B" ] || [ ${choice} == "b" ]; then
    if [ ! -d "${BACKUP_PATH}" ]; then
      mkdir -p ${BACKUP_PATH}
      echo "mkdir -p ${BACKUP_PATH}"
    fi
  # to backup
  #tar --exclude=./*.db-* -zcvf /mnt/v1/apps/sonarrbackup.tar.gz ./
  cd ${CONFIG_PATH}
  echo
  echo "${CONFIG_PATH}"
  tar czvfP ${BACKUP_PATH}/${BACKUP_NAME} -C /usr/local/etc/ssh .
chmod 660 ${BACKUP_PATH}/${BACKUP_NAME}
  echo
  echo "Backup complete file located at ${BACKUP_PATH}/${BACKUP_NAME}"
  echo
elif [ $choice == "R" ] || [ $choice == "r" ]; then
    if [ ! -d "${RESTORE_PATH}" ]; then
      mkdir -p ${RESTORE_PATH}
      echo
      echo "mkdir -p ${RESTORE_PATH}"
      echo
    fi

  tar zvxpf ${BACKUP_PATH}/${BACKUP_NAME} -C ${RESTORE_PATH}
  echo
  echo "tar zvxpf ${BACKUP_PATH}/${BACKUP_NAME} -C ${RESTORE_PATH}"
  echo
  echo "Restore completed at ${RESTORE_PATH}"
  echo
else
  echo
  echo "Must enter '(B)ackup' to backup Config files or '(R)estore' to restore Config files: "
  echo
fi
