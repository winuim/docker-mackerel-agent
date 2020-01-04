#!/bin/bash -eu

[[ -v DEBUG ]] && ${DEBUG} && set -x

if [[ -v MACKEREL_APIKEY ]]; then
    /go/bin/mackerel-agent init -conf etc/mackerel-agent.conf -apikey=${MACKEREL_APIKEY}
fi

case ${1} in
    run)
        /go/bin/mackerel-agent -conf etc/mackerel-agent.conf -v
        ;;
    *)
        exec "$@"
        ;;
esac
