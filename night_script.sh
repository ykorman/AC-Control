#!/bin/bash -e

DIR=$(dirname $0)
B=${DIR}/broadlink-cli
SLEEP_CMD="sleep 1m"
DEV_CONFIG=${DIR}/device_config

START_DELAY=${START_DELAY:-50}
TIMER_ON=${TIMER_ON:-10}
TIMER_OFF=${TIMER_OFF:-50}

STATUS_FILE=/run/$(basename $0).status

if [[ ${EUID} != 0 ]] ; then
	STATUS_FILE=${DIR}/.$(basename $0).status
fi

# debug
if [[ -n ${DEBUG} ]] ; then
	SLEEP_CMD="break"
fi

log() {
	echo $(date +%H:%M) -- $*
}

setup() {
	source ${DIR}/env/bin/activate
	${B}/broadlink_discovery | tail -n3 | head -n1 > ${DEV_CONFIG}
	log "Generated device config:"
	cat ${DEV_CONFIG}
	echo
}

cmd() {
	if [[ -z ${DEBUG} ]] ; then
		${B}/broadlink_cli --device @${DIR}/device_config --send $*
	else
		log "!DEBUG! Executing cmd with $*"
	fi
}

msleep() {
	local amount=$1
	local i=0

	log "Sleeping for ${amount} minutes"
	while [[ ${i} -lt ${amount} ]] ; do
		echo "$((amount - i)):${2}" > ${STATUS_FILE}
		echo -n .
		${SLEEP_CMD}
		let i++ || :
	done
	echo
}


main() {
	setup

	msleep ${START_DELAY}
	while true ; do
		# turn ac on
		log "Turning AC on (26 degrees)"
		cmd @${DIR}/cmds/ac_hot.26
		msleep ${TIMER_ON} "on"
		log "Turning AC off"
		cmd @${DIR}/cmds/ac.off
		msleep ${TIMER_OFF}
		if [[ -n ${DEBUG} ]] ; then
			break
		fi
	done
}

if [[ "${1}" == "status" ]] ; then
	cat ${STATUS_FILE}
	exit 0
fi

main
