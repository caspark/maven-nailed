#!/bin/bash

# Nailed-gunned version of Maven
# Runs nvn-server if it isn't already running, then invokes nvn

MVN_NAILGUN_PORT=45785

# get the source location for this script; handles symlinks
function get_script_path {
  local source="${BASH_SOURCE[0]}"
  while [ -h "$source" ] ; do
    local linked="$(readlink "$source")"
    local dir="$(cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd)"
    source="$dir/$(basename "$linked")"
  done
  echo ${source}
}

# script details
declare -r script_path=$(get_script_path)
declare -r script_dir="$(cd -P "$(dirname "$script_path")" && pwd)"

function check_port {
  nc -z -n -w 1 127.0.0.1 $1 > /dev/null 2>&1
}

if [[ $1 == "--stop" ]]; then
  echo -n "Stopping server listening on port $MVN_NAILGUN_PORT..."
  PIDS_TO_KILL=$(lsof -i tcp:$MVN_NAILGUN_PORT | awk 'NR!=1 {print $2}')
  if [[ -z $PIDS_TO_KILL ]]; then
    echo " no server was running."
  else
    ( lsof -i tcp:$MVN_NAILGUN_PORT | awk 'NR!=1 {print $2}' | xargs kill -9 ) && echo " stopped."
  fi
  exit 0
fi


# start nailgun if not already running
if ! check_port $MVN_NAILGUN_PORT ; then
  echo -n "nvn-server does not appear to be running on port $MVN_NAILGUN_PORT; starting..."
  $script_dir/nvn-server localhost:$MVN_NAILGUN_PORT > /dev/null 2>&1 &
  # $HOME/var/apache-maven-3.0.5/bin/mvn-ng-server localhost:$MVN_NAILGUN_PORT > /dev/null 2>&1 &

  # give some time for startup
  attempts=50
  while ! check_port $MVN_NAILGUN_PORT ; do
    [[ $attempts -eq 0 ]] && exit 1
    attempts=$((attempts - 1))
    sleep 0.1
  done
  echo " started."
fi

$script_dir/ng com.asparck.maven.nailed.Client --nailgun-port $MVN_NAILGUN_PORT "$@"
# $script_dir/ng com.github.nigelzor.maven.nailgun.Client --nailgun-port $MVN_NAILGUN_PORT "$@"

