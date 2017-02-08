#!/bin/bash

. ${root_path}/functions.bash
. ${abs_path}/functions.bash
require_environment

extractable_args="
    name
    cpu_name
    mem_size
    ind_steps
    vnc
    config
    nic::enum
"

simple_usage()
{
    printf "  %s\t\t%s\n" "add" "Adds an empty node from <template>, if not defined uses default setting"
}

usage ()
{
    cat <<EOF

This command adds a node, the following parameters can be sent as aruments,

  options:

    --template                          Specifies which template from which to clone nodes, by default uses sample

    --name                              Name of the node

    --cpu_num                           Number of cpus the node will get assigned

    --mem_size                          Amount of memory that will be allocated for the node

    --serial                            Specify serial access to the node if required

    --vnc "addr=,port="                 Specfiy vnc access to the node if required

    --nic<n-5>                            Creates a tap device pair for the node, multiple nics can be added.
                                        Each interfae can use the following parameters to customize the tap device pair.

                                          gw      sets default gateway for the interface
                                          ip      sets the ip address for interface 
                                          mac     sets the mac address for interface
                                          bridge  sets the bridge device which the tap will be attached to on the host/
                                          tap     sets the tap device name which will be created on the host.
                                          type    sets what type of interface to represent inside the node

                                        The syntax is to define the values using equal sign(=) like we would do with variables each separated by comma,
                                        and to enclose the whole argument in double quoutes to mark that all of the parameters belong to one nic,

                                        Example:
                                            --nic0 "gw=10.100.0.1,ip-10.100.0.10,mac=02:00:00:00:00:01,tap=test,type=ethernet,bridge=brtest"
                                         
   

    --ind_steps                         These are the steps in order from left to right in which tasks will run on the
                                        node when building the environment, the steps needs to be created (exist in ind-stesp)

    --config                            Use a supplied config file to define the settigngs of the node, note that if this argument is used
                                        no other argument should be, or needs to be supplied, for reference on how to write config files use see
                                        config operations section of node subcommand.
                                        
EOF
}

usage_nics () {
cat <<EOF

EOF
}

template="${1}"
[[ "${template}" == "--help"             ]] && { usage ; exit ; }
[[ "${template}" =~ ^"--"*               ]] && { template="sample" ; } || { shift ; }
[[ "${template}" == "simple_usage"       ]] && { simple_usage ; exit ; }
[[ -d "${abs_path}/template/${template}" ]] || { echo "[ERROR] Invalid template; $template." ; }

args=( "${@}" )
extract_args "${extractable_args}" "${args[@]}"
[[ $? == 1 ]] || {
    [[ -z $name ]] && { name=$(new_node_id) ; }
    [[ -n ${config} && -f ${config} ]] && {
        . ${config}
    }
    #validate_steps "${ind_steps}"
    create_node "${template}" "${name}"
    # render_cfg ${cpu_num} ${mem_size} ${serial} ${vnc}
    # render_vif_cfg ${node_name}
    # render_network ${node_name}

}
