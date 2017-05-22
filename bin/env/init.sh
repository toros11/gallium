#!/bin/bash

simple_usage ()
{
    printf "  %s\t\t%s\n" "init" "Initialize environment from configuration file"
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
cp ${root_path}/../lib/* ${PWD}/external_libraries/functions/
cp -r ${root_path}/step/template/ind-steps ${PWD}

git clone https://github.com/axsh/bashsteps.git ${PWD}/external_libraries/bashsteps

# for osx as there is no native readlink
if [[ "$(uname -v | awk '{ print $1 }')" == *"Darwin"* ]] ; then
    sed -i '' "s/readlink/greadlink/g" "${PWD}/build.sh"
    sed -i '' "s/readlink/greadlink/g" "${PWD}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source"
    sed -i '' "s/cd -P \/proc.*//g" "${PWD}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source"
fi
