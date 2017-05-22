#!/bin/bash

[ -z $ORGCODEDIR ] && ORGCODEDIR="$(cd "$(dirname $(greadlink -f "$0"))" && pwd -P)"
export ORGCODEDIR=${ORGCODEDIR}

. ${ORGCODEDIR}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source
. ${ORGCODEDIR}/ind-steps/functions.bash
. ${LINKCODEDIR}/datadir.conf

[[ ${LINKCODEDIR} == ${ORGCODEDIR} ]] && { level="Environment" ; } || { level="${LINKCODEDIR##*/}" ; }

if [[ "${level}" == "Environment" ]] ; then
    destroy_node "${NODES[@]}"
else
    destroy_node "${LINKCODEDIR}"
done
