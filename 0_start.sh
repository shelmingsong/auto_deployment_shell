#!/bin/bash

curr_dir=$PWD
temp_dir="$PWD/shell_temp"
succeed_list="$temp_dir/succeed_list.log"
failed_list="$temp_dir/failed_list.log"
ignore_list="$temp_dir/ignore_list.log"
succeed_shell="$temp_dir/succeed_shell.log"
failed_shell="$temp_dir/failed_shell.log"
exec_time_log="$temp_dir/exec_time.log"
yum_installed_list="$temp_dir/yum_installed_list.log"

yum makecache fast
rm $temp_dir -rf
mkdir $temp_dir
yum list installed > $yum_installed_list

start_time=`date +%s`
last_time=$start_time

function echo_exec_time(){
#    last_time=$1
#    curr_time=$2
#    shell_name=$3
#    exec_time_log=$4
    exec_time=$[$2-$1]
    exec_min=$[exec_time/60]
    exec_sec=$[exec_time%60]
    echo -e "$3 \t exec time: \t ${exec_min} m  ${exec_sec} s" >> $4
}

function record_exec_result(){
#    succeed_shell=$1
#    failed_shell=$2
#    shell_name=$3
    if [[ $? -eq 0 ]]; then echo "$3" >> $1; else echo "$3" >> $2; fi
}

function exec_hook(){
    # hook_shell_dir=$1
    # succeed_list=$2
    # failed_list=$3
    # ignored_list=$4
    # yum_installed_list=$5
    # db_host=$6
    cd $1
    x=0
    shell_list=()
    for filename in *;
        do
            if [[ $filename =~ .sh$ ]]; then
                shell_list[$x]=$filename
            fi
            let x+=1
        done
    for shell in ${shell_list[*]}
    do
        ./$shell $2 $3 $4 $5 $6
    done
}


shell_name="1_shell_init.sh"
cd $curr_dir
$curr_dir/1_shell_init.sh $temp_dir $succeed_list $failed_list $ignore_list $succeed_shell $failed_shell $exec_time_log $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

shell_name="pre_hook"
exec_hook $curr_dir/pre_hook $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

# ==================================================
# all new hook shell need to be added after here
# ==================================================

shell_name="2_deploy_firewall.sh"
cd $curr_dir
$curr_dir/2_deploy_firewall.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

shell_name="3_install_git.sh"
cd $curr_dir
$curr_dir/3_install_git.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

shell_name="4_install_pip.sh"
cd $curr_dir
$curr_dir/4_install_pip.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

source ~/.bashrc

shell_name="5_install_docker.sh"
cd $curr_dir
$curr_dir/5_install_docker.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

source ~/.bashrc

shell_name="6_install_mysql.sh"
cd $curr_dir
$curr_dir/6_install_mysql.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

shell_name="deploy_mysql_hook"
exec_hook $curr_dir/deploy_mysql_hook $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

shell_name="7_enable_sshd.sh"
cd $curr_dir
$curr_dir/7_enable_sshd.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

shell_name="8_install_zsh.sh"
cd $curr_dir
$curr_dir/8_install_zsh.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

# ==================================================
# all new hook shell need to be added before here
# ==================================================

shell_name="post_hook"
exec_hook $curr_dir/post_hook $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name
curr_time=`date +%s`
echo_exec_time $last_time $curr_time $shell_name $exec_time_log
last_time=$curr_time

end_time=$curr_time

shell_name="99_shell_finalize.sh"
cd $curr_dir
$curr_dir/99_shell_finalize.sh $succeed_list $failed_list $ignore_list $yum_installed_list
record_exec_result $succeed_shell $failed_shell $shell_name

echo "" >> $exec_time_log
echo_exec_time $start_time $end_time 'all_shell\t' $exec_time_log

echo "=================================================="
echo "following shell exec success"
cat $succeed_shell
echo "=================================================="

echo "=================================================="
echo "following command exec success"
cat $succeed_list
echo "=================================================="

echo "=================================================="
echo "following command ignored"
cat $ignore_list
echo "=================================================="

echo "##################################################"
echo "following shell exec fail"
cat $failed_shell
echo "##################################################"

echo "##################################################"
echo "following command exec fail"
cat $failed_list
echo "##################################################"

echo "=================================================="
echo "shell exec time"
cat $exec_time_log
echo "=================================================="

if [[ -s $failed_list || -s $failed_shell ]]; then
    exit 1
else
    exit 0
fi
