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
	echo "SLASS:    File not found: $2"
	echo "SLASS:    Maybe the server has been stopped before or was never up."
	exit 0
fi
#
# load function
source $basepath/slass-data/module/m_fnloader.sh
fn_debugMessage "p_a3server: scfg-File $2"
#
# set generic variables
serverdir="${basepath}/a3/a3srv${serverid}"
server="${serverdir}/arma3server"
#
if [ "$ishc" = true ]; then
	name="a3srv${serverid}_hc$((${processid}-1))"
else
	name=a3srv${serverid}
fi
#port=$((2302 + 10 * ( ${serverid} - 1 )))
pidfile="${serverdir}/${port}.pid"
runfile="${serverdir}/${port}.run"
cfg_dir=${serverdir}/cfg
config=${cfg_dir}/${name}.cfg
cfg=${cfg_dir}/basic.cfg
logdir=${basepath}/log
logfile=${logdir}/${name}_$(date +%Y-%m-%d_%H-%M-%S).log
#=======================================================================
#
case "$1" in
#
#
start)
	# check if there is a server running or not
	echo >>${logfile} "start commmand"
	ps ax | grep ${server} | grep ${port}  > /dev/null
	if [ $? -eq 0 ]; then
		fn_printMessage "there is a server already running (${server} at port ${port})" ""
		fn_printMessage "it can happen, when you started a server and stopped it to fast!" ""
		fn_printMessage "just stop the server again and it should be good to start!" ""
		echo $output | ps ax | grep ${server} | grep ${port}
	else
		fn_printMessage "starting a3 server @port ${port}..." ""
		# file to mark we want server running...
		echo "go" > ${runfile}
		# launch the background watchdog process to run the server
		nohup $0 watchdog $scfg >${logfile} 2>&1 </dev/null &
	fi
;;
#
#
stop)
	fn_printMessage "stopping a3 server if there is one (port=${port})..." ""
	if [ -e ${runfile} ]; then
		# ask watchdog to exit by deleting its runfile...
		rm -f ${runfile}
	else
		fn_printMessage "There is no runfile (${runfile}), server shouldn't be up, will shut it down if it is up!" ""
	fi
	# and terminate server process
	if [ -e ${pidfile} ]; then
		fn_printMessage "sending sigterm to process $(cat ${pidfile})..." ""
		kill -15 $(cat ${pidfile}) || true
		rm -f ${pidfile}
	fi
;;
#
#
status)
	if [ -e ${runfile} ]; then
		fn_printMessage "runfile exist, server should be up or is starting..." ""
		fn_printMessage "if the server is not done with its start, you will not get a pid file info in the next rows." ""
		fn_printMessage "if the server is done with its start, you will get a pid file and process info in the next rows." ""
	else
		echo "runfile doesn't exist, server should be down or is going down..."
	fi
	#
	if [ -e ${pidfile} ]; then
		pid=$(< ${pidfile})
		fn_printMessage "pid file exists (pid=${pid})..." ""
		if [ -f /proc/${pid}/cmdline ]; then
			fn_printMessage "server process seems to be running..." ""
			#echo $output |
			ps ax | grep ${server} | grep ${port}
		fi
	fi
;;
#
#
watchdog)
	# this is a background watchdog process. do not start directly
	# delete old logs when older then ${logfilelifetime} days
	#echo >>${logfile} "watchdog ($$): [$(date)] deleting all logfiles in ${logdir} when older then ${logfilelifetime} days."
	fn_printMessage "watchdog ($$): [$(date)] deleting all logfiles in ${logdir} when older then ${logfilelifetime} days." ""
	find -L ${logdir} -iname "*.log" -mtime "${logfilelifetime}" -delete

	while [ -e ${runfile} ]; do
		# launch the server...
		cd ${serverdir}
		#echo >>${logfile} "watchdog ($$): [$(date)] starting server (port ${port})..."
		fn_printMessage "watchdog ($$): [$(date)] starting server (port ${port})..." ""
		#
		if [ "$ishc" = true ]; then
			sudo -u ${userlnch} ${server} >>${logfile} 2>&1 -config=${config} -cfg=${cfg} -port=${port} -client -connect=127.0.0.1 -name=${profile} ${otherparams} -mod=${mods}&
			pid=$!
			echo $pid > $pidfile
			chmod 664 $logfile
			chown ${useradm}:${profile} $logfile
			wait $pid
		else
			sudo -u ${userlnch} ${server} >>${logfile} 2>&1 -config=${config} -cfg=${cfg} -port=${port} -name=${profile} ${otherparams} -mod=${mods} -servermod=${servermods} &
			pid=$!
			echo $pid > $pidfile
			chmod 664 $logfile
			chown ${useradm}:${profile} $logfile
			wait $pid
		fi
		#
		if [ -e ${runfile} ]; then
			echo >>${logfile} "watchdog ($$): [$(date)] server died, waiting to restart..."
			sleep 5s
		else
			echo >>${logfile} "watchdog ($$): [$(date)] server shutdown intentional, watchdog terminating"
		fi
	done
;;
#
#
log)
	# you can see the logfile in realtime, no more need for screen or something else
	clear
	fn_printMessage  "printing server log of ${name}" ""
	fn_printMessage  "- to stop, press ctrl+c -" ""
	echo "========================================"
	#sleep 1
	tail -fn5 ${logdir}/$(ls -t ${logdir} | grep ${name} | head -1)
;;
#
#
*)
	fn_printMessage "$0 (start|stop|status|log)" ""
	return 1
;;

esac