# Devstack Lustre plugin

function configure_cinder_backend_lustre {
    local backend="$1"
    local prefix="LUSTRE_OPTGROUP_${backend}_"
    local item

    for item in $(set | grep "^$prefix"); do
        local opt="${item#$prefix}"
        local name="${opt%%=*}"
        local value="${opt#*=}"

        iniset "$CINDER_CONF" "$backend" "$name" "$value"
    done
}

function configure_tempest_lustre {
    iniset $TEMPEST_CONFIG volume-feature-enabled snapshot True
    iniset $TEMPEST_CONFIG volume-feature-enabled backup False
    iniset $TEMPEST_CONFIG volume-feature-enabled clone True
    iniset $TEMPEST_CONFIG volume-feature-enabled manage_snapshot False
}

if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
    true
elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
    true
elif [[ "$1" == "stack" && "$2" == "test-config" ]]; then
    configure_tempest_lustre
elif [[ "$1" == "unstack" ]]; then
    if [[ -d ${DATA_DIR}/cinder/mnt ]]; then
        mount -t lustre | awk '{print $3}' | grep "^${DATA_DIR}/" | xargs -r -t -L1 sudo umount -l
    fi
fi
