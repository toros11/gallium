for node in ${NODES[@]} ; do
    boostraper env build --node "${node}"
done
