#!/bin/bash
# restore full snapshot from latest backup per default
indir=$(ls -t1d --group-directories-first /data/backup/DB_FULL_DUMP/* | head -n 1)
dry_run=false

usage() {
  echo -n "

Usage: $(basename "$0") [OPTIONS]

  Restore everything from mongodump archives within
  '--indir INDIR' (default: '${indir}') using 'mongorestore'.

Options:

  -h, --help
  -n, --dry-run     Show databases in filter, but don't actually dump.
  -i, --indir      Output directory.
"
}

args=$(getopt -n "$0" -l "help,dry-run,indir:" -o "hni:" -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$args"

while true; do
  case "$1" in
    -h | --help ) usage ; exit 0 ;;
    -n | --dry-run ) dry_run=true; shift;;
    -o | --indir ) indir="$2"; shift ; shift;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

source init_static_params.sh

log $LOG_MESSAGE_INFO "[INFO] Input directory: '$(readlink -f ${indir})'"
log $LOG_MESSAGE_INFO "[INFO] Current content:"
ls -lha "${indir}"

if [ "${dry_run}" == false ]; then
    mongorestore ${SSL_OPTS} ${AUTH_OPTS} --oplogReplay --gzip --verbose "${indir}"
fi
