#!/bin/bash
#
# SLASS - p_a3server
#
# Author: joka
#
# Description:
# starts and stops a server instance with config file
#
# Parameter(s):
# 1. option { start | stop | status | log} <string>
# 2. scfg file {startparameters_{j}.scfg} <string>
#
# Return Value:
# None <Any>
#
# load arbitrary variables
scfg=$2

if [ -e $scfg ]; then
	source "$2"
else
	printf "$(tput setaf 2)%s$(tput sgr0)$(tput setaf 3)%s$(tput sgr0)%s\n" "[SLASS]" "[Warning]:" "File not found: $2"
	printf "$(tput setaf 2)%s$(tput sgr0)$(tput setaf 3)%s$(tput sgr0)%s\n" "[SLASS]" "[Warning]:" "Maybe the server has been stopped before or was never up."
	exit 0
fi

# load function
source $basepath/slass-data/module/m_fnloader.sh

fn_printMessage "p_a3server: scfg-File $2" "" "debug"

# read usernames, $grpserver needed for Profile
fn_readuser

# set generic variables
serverdir="${basepath}/a3/a3srv${serverid}"
server="${serverdir}/arma3server_x64"

if [[ "$ishc" = true ]]; then
	name="a3srv${serverid}_hc$((${processid}-1))"
else
	name=a3srv${serverid}
fi

pidfile="${serverdir}/${port}_${processid}.pid"
runfile="${serverdir}/${port}_${processid}.run"
profile=${grpserver}
cfg_dir=${serverdir}/cfg
config=${cfg_dir}/${name}.cfg
cfg=${cfg_dir}/basic.cfg
logdir=${basepath}/log
logfile=${logdir}/${name}_$(date +%Y-%m-%d_%H-%M-%S).log
#=======================================================================

case "$1" in
	start)
		# check if there is a server running or not
		echo >>${logfile} "start commmand"
		ps ax | grep ${server} | grep ${config}  > /dev/null

		if [[ $? -eq 0 ]]; then
			fn_printMessage "there is a server already running (${server} at port ${port})" "" "warning"
			fn_printMessage "it can happen, when you started a server and stopped it to fast!" "" "warning"
			fn_printMessage "just stop the server again and it should be good to start!" "" "warning"
			echo $output | ps ax | grep ${server} | grep ${config}
		else
			fn_printMessage "starting a3 server @port ${port}..." ""
			# file to mark we want server running...
			echo "go" > ${runfile}
			# launch the background watchdog process to run the server
			nohup $0 watchdog $scfg >${logfile} 2>&1 </dev/null &
		fi
	;;

	stop)
		fn_printMessage "stopping a3 server if there is one (port=${port})..." ""

		if [ -e ${runfile} ]; then
			# ask watchdog to exit by deleting its runfile...
			rm -f ${runfile}
		else
			fn_printMessage "There is no runfile (${runfile}), server shouldn't be up, will shut it down if it is up!" "" "error"
		fi

		# and terminate server process
		if [ -e ${pidfile} ]; then
			fn_printMessage "sending sigterm to process $(cat ${pidfile})..." ""
			kill -15 $(cat ${pidfile}) || true
			rm -f ${pidfile}
		fi
	;;

	status)
		if [ -e ${runfile} ]; then
			fn_printMessage "runfile exist, server should be up or is starting..." ""
			fn_printMessage "if the server is not done with its start, you will not get a pid file info in the next rows." ""
			fn_printMessage "if the server is done with its start, you will get a pid file and process info in the next rows." ""
		else
			fn_printMessage "runfile doesn't exist, server should be down or is going down..." ""
		fi

		if [ -e ${pidfile} ]; then
			pid=$(< ${pidfile})
			fn_printMessage "pid file exists (pid=${pid})..." ""

			if [ -f /proc/${pid}/cmdline ]; then
				fn_printMessage "server process seems to be running..." ""
				ps ax | grep ${server} | grep ${port}
			fi
		fi
	;;

	watchdog)
		# delete old logs when older then ${logfilelifetime} days
		fn_printMessage "watchdog ($$): [$(date)] deleting all logfiles in ${logdir} when older then ${logfilelifetime} days." ""
		find -L ${logdir} -iname "*.log" -mtime "${logfilelifetime}" -delete

		while [[ -f ${runfile} ]]; do
			# launch the server...
			cd ${serverdir}
			fn_printMessage "watchdog ($$): [$(date)] starting server (port ${port})..." ""

			if [[ "$ishc" = true ]]; then
				${server} >>${logfile} 2>&1 -cfg=${cfg} -client -connect=127.0.0.1 -port=${port} -name=hc ${otherparams} -mod=${mods}&
				pid=$!
				echo $pid > $pidfile
				chmod 664 $logfile
				wait $pid
			else
				${server} >>${logfile} 2>&1 -config=${config} -cfg=${cfg} -port=${port} -name=${profile} ${otherparams} -mod=${mods} -servermod=${servermods} &
				pid=$!
				echo $pid > $pidfile
				chmod 664 $logfile
				wait $pid
			fi

			if [[ -f ${runfile} ]]; then
				echo >>${logfile} "watchdog ($$): [$(date)] server died, waiting to restart..."
				sleep 5s
			else
				echo >>${logfile} "watchdog ($$): [$(date)] server shutdown intentional, watchdog terminating"
			fi
		done
	;;

	log)
		# you can see the logfile in realtime, no more need for screen or something else
		clear
		fn_printMessage  "printing server log of ${name}" ""
		fn_printMessage  "- to stop, press ctrl+c -" ""
		echo "========================================"
		tail -fn5 ${logdir}/$(ls -t ${logdir} | grep ${name} | head -1)
	;;

	*)
		fn_printMessage "$0 (start|stop|status|log)" "" "warning"
		return 1
	;;
esac