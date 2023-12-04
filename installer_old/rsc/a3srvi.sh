#read server settings
. ${basepath}/scripts/service/servervars.cfg

# set path variables
arma_dir=${basepath}/a3srv${serverid}
#echo "armadir $arma_dir"
name=a3srv${serverid}
port=$((2302 + 10 * ( ${serverid} - 1 )))
cfg_dir=${arma_dir}/cfg
config=${cfg_dir}/${name}.cfg
cfg=${cfg_dir}/basic.cfg
log_dir=${arma_dir}/log
pidfile=${arma_dir}/${port}.pid
runfile=${arma_dir}/${port}.run
logfile=${log_dir}/${name}_$(date +%Y-%m-%d_%H:%M:%S).log
server=${arma_dir}/arma3server

#=======================================================================
ulimit -c 1000000
#
case "$1" in
#
#
start)
# check if there is a server running or not
ps ax | grep ${server} | grep ${port}  > /dev/null

if [ $? -eq 0 ]; then

echo "\033[31mthere is a server already running (${server} at port ${port})\033[0m"
echo "\033[31mit can happen, when you started a server and stopped it to fast!\033[0m"
echo "\033[31mjust stop the server again and it should be good to start!\033[0m"
echo $output | ps ax | grep ${server} | grep ${port}

else

echo "starting a3 server @port \033[35m${port}\033[0m..."

# file to mark we want server running...
echo "go" >${runfile}

#prepare server env (keys, modlist, hostname)
. ${basepath}/scripts/service/prepserv.sh

# launch the background watchdog process to run the server
nohup </dev/null >/dev/null $0 watchdog &
fi
;;
#
stop)
echo "stopping a3 server if there is one (port=\033[35m${port}\033[0m)..."
if [ -f ${runfile} ]; then
# ask watcher process to exit by deleting its runfile...
rm -f ${runfile}
else
echo "\033[31mthere is no runfile (${runfile}), server shouldn't be up, will shut it down if it is up!\033[0m"
fi
# and terminate arma 3 server process
if [ -f ${pidfile} ]; then
echo "sending sigterm to process $(cat ${pidfile})..."
kill $(cat ${pidfile})
if [ $?==0 ]; then
rm -f ${pidfile}
fi
fi
;;
#
status)
if [ -f ${runfile} ]; then
echo "\033[32mrunfile exist, server should be up or is starting...\033[0m"
echo "\033[35mif the server is \033[31mnot done\033[35m with its start, you will \033[31mnot get\033[35m a pid file info in the next rows.\033[0m"
echo "\033[35mif the server is \033[32mdone\033[35m with its start, you will \033[32mget\033[35m a pid file and process info in the next rows.\033[0m"
else
echo "\033[31mrunfile doesn't exist, server should be down or is going down...\033[0m"
fi
if [ -f ${pidfile} ]; then
pid=$(< ${pidfile})
echo "\033[32mpid file exists (pid=\033[35m${pid}\033[0m)..."
if [ -f /proc/${pid}/cmdline ]; then
echo "\033[32mserver process seems to be running...\033[0m"
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
cd ${arma_dir}
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
