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

# Start time
TIME=$(date -d "+10 seconds" +%Y%m%dT%H%M%S) #-Iseconds
echo "Start simulation at: $TIME"

# Simulation params
OPTS="--timestep 1 --duration $((300)) --system-freq 50 --start-at $TIME --solver-domain SP --solver-type NRP"
echo "Simulation params: $OPTS"

CPS_LOG_PREFIX="[Sys ] " \
build/dpsim-villas/examples/cxx/UDP_CIGRE_MV_PowerFlowTest_LoadProfiles $OPTS
