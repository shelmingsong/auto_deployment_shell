#!/bin/bash

touch $2
touch $3
touch $4
touch $5
touch $6
touch $7

temp_dir=$1
succeed_list=$2
failed_list=$3
ignored_list=$4
yum_installed_list=$8

function package_installed_judge(){
#    success_list=$1
#    failed_list=$2
#    ignored_list=$3
#    yum_installed_list=$4
#    task_name=$5
#    yum_package_name=$6
    if [[ ! "`cat $4 | grep $6`" ]]
    then
        yum -y install $6
        if [[ $? -eq 0 ]]; then echo "$5" >> $1; else echo "$5" >> $2; fi
    else
        echo "$5" >> $3
    fi
}

yum clean all
yum makecache fast
yum list installed > $yum_installed_list

task_name='1.1_install_wget'
yum_package_name='wget.x86_64'
package_installed_judge $succeed_list $failed_list $ignored_list $yum_installed_list $task_name $yum_package_name

task_name="1.2_backup_original_image"
if [ -e /etc/yum.repos.d/CentOS-Base.repo ]
then
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name_1="1.3_download_ustc_image"
task_name_2="1.4_switch_to_ustc_image"
if [ ! -e /etc/yum.repos.d/CentOS-Base-USTC.repo ]
then
    cd /etc/yum.repos.d/ && \
    wget https://raw.githubusercontent.com/shelmingsong/Share/master/CentOS-Base-USTC.repo
    if [[ $? -eq 0 ]]; then echo "$task_name_1" >> $succeed_list; else echo "$task_name_1" >> $failed_list; fi

    yum clean all
    yum makecache
    if [[ $? -eq 0 ]]; then echo "$task_name_2" >> $succeed_list; else echo "$task_name_2" >> $failed_list; fi
else
    echo "$task_name_1" >> $ignored_list
    echo "$task_name_2" >> $ignored_list
fi

task_name='1.5_install_expect'
yum_package_name='expect.x86_64'
package_installed_judge $succeed_list $failed_list $ignored_list $yum_installed_list $task_name $yum_package_name
