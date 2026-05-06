#!/bin/bash

set -x

_stop() {
        echo "Caught SIGTSTP signal!"
        kill -TSTP ${CHILDS} 2>/dev/null
}

_cont() {
        echo "Caught SIGCONT signal!"
        kill -CONT ${CHILDS} 2>/dev/null
}

_term() {
        echo "Caught SIGTERM signal!"
        kill -TERM ${VN} ${CHILDS} 2>/dev/null
}

_kill() {
        echo "Caught SIGKILL signal!"
        kill -KILL ${VN} ${CHILDS} 2>/dev/null
}

trap _stop SIGTSTP
trap _cont SIGCONT
trap _term SIGTERM
trap _kill SIGKILL

CHILDS=""

if [ -z "${VILLAS_PAYLOAD_FILE}" ]; then
        export VILLAS_PAYLOAD_FILE=/config/payload.json
fi

#some defaults
DEFAULT_TIMESTEP="1"
DEFAULT_DURATION="300"
DEFAULT_FREQ="50"
DEFAULT_START_AT=$(date -d "+10 seconds" +%Y%m%dT%H%M%S)
DEFAULT_DOMAIN="SP"
DEFAULT_SOLVER="NRP"
DEFAULT_IP="localhost"
DEFAULT_PORT="8080"

if [ -f "$VILLAS_PAYLOAD_FILE" ]; then
    echo "Found payload at $VILLAS_PAYLOAD_FILE, parsing values..."
    TIMESTEP=$(jq -r ".parameters.timestep // \"$DEFAULT_TIMESTEP\"" "$VILLAS_PAYLOAD_FILE")
    DURATION=$(jq -r ".parameters.duration // \"$DEFAULT_DURATION\"" "$VILLAS_PAYLOAD_FILE")
    FREQ=$(jq -r ".parameters.[\"system-frequency\"] // \"$DEFAULT_FREQ\"" "$VILLAS_PAYLOAD_FILE")
    START_AT=$(jq -r ".parameters.[\"start-at\"] // \"$DEFAULT_START_AT\"" "$VILLAS_PAYLOAD_FILE")
    DOMAIN=$(jq -r ".parameters.domain // \"$DEFAULT_DOMAIN\"" "$VILLAS_PAYLOAD_FILE")
    SOLVER=$(jq -r ".parameters.solver // \"$DEFAULT_SOLVER\"" "$VILLAS_PAYLOAD_FILE")
    export RECEIVER_IP=$(jq -r ".parameters.receiver_ip // \"$DEFAULT_IP\"" "$VILLAS_PAYLOAD_FILE")
    export UDP_PORT=$(jq -r ".parameters.udp_port // \"$DEFAULT_PORT\"" "$VILLAS_PAYLOAD_FILE")
else
    echo "No payload found, using system defaults."
    TIMESTEP=$DEFAULT_TIMESTEP
    DURATION=$DEFAULT_DURATION
    FREQ=$DEFAULT_FREQ
    START_AT=$DEFAULT_START_AT
    DOMAIN=$DEFAULT_DOMAIN
    SOLVER=$DEFAULT_SOLVER
    export RECEIVER_IP=$DEFAULT_IP
    export UDP_PORT=$DEFAULT_PORT
fi

OPTS="--timestep $TIMESTEP --duration $DURATION --system-freq $FREQ --start-at $START_AT --solver-domain $DOMAIN --solver-type $SOLVER"
echo "Final Simulation Params: $OPTS"
echo "Networking: $RECEIVER_IP:$UDP_PORT"

CPS_LOG_PREFIX="[Sys ] " \
build/dpsim-villas/examples/cxx/UDP_CIGRE_MV_PowerFlowTest_LoadProfiles $OPTS
