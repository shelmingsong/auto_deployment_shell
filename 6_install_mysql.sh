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

mysql_package_list=(
    'mysql57-community-release.noarch'
    'mysql-community-client.x86_64'
    'mysql-community-common.x86_64'
    'mysql-community-devel.x86_64'
    'mysql-community-libs.x86_64'
    'mysql-community-libs-compat.x86_64'
    'mysql-community-server.x86_64'
)

need_install_mysql_flag=0

for mysql_package in ${mysql_package_list[*]}
do
    if [[ ! "`cat $yum_installed_list | grep $mysql_package`" ]]
    then
        need_install_mysql_flag=1
        break
    fi
done

if [[ $need_install_mysql_flag -eq 1 ]]
then
    yum install $curr_dir/required_rpms/mysql/*.rpm -y
    yum install $curr_dir/required_rpms/mysql-devel/*.rpm -y
    rpm -ivh $curr_dir/required_rpms/mysql57-community-release-el7-11.noarch.rpm
    yum install $curr_dir/required_rpms/mysql-community-server/*.rpm -y
    rm /etc/yum.repos.d/mysql*.repo -f
fi

task_name="6.1_start_mysql_server"
systemctl start mysqld
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi