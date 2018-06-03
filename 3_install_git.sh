#!/bin/bash

succeed_list=$1
failed_list=$2
ignored_list=$3
yum_installed_list=$4

curr_dir=$PWD

function package_installed_judge(){
    if [[ ! "`cat $4 | grep $6`" ]]
    then
        yum -y install $6
        if [[ $? -eq 0 ]]; then echo "$5" >> $1; else echo "$5" >> $2; fi
    else
        echo "$5" >> $3
    fi
}

task_name='3.1_install_git'
yum_package_name='git.x86_64'
package_installed_judge $succeed_list $failed_list $ignored_list $yum_installed_list $task_name $yum_package_name

task_name='3.2_git_bash_autoload'
if [[ ! -e /etc/bash_completion.d/git-completion.bash ]]; then
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P /etc/bash_completion.d/ && \
cat << "EOF" >> ~/.bashrc
# Git bash autoload
if [ -f /etc/bash_completion.d/git-completion.bash ]; then
. /etc/bash_completion.d/git-completion.bash
fi
EOF
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
fi

source ~/.bashrc
