#!/bin/bash

succeed_list=$1
failed_list=$2
ignored_list=$3
yum_installed_list=$4

function package_installed_judge(){
    if [[ ! "`cat $4 | grep $6`" ]]
    then
        yum -y install $6
        if [[ $? -eq 0 ]]; then echo "$5" >> $1; else echo "$5" >> $2; fi
    else
        echo "$5" >> $3
    fi
}

task_name="99.1_install_ntp"
yum_package_name='ntp.x86_64'
package_installed_judge $succeed_list $failed_list $ignored_list $yum_installed_list $task_name $yum_package_name

task_name="99.2 set timezone and synchronization time"
systemctl enable ntpd && \
systemctl start ntpd && \
timedatectl set-timezone Asia/Shanghai && \
timedatectl set-ntp yes && \
ntpq -p
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
