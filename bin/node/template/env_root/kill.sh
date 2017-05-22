#!/bin/bash

[ -z $ORGCODEDIR ] && ORGCODEDIR="$(cd "$(dirname $(greadlink -f "$0"))" && pwd -P)"
export ORGCODEDIR=${ORGCODEDIR}

. ${ORGCODEDIR}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source
. ${ORGCODEDIR}/ind-steps/functions.bash
. ${LINKCODEDIR}/datadir.conf

if [[ "${level}" == "Environment" ]] ; then
    kill_node "${NODES[@]}"
else
    kill_node "${LINKCODEDIR}"
done
