#!/bin/bash

simple_usage ()
{
    printf "  %s\t\t%s\n" "init" "Initialize environment from configuration file"
}

do_for_os_distro ()
{
    [[ ${1} == *"Darwin"* ]] || return 0
    sed -i '' "s/readlink/greadlink/g" "${PWD}/build.sh"
    sed -i '' "s/readlink/greadlink/g" "${PWD}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source"
    sed -i '' "s/cd -P \/proc.*//g" "${PWD}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source"
}

[[ "$1" == "simple_usage" ]] && { simple_usage ; exit 1 ; }
[[ -f $PWD/.envfile ]] && { echo "[ERROR] envfile already exists, exiting." ; exit 1 ; }

echo "Initializing environment struture"
cat <<EOF > ${PWD}/.envfile
env_root_path=${PWD}
EOF

mkdir -p ${PWD}/nodes
mkdir -p ${PWD}/external_libraries/functions
cp ${root_path}/node/template/env_root/* ${PWD}
cp ${root_path}/functions.bash ${PWD}/external_libraries/functions/utility.bash
cp -r ${root_path}/step/template/ind-steps ${PWD}

git clone https://github.com/axsh/bashsteps.git ${PWD}/external_libraries/bashsteps

do_for_os_distro "$(uname -v | awk '{ print $1 }')"
