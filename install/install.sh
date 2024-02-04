#!/bin/bash

# server info
server_addr=
mysql_root_password=

# private info
my_info_location="Beijing, China"
my_info_email=itwangshuai@126.com
my_info_qq=553704997


#################################################################################################

# php webapp
title_page=风和魔兽
language=chinese-simplified
realmlist=${server_addr}
realmname=黑暗之门
url_base=http://${realmlist}
server_core=1
template=icecrown

# captcha 
captcha_type=9
captcha_key=7f2d5e91-9a1e-4ae7-b0f0-cd0340b1b160
captcha_secret=ES_8227b375652e443993e29ef33e8b918c
captcha_language=zh-CN

# database
db_host=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ws-mysql)
db_port=3306
db_user=acore
db_pass=acore
db_name_auth=acore_auth
db_name_char=acore_characters

# docker
url_docker_nginx=registry.cn-beijing.aliyuncs.com/wshuai/nginx:latest
url_docker_phpfpm=registry.cn-beijing.aliyuncs.com/wshuai/php-fpm:7.2
host_listen_port_nginx=80
host_mount_path_nginx_conf=/mnt/nginx/conf.d
host_mount_path_html=/mnt/php/html
host_listen_port_php=9000

# installer
url_download_install=https://wsnote.oss-cn-beijing-internal.aliyuncs.com/wow/WoWSimpleRegistration.zip
url_download_client=https://us-download.wowdl.net/downloadFiles/Clients/World-of-Warcraft-3.3.5a.12340-zhCN.zip
#path_install=/root/workspace

start_php(){
    # start php
    docker run \
        -d \
        --name ws-php \
        -p ${host_listen_port_php}:9000 \
        -v ${host_mount_path_html}:/www \
        ${url_docker_phpfpm}
    
    configure_php
}
start_nginx(){
    # start nginx
    docker run \
        -d \
        --name ws-nginx \
        -p ${host_listen_port_nginx}:80 \
        -v ${host_mount_path_nginx_conf}:/etc/nginx/conf.d \
        -v ${host_mount_path_html}:/usr/share/nginx/html \
        ${url_docker_nginx}

    configure_nginx
}

configure_php(){
    cd ${host_mount_path_html}

    # download
    wget ${url_download_install}

    # unzip
    unzip -q $(basename "$url_download_install")
    rm -f $(basename "$url_download_install")

    # configure
    configure_register
    configure_light
    configure_advance
    configure_icecrown
    configure_main

    cd -
}

configure_register(){
    local config_file_lang_chinese=application/language/chinese-simplified.php
    sed -i "s/点击这里/点击<a onclick=\"\$(\\\'#register\\\').trigger(\\\'click\\\')\">这里<\/a>/" ${config_file_lang_chinese}
    sed -i "s#这里(合法的)#<a href=${url_download_client}>这里(合法的)</a>#g" ${config_file_lang_chinese}
}

configure_light(){
    # connect rule contact info
    configure_common template/light/tpl/howtoconnect.php template/light/tpl/rules.php template/light/tpl/contactus.php
}

configure_advance(){
    # server info
    local config_file_server_info=template/advance/tpl/server-info.php
    sed -i '/edit_on/d' ${config_file_server_info}
    sed -i 's/x4/x1/g' ${config_file_server_info}

    # faq info
    local config_file_faq_info=template/advance/tpl/main.php
    sed -i "s/require_once 'faq.php';/#require_once 'faq.php';/g" ${config_file_faq_info}

    # connect rule contact info
    configure_common template/advance/tpl/howtoconnect.php template/advance/tpl/rules.php template/advance/tpl/contactus.php
    
}

configure_icecrown(){
    # connect rule contact info
    configure_common template/icecrown/tpl/howtoconnect.php template/icecrown/tpl/rules.php template/icecrown/tpl/contactus.php
}

