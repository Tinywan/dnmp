![images](images/docker-composer-lnmp.png)

##  使用 docker-compose 部署 LNMP 环境

### :book: 目录

* [Docker简介](#Docker简介)
* [为什么使用Docker](#为什么使用Docker)
* [版本更新](#版本更新)
* [项目结构](#项目结构)
* [版本更新](#版本更新)
* [如何快速使用](#如何快速使用)
    *   [部署环境要求](#部署环境要求)
    *   [快速启动](#快速启动)
    *   [测试访问](#测试访问)
* [Nginx管理](#Nginx管理)
    *   Nginx日志定时备份和删除
* [MySQL管理](#MySQL管理)
    *   Mysql自动备份脚本
* [Redis管理](#Redis管理)  
* [Composer管理](#Composer管理)
* [Crontab管理](#Crontab管理)
* [WebSocket管理](#WebSocket管理)
* [phpMyAdmin管理](#phpMyAdmin管理)
* [容器管理](#容器管理)  
* [证书管理](#证书管理)
    * [本地生成HTTPS](#本地生成HTTPS)
    * [Docker生成HTTPS](#Docker生成HTTPS)
* [遇到的问题](#遇到的问题)

### Docker简介

Docker 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口。

### 为什么使用Docker

- [x] 加速本地的开发和构建流程，容器可以在开发环境构建，然后轻松地提交到测试环境，并最终进入生产环境
- [x] 能够在让独立的服务或应用程序在不同的环境中得到相同的运行结果  
- [x] 创建隔离的环境来进行测试  
- [x] 高性能、超大规划的宿主机部署  
- [x] 从头编译或者扩展现有的OpenShift或Cloud Foundry平台来搭建自己的PaaS环境

### 版本更新

```java
dnmp
├── v1      -- Nginx + PHHP-FPM
├── v2      -- Nginx + PHP7.2.3 + PHPRedis4.0
├── v3      -- Nginx + PHP7.2.3 + PHPRedis4.0 + MySQL5.7 + Reids3.2
├── v4      -- Nginx + PHP7.2.3 + PHPRedis4.0 + MySQL5.7  + Reids5.0
├── v5      -- Nginx + PHP7.2.3 + PHPRedis4.0 + MySQL5.7  + Reids5.0  + HTTPS
├── v6      -- Nginx + PHP7.2.3-v1 + PHPRedis4.0 + MySQL5.7 + Reids5.0 + HTTPS + Crontab
├── v7      -- Nginx + PHP7.2.3-v1 + PHPRedis4.0 + MySQL5.7 + Reids5.0 + HTTPS + Crontab + Websocket  
└── v8      -- Nginx + PHP7.2.3-v1 + PHPRedis4.0 + MySQL5.7 + Reids5.0 + HTTPS + Crontab + Websocket + phpmyadmin
```

### 项目结构  

```java
dnmp
└── dnmp
    ├── conf                    -- Nginx 配置目录
    │   ├── conf.d
    │   │   └── www.conf        -- Nginx 扩展配置文件
    │   ├── fastcgi.conf
    │   ├── fastcgi_params
    │   ├── mime.types
    │   └── nginx.conf          -- Nginx 主配置文件
    ├── docker-compose.yml      -- 基础配置文件
    ├── docker-compose.override.yml -- 开发环境配置文件，默认加载
    ├── docker-compose.prod.yml -- 生产环境配置文件，-f 指定加载
    ├── env.sample              -- 环境配置文件，拷贝 env.sample 为 .env
    ├── etc                     -- 公共配置目录
    │   ├── letsencrypt         -- Nginx 证书目录
    │   │   ├── ssl.crt
    │   │   └── ssl.key
    │   ├── php-fpm.conf        -- PHP-FPM 进程服务的配置文件
    │   ├── php-fpm.d
    │   │   └── www.conf        -- PHP-FPM 扩展配置文件
    │   ├── redis
    │   │   └── redis.conf      -- Redis 配置文件
    │   ├── mysql
    │   │   └── data            -- MySQL 数据存储目录
    │   │   └── my.cnf          -- MySQL 配置文件
    │   └── php.ini             -- PHP 运行核心配置文件
    ├── log                     -- Nginx 日志目录
    │   ├── tp5_access.log
    │   ├── tp5_error.log       -- 项目错误日志
    │   ├── access.log
    │   └── error.log           -- Nginx 系统错误日志
    └── www                     -- 项目代码目录
        └── site                -- 具体项目目录
            ├── application
            └── public
               └──index.php     -- 项目框架入口文件
```

### 环境要求   

*   已经安装 [Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04)  
*   已经安装 [Docker-compose](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04)  

### 如何快速使用 
*   拉取项目：`git clone https://github.com/Tinywan/dnmp.git`  
*   进入目录：`cd dnmp/dnmp` 
*   启动所有容器（守护进程） 

    ```java
    $ docker-compose up -d
    Starting lnmp-redis ... done
    Starting lnmp-mysql ... done
    Starting lnmp-php ... done
    Starting lnmp-nginx ... done
    Starting lnmp-phpmyadmin ... done
    ```

* 浏览器访问：`http://127.0.0.1/`  
    * 请确保`80`端口没有被占用
    * Redis 容器内连接，连接主机为：`lnmp-redis`
    * MySQL 容器内连接，连接主机为：`lnmp-mysql`
*   请务必给使用`-v`挂载主机目录赋予权限：`sudo chown -R 1000 data(宿主机目录)`

### Nginx管理  

*   配置文件端口必须和 `docker-compose.yml`的`ports - 8088:80`中的映射出来的端口一一对应

    > 列如：`conf/conf.d/www.conf`中配置端口为 `80`,则映射端口也`80`，对应的映射端口为：`8088:80`

*   重新加载配置文件 `docker exec -it lnmp-nginx nginx -s reload`  

    > 或者 `docker exec lnmp-nginx nginx -s reload`

*   [Nginx日志定时备份和删除](./dnmp/backup/nginx_log_cut.sh)

### MySQL管理

*   进入容器：`docker exec -it lnmp-mysql /bin/bash`

    > Windows 环境使用：`docker exec -it lnmp-mysql bash`  

*   修改配置文件 `my.cnf`，重新加载：`docker-compose restart mysql`
*   容器内连接：`mysql -uroot -p123456`
*   外部宿主机连接：`mysql -h 127.0.0.1 -P 3308 -uroot -p123456`
*   数据-备份-恢复  
    *   导出（备份）
        *   导出数据库中的所有表结构和数据：`docker exec -it lnmp-mysql mysqldump -uroot -p123456 test > test.sql`  
        *   只导结构不导数据：`docker exec -it lnmp-mysql mysqldump --opt -d -uroot -p123456 test > test.sql`  
        *   只导数据不导结构：`docker exec -it lnmp-mysql mysqldump -t -uroot -p123456 test > test.sql`  
        *   导出特定表的结构：`docker exec -it lnmp-mysql mysqldump -t -uroot -p123456 --table user > user.sql`  
    *   导入（恢复）`docker exec -i lnmp-mysql -uroot -p123456 test < /home/www/test.sql`  
        > 如果导入不成功，检查sql文件头部：`mysqldump: [Warning] Using a password on the command line interface can be insecure.`是否存在该内容，有则删除即可
*   [MySQL备份小脚本](./dnmp/backup/nginx_log_cut.sh)
    > Crontab 任务：`55 23 * * *  bash /backup/mysql_auto_backup.sh >/dev/null 2>&1`  
    > 注意：crontab定时执行Docker 任务的时候是不需要添加参数 `-it`。`-t`是分配一个伪终端,但是crontab执行的时候实际是不需要的。

### PHP管理

*   进入php容器 `docker exec -it lnmp-php /bin/bash`
    > 如果提示：`bash: export: [/bin/bash,': not a valid identifier`。删除配置文件`vim ~/.bashrc`末尾部分：`[/bin/bash, -c, source ~/.bashrc]`
*   重启php服务 `docker-compose restart php`

    > 修改配置文件 `www.conf`，可使用该命令重新加载。  

### Redis管理

*   连接Redis容器：`docker exec -it lnmp-redis redis-cli -h 127.0.0.1 -p 63789`  
*   通过容器连接：`docker exec -it lnmp-redis redis-cli -h lnmp-redis -p 63789`  
*   单独重启redis服务 `docker-compose up --no-deps -d redis`
*   外部宿主机连接：`redis-cli -h 127.0.0.1 -p 63789`

### Composer管理

#### 容器内

*   需要进入`lnmp-php`容器： `docker exec -it lnmp-php /bin/bash`
*   查看 `composer`版本：`composer --version`
*   修改 composer 的全局配置文件（推荐方式）

    ```
    composer config -g repo.packagist composer https://packagist.phpcomposer.com
    ```
    > 如果你是墙内客户，务必添加以上国内镜像
    
*   更新框架或者扩展

    ```java
    /var/www/tp5.1# composer update
    - Installing topthink/think-installer (v2.0.0): Downloading (100%)
    - Installing topthink/framework (v5.1.32): Downloading (100%)
    Writing lock file
    Generating autoload files
    ```

#### 宿主机

建议在主机HOST中使用composer，避免PHP容器变得庞大，[Docker Official Images](https://hub.docker.com/_/composer)

*   1、在主机创建一个目录，用以保存composer的配置和缓存文件
    ```
    mkdir ~/dnmp/composer
    ```
*   2、打开主机的 ~/.bashrc 或者 ~/.zshrc 文件，加上
    ```
    composer () {
        tty=
        tty -s && tty=--tty
        docker run \
            $tty \
            --interactive \
            --rm \
            --user $(id -u):$(id -g) \
            --volume ~/dnmp/composer:/tmp \
            --volume /etc/passwd:/etc/passwd:ro \
            --volume /etc/group:/etc/group:ro \
            --volume $(pwd):/app \
            composer "$@"
    }
    ```
*   3、让文件起效
    ```
    source ~/.bashrc
    ```

*   4、在主机的任何目录下就能用`composer`了
    ```
    cd ~/dnmp/www/
    composer create-project topthink/think tp5.2
    composer update topthink/framework
    ```
    > 第一次执行提示：`Unable to find image 'composer:latest' locally`，不要慌，稍等片刻  

### Crontab管理

#### 执行方案  

* 1、使用主机的cron实现定时任务（推荐）
* 2、创建一个新容器专门执行定时任务，[crontab for docker ](https://hub.docker.com/r/willfarrell/crontab) 
* 3、在原有容器上安装cron，里面运行2个进程

#### 宿主机执行任务（推荐）  

```
# 2019年2月14日 @add Tinywan 获取图表数据 每3分钟执行一次
*/30 * * * * docker exec lnmp-php echo " Hi Lnmp " >> /var/www/crontab.log
```
> `lnmp-php` 为容器名称

#### 容器内执行任务  

*   需要进入`lnmp-php`容器： `docker exec -it lnmp-php /bin/bash`
*   手动启动crontab，`/etc/init.d/cron start` 
*   添加Crontab任务 `crontab -e`  
*   添加任务输出日志到映射目录：`* * * * * echo " Hi Lnmp " >> /var/www/crontab.log`
*   定时执行ThinkPHP5自带命令行命令：`*/30 * * * * /usr/local/php/bin/php /var/www/tp5.1/think jobs hello`

### WebSocket管理  

在项目中难免会用到 [workerman](https://github.com/walkor/Workerman)  

*   进入`lnmp-php`容器：`docker exec -it lnmp-php /bin/bash`  
*   以daemon（守护进程）方式启动 workerman ：` php ../workerman/start.php start -d`  
*   配置`docker-compose.yml` 文件中对应的映射端口  

    ```
    php:
        ports:
            - "9000:9000"
            - "9502:9502" # workerman 映射端口
    ```

*   防火墙问题，如果使用阿里云ESC，请在[安全组](https://ecs.console.aliyun.com/?spm=5176.2020520001#/securityGroup/region/cn-shanghai)增加**入方向**和**出方向**端口配置

    ```
    协议类型：自定义 TCP
    端口范围：9502/9502
    授权对象：0.0.0.0/0
    ```

*   宿主机可以查看对应端口号是否已经映射成功

    ```
    ps -aux|grep 9502
    WorkerMan: worker process  AppGateway websocket://0.0.0.0:9502
    ```

*   通过`telnet`命令检测远程端口是否打开

    ```
    telnet 127.0.0.1 9502
    Trying 127.0.0.1...
    Connected to 127.0.0.1.
    Escape character is '^]'.
    ```

    > 出现`Connected`表示连通了

*   通过Console测试是否支持外网访问 

    ```
    var ws = new WebSocket('ws://宿主机公网ip:9502/');
    ws.onmessage = function(event) {
        console.log('MESSAGE: ' + event.data);
    };
    ƒ (event) {
        console.log('MESSAGE: ' + event.data);
    }
    MESSAGE: {"type":"docker","text":"Hi Tinywan"}
    ```

#### phpMyAdmin管理  

主机上访问phpMyAdmin的地址：`http://localhost:8082`或者`http://宿主机Ip地址:8082`
> 默认登录账户：`root`，密码：`123456`

#### 容器管理  

![images](images/engine-components-flow.png)

*   进入Docker 容器  

    * Linux 环境  `$ docker exec -it lnmp-php bash`
    * Windows 环境  `$ winpty docker exec -it lnmp-php bash`

*   关闭容器并删除服务`docker-compose down`  

*   单独重启redis服务 `docker-compose up --no-deps -d redis`  

    > 如果用户只想重新部署某个服务，可以使用 `docker-compose up --no-deps -d <SERVICE_NAME>` 来重新创建服务并后台停止旧服务，启动新服务，并不会影响到其所依赖的服务。

*   单独加载配置文件，列如修改了nginx配置文件`www.conf`中的内容，如何即使生效，请使用以下命令重启容器内的Nginx配置文件生效：

    ```java
    docker exec -it lnmp-nginx nginx -s reload
    ```

    > `lnmp-nginx`为容器名称（`NAMES`），也可以指定容器的ID 。`nginx`为服务名称（`docker-compose.yml`）  

*   修改`docker-compose.yml`文件之后，如何使修改的`docker-compose.yml`生效？

    ```java
    docker-compose up --no-deps -d  nginx
    ```

    > 以上表示只是修改了`docker-compose.yml`中关于Nginx相关服务器的配置  

*   容器资源使用情况    
    *   所有运行中的容器资源使用情况：`docker stats`  
    *   查看多个容器资源使用：`docker stats lnmp-nginx lnmp-php lnmp-mysql lnmp-redis`  
    *   自定义格式的docker统计信息：`docker stats --all --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" lnmp-nginx lnmp-php`  

*   docker-compose常用命令

    *   启动`docker-compose.yml`定义的所有服务：`docker-compose up`
    *   重启`docker-compose.yml`中定义的所有服务：`docker-compose restart`
    *   停止`docker-compose.yml`中定义的所有服务(当前目录配置)：`docker-compose stop`
    *   停止现有 docker-compose 中的容器：`docker-compose down`（重要） 

        > 如果你修改了`docker-compose.yml`文件中的内容，请使用该命令，否则配置文件不会生效  

        > 例如：Nginx或者 MySQL配置文件的端口

    *   重新拉取镜像：`docker-compose pull`   
    *   后台启动 docker-compose 中的容器：`docker-compose up -d`   

### 证书管理

#### 本地生成HTTPS

生成本地 HTTPS 加密证书的工具 [mkcert](https://github.com/FiloSottile/mkcert),一个命令就可以生成证书，不需要任何配置。

*   本地本地`C:\Windows\System32\drivers\etc\hosts`文件，添加以下内容

    ```
    127.0.0.1	dnmp.com
    127.0.0.1	www.dnmp.org
    127.0.0.1	www.dnmp.cn
    ```

*   一键生成证书。进入证书存放目录：`$ cd etc/letsencrypt/`   

    *   首次运行时，先生成并安装根证书  

        ```
        $ mkcert --install
        Using the local CA at "C:\Users\tinywan\AppData\Local\mkcert" ✨
        ```

    *   自定义证书签名  

        ```
        $ mkcert dnmp.com "*.dnmp.org" "*.dnmp.cn" localhost 127.0.0.1
        Using the local CA at "C:\Users\tinywan\AppData\Local\mkcert" ✨

        Created a new certificate valid for the following names 📜
        - "dnmp.com"
        - "*.dnmp.org"
        - "*.dnmp.cn"
        - "localhost"
        - "127.0.0.1"

        Reminder: X.509 wildcards only go one level deep, so this won't match a.b.dnmp.org ℹ️

        The certificate is at "./dnmp.com+4.pem" and the key at "./dnmp.com+4-key.pem" ✅
        ```

*   已经生成的证书

    ```
    $ ls etc/letsencrypt/
    dnmp.com+4.pem  dnmp.com+4-key.pem
    ```

*   配置Nginx 虚拟主机配置文件

    ```
    server {
        listen 443 ssl http2;
        server_name www.dnmp.cn;

        ssl_certificate /etc/letsencrypt/dnmp.com+4.pem;
        ssl_certificate_key /etc/letsencrypt/dnmp.com+4-key.pem;

        ...
    }
    ```

*   浏览器访问效果  

    ![images](images/docker-composer-https.png)

#### Docker生成HTTPS

```java
$ docker run --rm  -it -v "D:\Git\docker-lnmp\dev\nginx\v5\etc\letsencrypt":/acme.sh \
-e Ali_Key="LTAIn" -e Ali_Secret="zLzA" neilpang/acme.sh --issue --dns dns_ali \
-d tinywan.top -d *.tinywan.top -d *.frps.tinywan.top
```

> 保存目录
* Linux 环境 : `/home/www/openssl`
* Windows 环境 : `D:\Git\docker-lnmp\dev\nginx\v5\etc\letsencrypt`

> 参数详解（阿里云后台获取的密钥）
* `Ali_Key` 阿里云 AccessKey ID
* `Ali_Secret` 阿里云 Access Key Secret

### 多域名配置
*   域名列表
    *   HTTP访问：
        *   1、http://localhost:8081/
        *   2、http://localhost:8082/
    *   HTTPS访问：    
        *   1、https://docker-v5.frps.tinywan.top/
        *   2、https://docker-v6.frps.tinywan.top/
        *   3、https://docker-v7.frps.tinywan.top/
*   配置文件列表

### 遇到的问题

*   连接Redis报错：`Connection refused`，其他客户端可以正常连接
    > 容器之间相互隔绝，在进行了端口映射之后，宿主机可以通过127.0.0.1:6379访问redis，但php容器不行。在php中可以直接使用`hostname: lnmp-mysql-v3` 来连接redis容器。[原贴地址](https://stackoverflow.com/questions/42360356/docker-redis-connection-refused/42361204)

*   Windows 10 启动错误 `Error starting userland proxy: Bind for 127.0.0.1:3306: unexpected error Permission denied `  
    > 检查本地是否有MySQL已经启动或者端口被占用。关闭即可 

*   Linux 环境启动的时候，MySQL总是`Restarting`：`lnmp-mysql-v6    docker-entrypoint.sh --def ...   Restarting`
    > 解决办法：`cd etc/mysql `，查看文件权限。最暴力的：`rm -r data && mkdir data`解决问题

*   权限问题
    *   遇到`mkdir(): Permission denied`问题，解决办法：`sudo chmod -R 777 runtime`
    *   ThinkPHP5，`ErrorException in File.php line 29 mkdir(): Permission denied` 无法权限被拒绝
        *   执行命令：`chmod -R 777 runtime`
        *   如果图片上传也有问题：`chmod -R 777 upload`
*   `docker-compose.yml`文件格式错误  

    ```
    ERROR: yaml.scanner.ScannerError: while scanning for the next token
    found character '\t' that cannot start any token
    in "./docker-compose.yml", line 68, column 1
    ```
    > 这里的原因是`docker-compose.yml`中最前面用了`tab`，改成空格就好了。对yaml文件格式要求严格  

###  参考

*   [Dockerise your PHP application with Nginx and PHP7-FPM](http://geekyplatypus.com/dockerise-your-php-application-with-nginx-and-php7-fpm/)
*   [docker-openresty](https://github.com/openresty/docker-openresty)
*   [Docker Volume 之权限管理(转)](https://www.cnblogs.com/jackluo/p/5783116.html)
*   [bind-mount或者COPY时需要注意 用户、文件权限 的问题](https://segmentfault.com/a/1190000015233229)
*   [write in shared volumes docker](https://stackoverflow.com/questions/29245216/write-in-shared-volumes-docker)

![images](images/Docker_Install_mostov_twitter-_-facebook-2.png)
