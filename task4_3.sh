#!/bin/bash

PATH_TO_BACKUPDIR=${1}
NUMBER_BACKUPS=${2}
BACKUP_FOLDER="/tmp/backups/"
PARAM_QUANTITY=$#

function verifications() {
  if [ ${PARAM_QUANTITY} -ne 2 ]; then
    echo "ERROR: wrong number of parameters" 1>&2
    exit 1
  elif ! [ -d "${PATH_TO_BACKUPDIR}" ]; then
    echo "ERROR: directory does not exist" 1>&2
    exit 2
  elif [ -z "${NUMBER_BACKUPS##*[!0-9]*}" ] || [ "${NUMBER_BACKUPS}" -eq 0 ]; then 
    echo "ERROR: the second parameter must be a positive number" 1>&2
    exit 3
  fi

  if ! [ -d "${BACKUP_FOLDER}" ]; then
    mkdir "${BACKUP_FOLDER}"
  fi
}

function backup() {
  local backup_name=$(echo "${PATH_TO_BACKUPDIR}" | sed "s#/##; s/\/$//; s#/#-#g")
  local time_stamp=$(date +%Y-%m-%d-%H%M%S)
  local archive_name="${backup_name}.${time_stamp}.tar.gz"
  local tail_counter=$(echo ${NUMBER_BACKUPS}+1 | bc)
  cd "${PATH_TO_BACKUPDIR}"
  tar -cvzf "${archive_name}" * >> /dev/null 
  mv "${archive_name}" "${BACKUP_FOLDER}"
  echo "---Backup completed! ${archive_name} saved---"
  cd ${BACKUP_FOLDER}
  if ls -t | grep -F " " >> /dev/null; then
    IFS=$'\n'
  fi
  rm $(ls -t | grep -F "${backup_name}." | tail --lines=+${tail_counter}) >> /dev/null 2>&1
  IFS=$' '
  echo "---You have ${NUMBER_BACKUPS} backups of the directory: ${PATH_TO_BACKUPDIR}---"
}

verifications
backup
