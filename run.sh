#!/bin/bash

# Enable vm.overcommit_memory
sysctl vm.overcommit_memory=1

if [ "${REDIS_PASS}" == "**Random**" ]; then
    unset REDIS_PASS
fi

# Set initial configuration
if [ ! -f /.redis_configured ]; then

    mkdir -p /usr/local/etc/redis
    touch /usr/local/etc/redis/redis.conf

    if [ "${REDIS_PASS}" != "**None**" ]; then
        PASS=${REDIS_PASS:-$(pwgen -s 32 1)}
        _word=$( [ ${REDIS_PASS} ] && echo "preset" || echo "random" )
        echo "=> Securing redis with a ${_word} password"
        echo "requirepass $PASS" >> /usr/local/etc/redis/redis.conf
        echo "=> Done!"
        echo "========================================================================"
        echo "You can now connect to this Redis server using:"
        echo ""
        echo "    redis-cli -a $PASS -h <host> -p <port>"
        echo ""
        echo "Please remember to change the above password as soon as possible!"
        echo "========================================================================"
    fi

    unset REDIS_PASS

    # Backwards compatibility
    if [ ! -z "${REDIS_MODE}" ]; then
        echo "!! WARNING: \$REDIS_MODE is deprecated. Please use \$REDIS_MAXMEMORY_POLICY instead"
        if [ "${REDIS_MODE}" == "LRU" ]; then
            export REDIS_MAXMEMORY_POLICY=allkeys-lru
            unset REDIS_MODE
        fi
    fi

    for i in $(printenv | grep REDIS_); do
        echo $i | sed "s/REDIS_//" | sed "s/_/-/" | sed "s/=/ /" | sed "s/^[^ ]*/\L&\E/" >> /usr/local/etc/redis/redis.conf
    done

    echo "=> Using redis.conf:"
    cat /usr/local/etc/redis/redis.conf | grep -v "requirepass"

    touch /.redis_configured
fi

exec redis-server /usr/local/etc/redis/redis.conf
