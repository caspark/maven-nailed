#!/bin/bash

# Stops any running nvn-server, executes compile twice using nvn, then stops nvn-server again.

MAVEN_VERSION=$1

MVN_NAILGUN_PORT=45785 # should match the value in nvn.sh
NVN_CMD=target/apache-maven-$MAVEN_VERSION/bin/nvn

function stop_nvn_server {
  echo "Shutting down nvn by executing 'nvn --stop'"
  $NVN_CMD --stop

  if [[ $? -ne 0 ]]; then
    echo "Shutting down nvn by using 'nvn --stop' failed; failing integration-test"
    exit 4
  fi

  echo "Waiting a bit and then checking server is shutdown"
  sleep 0.5

  NVN_PID=$(lsof -i tcp:$MVN_NAILGUN_PORT | awk 'NR!=1 {print $2}')
  if [[ ! -z $NVN_PID ]]; then
    echo "nvn-server still appears to be running after executing 'nvn --stop'; failing integration-test"
    lsof -i tcp:$MVN_NAILGUN_PORT
    exit 5
  fi
}

echo "Making sure stopping nvn-server works when there's no server running"
stop_nvn_server

echo "Testing nvn by executing 'nvn compile' for the first time"
TIMEFORMAT=%R
exec 3>&1 4>&2
FIRST_TIME=$( { time $NVN_CMD compile 1>&3 2>&4; } 2>&1 )
exec 3>&- 4>&-

if [[ $? -ne 0 ]]; then
  echo "First 'nvn dependency:tree' invocation failed; failing integration-test"
  exit 1
fi

echo "Time of first compile was $FIRST_TIME seconds"

echo "Testing nvn by executing 'nvn compile' for the second time, which should be faster"
exec 3>&1 4>&2
SECOND_TIME=$( { time $NVN_CMD compile 1>&3 2>&4; } 2>&1 )
exec 3>&- 4>&-

if [[ $? -ne 0 ]]; then
  echo "Second 'nvn dependency:tree' invocation failed; failing integration-test"
  exit 2
fi

echo "Time of second compile was $SECOND_TIME seconds"

echo "Checking that second compile took less time than first compile"

if ! awk "{ exit ($FIRST_TIME <= $SECOND_TIME) }" < /dev/null ; then
  echo "First compile was faster than second compile; failing integration-test"
  exit 3
fi

echo "Making sure stopping nvn-server works when there is a server running"
stop_nvn_server

echo "Integration test successful!"
