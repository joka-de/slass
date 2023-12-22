#!/bin/bash
#
# SLASS - p_a3server
# 
# Author: joka
# 
# Description:
# starts and stops a server instance with config file
# 
# Parameter(s): { start | stop | } {i} {startparameters_{j}.scfg}
# Message <string>
# 
# Return Value:
# None <Any>
#
# load arbitrary variables
serverid=$2
if [ -f $3} ]; then
	source $3
else
	echo "SLASS:    There is no scfg-file ($3), maybe the server has been stopped before or was never up."
	exit 0
fi
#
# load function
source $basepathsource/slass-data/module/m_fnloader.sh
fn_debugMessage "scfg-File $2"
#
# set generic variables
serverdir=&{basepath}/a3/a3srv${serverid}
name=a3srv${serverid}
port=$((2302 + 10 * ( ${serverid} - 1 )))
cfg_dir=${serverdir}/cfg
config=${cfg_dir}/${name}.cfg
cfg=${cfg_dir}/basic.cfg
log_dir=${basepath}/log
pidfile=${serverdir}/${port}.pid
runfile=${serverdir}/${port}.run
logfile=${log_dir}/${name}_$(date +%Y-%m-%d_%H:%M:%S).log
server=${serverdir}/arma3server

#=======================================================================
#
case "$1" in
#
#
start)
	# check if there is a server running or not
	ps ax | grep ${server} | grep ${port}  > /dev/null
	if [ $? -eq 0 ]; then
		fn_printMessage "there is a server already running (${server} at port ${port})"
		fn_printMessage "it can happen, when you started a server and stopped it to fast!"
		fn_printMessage "just stop the server again and it should be good to start!"
		echo $output | ps ax | grep ${server} | grep ${port}
	else
		fn_printMessage "starting a3 server @port ${port}..."
		# file to mark we want server running...
		echo "go" >${runfile}
		#prepare server env (keys, modlist, hostname)
		#. ${basepath}/scripts/service/prepserv.sh
		# launch the background watchdog process to run the server
		nohup </dev/null >/dev/null $0 watchdog &
	fi
;;
#
stop)
	fn_printMessage "stopping a3 server if there is one (port=${port}..."
	if [ -f ${runfile} ]; then
		# ask watcher process to exit by deleting its runfile...
		rm -f ${runfile}
	else
		fn_printMessage "there is no runfile (${runfile}), server shouldn't be up, will shut it down if it is up!"
	fi
	# and terminate arma 3 server process
	if [ -f ${pidfile} ]; then
		fn_printMessage "sending sigterm to process $(cat ${pidfile})..."
		kill $(cat ${pidfile})
		if [ $?==0 ]; then
			rm -f ${pidfile}
		fi
	fi
;;
#
status)
	if [ -f ${runfile} ]; then
		echo "runfile exist, server should be up or is starting..."
		echo "if the server is not done with its start, you will not get a pid file info in the next rows."
		echo "if the server is done with its start, you will get a pid file and process info in the next rows."
	else
		echo "runfile doesn't exist, server should be down or is going down..."
	fi
	#
	if [ -f ${pidfile} ]; then
		pid=$(< ${pidfile})
		fn_printMessage "pid file exists (pid=${pid})..."
		if [ -f /proc/${pid}/cmdline ]; then
			fn_printMessage "server process seems to be running..."
			#echo $output |
			ps ax | grep ${server} | grep ${port}
		fi
	fi
;;
#
restart)
	$0 stop
	sleep 10s
	$0 start
;;
#
watchdog)
	# delete old logs when older then ${deldays} days
	echo >>${logfile} "watchdog ($$): [$(date)] deleting all logfiles in ${log_dir} when older then ${deldays} days."
	find -L ${log_dir} -iname "*.log" -mtime +${deldays} -delete
	#
	# this is a background watchdog process. do not start directly
	while [ -f ${runfile} ]; do
		# launch the server...
		cd ${serverdir}
		echo >>${logfile} "watchdog ($$): [$(date)] starting server (port ${port})..."
		#
		sudo -u ${username} ${server} >>${logfile} 2>&1 -filepatching -config=${config} -cfg=${cfg} -port=${port} -name=${profile} ${otherparams} -mod=${mods} -servermod=${servermods} &
		pid=$!
		echo $pid > $pidfile
		chmod 664 $logfile
		chown ${useradm}:${profile} $logfile
		wait $pid
		#
		if [ -f ${runfile} ]; then
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
echo "printing server log of ${name}"
echo "- to stop, press ctrl+c -"
echo "========================================"
#sleep 1
tail -fn5 ${log_dir}/$(ls -t ${log_dir} | grep ${name} | head -1)
;;
#
#
*)
echo "$0 (start|stop|restart|status|log)"
exit 1
;;

esac



