#!/bin/bash

if [ "${REDIS_PASS}" == "**Random**" ]; then
    unset REDIS_PASS
fi

# Set initial configuration
if ([ ! -f /.redis_configured ]); then

    unset REDIS_VERSION REDIS_DOWNLOAD_URL REDIS_DOWNLOAD_SHA1

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
        i=$(echo $i | sed "s/REDIS_//" | sed "s/_/-/" | sed "s/^[^ ]*/\L&\E/")
        IFS='=' read -a conf <<< "${i}"
        # Replace existing configuration file lines with environment variables, or
        # saving the new values to the configuration file.
        if [ $( grep -ic "${conf[0]}" /usr/local/etc/redis/redis.conf ) -ge 1 ]
        then
            sed -i "s/${conf[0]}.*/${conf[0]} ${conf[1]}/g" /usr/local/etc/redis/redis.conf
        else
            echo ${conf[0]} " " ${conf[1]}  >> /usr/local/etc/redis/redis.conf
        fi
    done

    echo "=> Using redis.conf:"
    cat /usr/local/etc/redis/redis.conf | grep -v "requirepass"

    touch /.redis_configured
fi

redis-server /usr/local/etc/redis/redis.conf
