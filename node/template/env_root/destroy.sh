#!/bin/bash

[ -z $ORGCODEDIR ] && ORGCODEDIR="$(cd "$(dirname $(greadlink -f "$0"))" && pwd -P)"
export ORGCODEDIR=${ORGCODEDIR}

. ${ORGCODEDIR}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source
. ${ORGCODEDIR}/ind-steps/functions.bash
. ${LINKCODEDIR}/datadir.conf

method="destroy"
[[ $1 == "--kill" ]] && method="kill"

destroy="${method}" execute ${IND_STEPS[@]}
