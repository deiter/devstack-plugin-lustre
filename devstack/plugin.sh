# Devstack Lustre plugin

function init_cinder_backend_lustre {
    local backend="$1"

    if ! mount.lustre -h; then
        echo 'Required package lustre-client is not installed'
	exit 1
    fi
}

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

function cleanup_cinder_backend_lustre {
    local backend="$1"
    local mount_base="$DATA_DIR/cinder/mnt"

    if [[ -d "$mount_base" ]]; then
        mount -t lustre | awk '$3 ~ "^'$mount_base'" {print $3}' | xargs -r -t -L1 sudo umount -l
    fi
}

function configure_tempest_lustre {
    iniset $TEMPEST_CONFIG volume-feature-enabled snapshot True
    iniset $TEMPEST_CONFIG volume-feature-enabled backup False
    iniset $TEMPEST_CONFIG volume-feature-enabled clone True
    iniset $TEMPEST_CONFIG volume-feature-enabled manage_snapshot False
}

if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
    true
elif [[ "$1" == "stack" && "$2" == "install" ]]; then
    true
elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
    true
elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
    true
elif [[ "$1" == "stack" && "$2" == "test-config" ]]; then
    configure_tempest_lustre
elif [[ "$1" == "unstack" ]]; then
    true
elif [[ "$1" == "clean" ]]; then
    true
fi
