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

task_name="7.1_enable_sshd"
systemctl start sshd
systemctl enable sshd
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
