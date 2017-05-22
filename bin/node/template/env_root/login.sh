#!/bin/bash

ORGCODEDIR="$(cd "$(dirname $(greadlink -f "$0"))" && pwd -P)"

export NODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

node="${1}"
protocol="${2:-ssh}"
in_node=${in_node}

if [[ -z ${in_node} ]] ; then
    [[ "${node}" == "" ]] && {
        echo "Error: missing node name"
        exit 1
    }
    in_node="true" protocol=${protocol} ${ORGCODEDIR}/${node}/login.sh
else
    . "${ORGCODEDIR}/datadir.conf"

    $(sudo kill -0 $(sudo cat "${ORGCODEDIR}/${vm_name}.pid" 2> /dev/null) 2> /dev/null) || {
        echo "Error: node not running"
        exit 1
    }

    [[ ${protocol} == "ssh" ]] &&
        ssh -i ${ORGCODEDIR}/sshkey ${IP_ADDR}
    [[ ${protocol} == "telnet" ]] && {
        telnet_host="${serial%%,*}"
        telnet_host=${telnet_host#*:}
        telnet "${telnet_host%:*}" "${telnet_host#*:}"
    }
fi
