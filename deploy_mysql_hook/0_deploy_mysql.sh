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

curr_dir=$PWD

USER_NAME="song"
TEMP_PASS=`sed 's/A temporary password is generated for /\n/g' /var/log/mysqld.log | grep 'root@localhost: ' | sed 's/root@localhost: //g'`
ROOT_PASS="123456"
USER_PASS="123456"

task_name="init_mysql"
$curr_dir/init_mysql.exp $TEMP_PASS
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi

mysql -uroot -p$TEMP_PASS -e"set global validate_password_policy=0;set global validate_password_length=1;ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASS';grant all on *.* to '$USER_NAME'@'%' identified by '$USER_PASS' with grant option;"
