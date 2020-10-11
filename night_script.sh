#!/bin/bash -e

DIR=$(dirname $0)
B=${DIR}/broadlink-cli
SLEEP_CMD="sleep 1m"

# debug
if [[ -n ${DEBUG} ]] ; then
	SLEEP_CMD="break"
fi

setup() {
	${B}/broadlink_discovery | tail -n3 | head -n1 > ${DIR}/device_config
}

log() {
	echo $(date +%H:%M) -- $*
}

msleep() {
	local amount=$1
	local i=0

	log "Sleeping for ${amount} minutes"
	while [[ ${i} -lt ${amount} ]] ; do
		echo -n .
		${SLEEP_CMD}
		let i++ || :
	done
	echo
}

setup

msleep 50
while true ; do
	# turn ac on
	log "Turning AC on (26 degrees)"
	${B}/broadlink_cli --device @${DIR}/device_config --send @${DIR}/cmds/ac.26
	msleep $((9))
	log "Turning AC off"
	${B}/broadlink_cli --device @${DIR}/device_config --send @${DIR}/cmds/ac.off
	msleep 50
done
