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

dependence_list=(
    'yum-utils.noarch'
    'device-mapper-persistent-data.x86_64'
    'lvm2.x86_64'
)

for dependence in ${dependence_list[*]}
do
    task_name="5.1_install_${dependence}_for_docker"
    yum_package_name=$dependence
    package_installed_judge $succeed_list $failed_list $ignored_list $yum_installed_list $task_name $yum_package_name
done

task_name="5.2_add_aliyun_docker-ce_repo"
if [[ ! -e /etc/yum.repos.d/docker-ce.repo ]]; then
    yum-config-manager \
    --add-repo \
    https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="5.3_install_docker-ce"
yum_package_name='docker-ce-17.06.2.ce-1.el7.centos'
if [[ ! "`cat $yum_installed_list | grep 17.06.2.ce-1.el7.centos`" ]]
then
    yum makecache fast && \
    yum -y install $yum_package_name
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="5.4_enable_and_start_docker"
systemctl start docker && \
systemctl enable docker
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi

task_name="5.5_install_docker-compose"
if [[ ! -e /etc/bash_completion.d/docker-compose ]]; then
    pip install -U docker-compose==1.17.0 && \
    curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi
