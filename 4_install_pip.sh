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

task_name="4.1_install_gcc_for_pyenv"
if [[ ! `cat $yum_installed_list | grep 'gcc.x86_64'` =~ ^gcc* ]]
then
    yum -y install gcc.x86_64
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

dependence_list=(
#    'gcc.x86_64'
    'zlib-devel.x86_64'
    'bzip2.x86_64'
    'bzip2-devel.x86_64'
    'readline-devel.x86_64'
    'sqlite.x86_64'
    'sqlite-devel.x86_64'
    'openssl-devel.x86_64'
    'xz.x86_64'
    'xz-devel.x86_64'
)

for dependence in ${dependence_list[*]}
do
    task_name="4.1_install_${dependence}_for_pyenv"
    yum_package_name=$dependence
    package_installed_judge $succeed_list $failed_list $ignored_list $yum_installed_list $task_name $yum_package_name
done

task_name="4.2_git_clone_pyenv_code"
if [[ ! -d ~/.pyenv ]]; then
    git clone git://github.com/yyuu/pyenv.git ~/.pyenv
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="4.3_reload_environ_for_pyenv"
if [[ ! `cat ~/.bashrc | grep 'export PYENV_ROOT="${HOME}/.pyenv"'` ]]; then
cat << "EOF" >> ~/.bashrc

# pyenv
export PYENV_ROOT="${HOME}/.pyenv"

if [ -d "${PYENV_ROOT}" ]; then
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  eval "$(pyenv init -)"
fi

EOF
source ~/.bashrc
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="4.4_download_python_3.6.6"
if [[ ! -e ~/.pyenv/cache/Python-3.6.6.tar.xz ]]; then
    wget http://mirrors.sohu.com/python/3.6.6/Python-3.6.6.tar.xz  -P ~/.pyenv/cache
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="4.5_install_python_3.6.6"
if [[ ! "`pyenv versions | grep 3.6.6`" ]]; then
    pyenv install 3.6.6
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="4.6_pyenv_global_python_3.6.6"
if [[ ! "`pyenv global | grep 3.6.6`" ]]; then
    pyenv global 3.6.6
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="4.7_install_pyenv_virtualenv"
if [[ ! -d ~/.pyenv/plugins/pyenv-virtualenv ]]; then
    git clone git://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="4.8_reload_environ_for_pyenv_virtualenv"
if [[ ! `cat ~/.bashrc | grep 'eval "$(pyenv virtualenv-init -)"'` ]]; then
    echo '' >> ~/.bashrc
    echo '# pyenv virtualenv' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    echo '' >> ~/.bashrc
    source ~/.bashrc
    if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi

task_name="4.9_switch_pip_mirror_to_douban_repo"
if [[ ! -e ~/.pip/pip.conf ]]; then
mkdir ~/.pip
cat << "EOF" >> ~/.pip/pip.conf
[global]
timeout = 6000
index-url = https://pypi.douban.com/simple
trusted-host = pypi.douban.com
EOF
if [[ $? -eq 0 ]]; then echo "$task_name" >> $succeed_list; else echo "$task_name" >> $failed_list; fi
else
    echo "$task_name" >> $ignored_list
fi
