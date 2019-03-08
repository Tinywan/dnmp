#!/bin/bash

#######################################################
# $Name:          nginx_log_cut.sh
# $Version:       1.0
# $Function:      Nginx Log Cut Script
# $Author:        ShaoBo Wan (Tinywan)
# $Description:   Nginx日志定时切割
# $Crontab:       55 1 * * * bash /home/tinywan/shell/nginx_log_cut.sh >/dev/null 2>&1
#######################################################

# get docker nginx PID
pid=1

#set the path save nginx log files
base_path="/home/www/backup/logs"

# get data eg：201611
log_dir_name=$(date -d yesterday +"%Y%m")

# get days eg：03
DAY=$(date -d yesterday +"%d")

# create log directory
mkdir -p $base_path/$log_dir_name

# set the path to nginx log
log_files_path="/home/www/lnmp/log"

#set nginx log files you want to cut eg: array
log_files_names=(access error)

#Set how long you want to save eg: 7 days
save_mins=1

#log file num eg: 2
log_files_num=${#log_files_names[@]}

#loop cut nginx log files
for log_name in ${log_files_names[*]}
do
   mv ${log_files_path}/${log_name}.log ${base_path}/${log_dir_name}/${log_name}_${DAY}.log
done

#向 Nginx 主进程发送 USR1 信号,USR1 信号是重新打开日志文件
docker exec lnmp-nginx sh -c "kill -USR1 1"

#delete 7 days ago nginx log files
find $base_path -mindepth 1 -maxdepth 3 -type f -name "*.log" -mmin +$save_mins | xargs rm -rf