configure_main(){
    # app config
    local config_file_webapp=application/config/config.php
    cp -f ${config_file_webapp}.sample ${config_file_webapp}
    
    # modify
    sed -i "s/\$config\['page_title'\] = .*/\$config['page_title'] = \"${title_page}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['language'\] = .*/\$config['language'] = \"${language}\";/g" ${config_file_webapp}
    sed -i "s|\$config\['baseurl'\] = .*|\$config['baseurl'] = \"${url_base}\";|g" ${config_file_webapp}
    sed -i "s/\$config\['realmlist'\] = .*/\$config['realmlist'] = \"${realmlist}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['server_core'\] = .*/\$config['server_core'] = \"${server_core}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['template'\] = .*/\$config['template'] = \"${template}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['captcha_type'\] = .*/\$config['captcha_type'] = ${captcha_type};/g" ${config_file_webapp}
    sed -i "s/\$config\['captcha_key'\] = .*/\$config['captcha_key'] = \"${captcha_key}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['captcha_secret'\] = .*/\$config['captcha_secret'] = \"${captcha_secret}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['captcha_language'\] = .*/\$config['captcha_language'] = \"${captcha_language}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['db_auth_host'\] = .*/\$config['db_auth_host'] = \"${db_host}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['db_auth_port'\] = .*/\$config['db_auth_port'] = \"${db_port}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['db_auth_user'\] = .*/\$config['db_auth_user'] = \"${db_user}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['db_auth_pass'\] = .*/\$config['db_auth_pass'] = \"${db_pass}\";/g" ${config_file_webapp}
    sed -i "s/\$config\['db_auth_dbname'\] = .*/\$config['db_auth_dbname'] = \"${db_name_auth}\";/g" ${config_file_webapp}
    sed -i "s#'realmname' => \"Realm 1\", // Realm Name#'realmname' => \"${realmname}\", // Realm Name#g" ${config_file_webapp}
    sed -i "s#'db_host' => \"127.0.0.1\", // MySQL Host IP#'db_host' => \"${db_host}\", // MySQL Host IP#g" ${config_file_webapp}
    sed -i "s#'db_port' => \"3306\", // MySQL Host Port#'db_port' => \"${db_port}\", // MySQL Host Port#g" ${config_file_webapp}
    sed -i "s#'db_user' => \"root\", // MySQL username#'db_user' => \"${db_user}\", // MySQL username#g" ${config_file_webapp}
    sed -i "s#'db_pass' => 'root', // MySQL password#'db_pass' => '${db_pass}', // MySQL password#g" ${config_file_webapp}
    sed -i "s/'db_name' => \"realm1_characters\"/'db_name' => \"${db_name_char}\"/g" ${config_file_webapp}
}

configure_common(){
    # main info
    local config_file_main_info=template/*/tpl/main.php
    sed -i '/edit_on/d' ${config_file_main_info}
    sed -i '/server_patch/d' ${config_file_main_info}

    # connect info
    local config_file_connect_info=${1}
    sed -i '/edit_on/d' ${config_file_connect_info}

    # rule info
    local config_file_rule_info=${2}
    sed -i '/edit_on/d' ${config_file_rule_info}
    sed -i "s/<?php elang('rule'); ?> 1\./<?php elang('rule'); ?> 1. 推荐使用真实可用的邮箱，当您需要找回密码时会非常有用/g" ${config_file_rule_info}
    sed -i "s/<?php elang('rule'); ?> 2\./<?php elang('rule'); ?> 2. 推荐使用易于记忆且保密性强的账号和密码/g" ${config_file_rule_info}
    sed -i "s/<?php elang('rule'); ?> 3\./<?php elang('rule'); ?> 3. 请务必保护好您的账号和密码/g" ${config_file_rule_info}
    sed -i "/<?php elang('rule'); ?> 4\./d" ${config_file_rule_info}
    sed -i "/<?php elang('rule'); ?> 5\./d" ${config_file_rule_info}
    sed -i "/<?php elang('rule'); ?> 6\./d" ${config_file_rule_info}

    # contact info
    local config_file_contact_info=${3}
    sed -i '/edit_on/d' ${config_file_contact_info}
    sed -i '/Discord/d' ${config_file_contact_info}
    sed -i "s/Tehran, Iran/${my_info_location}/g" ${config_file_contact_info}
    sed -i "s/info@example.com/${my_info_email}/g" ${config_file_contact_info}
    sed -i "s/qq1234567/${my_info_qq}/g" ${config_file_contact_info}
}

configure_nginx(){
    local docker_ip_addr_php=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ws-php)
    cat > ${host_mount_path_nginx_conf}/nginx-php.conf << EOT
server {
    listen      80;
    server_name localhost;
    root        /usr/share/nginx/html;

    location / {
        autoindex off;
        if (!-e \$request_filename){
            rewrite ^/(.*)$ /index.php?/\$1 last;    break;
        }
        try_files \$uri \$uri/ /index.php\$is_args\$query_string;
        index   index.html index.htm index.php;
    }

    error_page  500 502 503 504 /50x.html;
    location = /50x.html {
        root    /usr/share/nginx/html;
    }

    location ~ \.php(/|$) {
        fastcgi_index   index.php;
        fastcgi_pass    ${docker_ip_addr_php}:${host_listen_port_php};
        fastcgi_param   SCRIPT_FILENAME /www/\$fastcgi_script_name;
        #fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include         fastcgi_params;
    }
}
EOT
}

main(){
    start_php
    start_nginx
}

main