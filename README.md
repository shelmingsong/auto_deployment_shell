## 在 CentOS 上初始化 Python 环境的自动部署脚本
### 环境
> CentOS Linux release 7.5.1804

### 脚本完成操作
* 切换CentOS软件镜像源为中科大软件源
* 设置防火墙，允许全部端口通过
* 安装git
* 安装Pyenv包管理工具，Pyenv使用详见：[Python版本管理工具 Pyenv的安装与使用](https://songmingyao.com/Python%E7%89%88%E6%9C%AC%E7%AE%A1%E7%90%86%E5%B7%A5%E5%85%B7%20Pyenv%E7%9A%84%E5%AE%89%E8%A3%85%E4%B8%8E%E4%BD%BF%E7%94%A8/)
* 安装Python 3.6.4
* 切换pip源为豆瓣
* 安装Docker
* 安装MySQL
* 初始化MySQL（root@localhost的密码为123456，song@%的密码为123456）
* 设置sshd开机启动
* 安装ntp时间自动更新工具

### 使用
* 从[Github](https://github.com/shelmingsong/auto_deployment_shell)下载部署脚本代码
* 从[百度云](https://pan.baidu.com/s/1OLtN6SmzbOlytV44I_nY5g)下载包含MySQL rpm包的`required_rpms`文件夹（MySQL官网由于国内特殊的网络环境原因，下载很慢，经常中断导致无法安装，因而将安装所需的rpm包单独down了下来，又因为所有MySQL包加起来有200+M，不方便传到Github上，只能传到百度云上单独下载）
* 将百度云上下载的`required_rpms`文件夹加入到代码主目录，最终目录如下：
```
.
├── 0_start.sh
├── 1_shell_init.sh
├── 2_deploy_firewall.sh
├── 3_install_git.sh
├── 4_install_pip.sh
├── 5_install_docker.sh
├── 6_install_mysql.sh
├── 7_enable_sshd.sh
├── 99_shell_finalize.sh
├── deploy_mysql_hook
│   ├── 0_deploy_mysql.sh
│   └── init_mysql.exp
├── post_hook
│   └── 1_test.sh
├── pre_hook
│   └── 1_test.sh
├── README.md
└── required_rpms
    ├── mysql
    │   ├── mariadb-5.5.56-2.el7.x86_64.rpm
    │   ├── perl-5.16.3-292.el7.x86_64.rpm
    │   ├── perl-Carp-1.26-244.el7.noarch.rpm
    │   ├── perl-constant-1.27-2.el7.noarch.rpm
    │   ├── perl-Encode-2.51-7.el7.x86_64.rpm
    │   ├── perl-Exporter-5.68-3.el7.noarch.rpm
    │   ├── perl-File-Path-2.09-2.el7.noarch.rpm
    │   ├── perl-File-Temp-0.23.01-3.el7.noarch.rpm
    │   ├── perl-Filter-1.49-3.el7.x86_64.rpm
    │   ├── perl-Getopt-Long-2.40-2.el7.noarch.rpm
    │   ├── perl-HTTP-Tiny-0.033-3.el7.noarch.rpm
    │   ├── perl-libs-5.16.3-292.el7.x86_64.rpm
    │   ├── perl-macros-5.16.3-292.el7.x86_64.rpm
    │   ├── perl-parent-0.225-244.el7.noarch.rpm
    │   ├── perl-PathTools-3.40-5.el7.x86_64.rpm
    │   ├── perl-Pod-Escapes-1.04-292.el7.noarch.rpm
    │   ├── perl-podlators-2.5.1-3.el7.noarch.rpm
    │   ├── perl-Pod-Perldoc-3.20-4.el7.noarch.rpm
    │   ├── perl-Pod-Simple-3.28-4.el7.noarch.rpm
    │   ├── perl-Pod-Usage-1.63-3.el7.noarch.rpm
    │   ├── perl-Scalar-List-Utils-1.27-248.el7.x86_64.rpm
    │   ├── perl-Socket-2.010-4.el7.x86_64.rpm
    │   ├── perl-Storable-2.45-3.el7.x86_64.rpm
    │   ├── perl-Text-ParseWords-3.29-4.el7.noarch.rpm
    │   ├── perl-threads-1.87-4.el7.x86_64.rpm
    │   ├── perl-threads-shared-1.43-6.el7.x86_64.rpm
    │   ├── perl-Time-HiRes-1.9725-3.el7.x86_64.rpm
    │   └── perl-Time-Local-1.2300-2.el7.noarch.rpm
    ├── mysql57-community-release-el7-11.noarch.rpm
    ├── mysql-community-server
    │   ├── mysql-community-client-5.7.20-1.el7.x86_64.rpm
    │   ├── mysql-community-common-5.7.20-1.el7.x86_64.rpm
    │   ├── mysql-community-devel-5.7.20-1.el7.x86_64.rpm
    │   ├── mysql-community-libs-5.7.20-1.el7.x86_64.rpm
    │   ├── mysql-community-libs-compat-5.7.20-1.el7.x86_64.rpm
    │   └── mysql-community-server-5.7.20-1.el7.x86_64.rpm
    └── mysql-devel
        ├── keyutils-libs-devel-1.5.8-3.el7.x86_64.rpm
        ├── krb5-devel-1.15.1-8.el7.x86_64.rpm
        ├── libcom_err-devel-1.42.9-10.el7.x86_64.rpm
        ├── libkadm5-1.15.1-8.el7.x86_64.rpm
        ├── libselinux-devel-2.5-11.el7.x86_64.rpm
        ├── libsepol-devel-2.5-6.el7.x86_64.rpm
        ├── libverto-devel-0.2.5-4.el7.x86_64.rpm
        ├── mariadb-devel-5.5.56-2.el7.x86_64.rpm
        ├── openssl-devel-1.0.2k-8.el7.x86_64.rpm
        ├── pcre-devel-8.32-17.el7.x86_64.rpm
        └── zlib-devel-1.2.7-17.el7.x86_64.rpm
```
* 在主目录运行`source 0_start.sh`，等待执行完成即可，执行结果如下:
```
==================================================
shell exec time
1_shell_init.sh 	 exec time: 	 0 m  25 s
pre_hook 	 exec time: 	 0 m  0 s
2_deploy_firewall.sh 	 exec time: 	 0 m  2 s
3_install_git.sh 	 exec time: 	 0 m  7 s
4_install_pip.sh 	 exec time: 	 4 m  3 s
5_install_docker.sh 	 exec time: 	 1 m  2 s
6_install_mysql.sh 	 exec time: 	 1 m  6 s
deploy_mysql_hook 	 exec time: 	 0 m  3 s
7_enable_sshd.sh 	 exec time: 	 0 m  0 s
post_hook 	 exec time: 	 0 m  0 s

all_shell	 	 exec time: 	 6 m  48 s
==================================================
```
