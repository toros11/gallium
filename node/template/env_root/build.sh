#!/bin/bash

[[ -z $ORGCODEDIR ]] && ORGCODEDIR="$(cd "$(dirname $(readlink -f "$0"))" && pwd -P)"
. ${ORGCODEDIR}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source
export ORGCODEDIR

. ${ORGCODEDIR}/ind-steps/functions.bash
. ${LINKCODEDIR}/datadir.conf

IND_STEPS=($(cat ${LINKCODEDIR}/steplist.conf))

[[ ${LINKCODEDIR} == ${ORGCODEDIR} ]] && { level="Environment" ; } || { level="${LINKCODEDIR##*/}" ; }
echo "=======> building $level:"

execute ${IND_STEPS[@]}
