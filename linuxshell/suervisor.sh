#!/bin/bash
#Use supervisor start all docker
addrs=172.31.1.160:5000
mountdir=172.31.1.160:/install/dockerimages
#Get HostIP
IP=`ifconfig | grep 'inet addr' | grep -v '127.0.0.1' | tail -1 | cut -d: -f2  | awk '{print $1}'`
#Get All images name 
tomcatweb=`docker images | grep 172.31.1.160 | grep web | awk '{print $1}'`
tomcatfront=`docker images | grep 172.31.1.160 | grep front | awk '{print $1}'`
solr=`docker images | grep 172.31.1.160 | grep solr | awk '{print $1}'`
mysql=`docker images | grep 172.31.1.160| awk '{print $1}' | grep mysql`
memcache=`docker images | grep 172.31.1.160 | awk '{print $1}' | grep memcached`
mongodb=`docker images | grep 172.31.1.160 | awk '{print $1}' | grep mongodb`
#Create the required runtime
mysql_d=/mysqldata
tomcatweb_d=/deploy
tomcatfront_d=/deployfront
mongodb_d=/data/db
solrwar_d=/solrdeplpoy
sorlhome_d=/dockersolr
dockerpro=`docker ps | awk '{print $1}'`
#mount images
local_upload=/install/upload
mount_web=/deploy/ROOT/assets
mount_web1=/deploy/cybershop-web-0.0.1-SNAPSHOT/assets
mount_front=/deployfront/cybershop-front-0.0.1-SNAPSHOT/assets
mount_front1=/deployfront/ROOT/assets
create(){
	ls $mysql $tomcatweb_d $mongodb_d $solrwar_d $sorlhome_d $tomcatfront_d >/dev/null  2>&1
	if [ $? -ne 0 ]; then
		echo -e "\033[31m creat Directory \033[0m"
		mkdir -p $mysql $tomcatweb_d $mongodb_d $solrwar_d $sorlhome_d $tomcatfront_d
	else
		echo -e "\033[31m Directory already exists \033[0m"
	fi
}
dockerps(){
	if [ ! $dockerpro ]; then
		echo -e "\033[31m Kill docker ps \033[0m"
		docker rm $(docker ps -a -q)
		sleep 30
	else 
		echo -e "\033[31m Nothting \033[0m"
	fi
}
d_solr(){	
		if [ ! $solr ]; then
			echo -e "\033[31m Downloading Solr images......... \033[0m"
			docker pull $solr
		else
			echo -e "\033[32m $solr exits \033[0m"
		fi
}
d_tomact-web(){
		if [ ! $tomcatweb ]; then
			echo -e "\033[31m Downloading tomcatweb images........ \033[0m"
			docker pull $tomcatweb
		else
			echo -e "\033[32m $tomcatweb exits \033[0m"
		fi
}
d_tomcatfront(){
	if [ ! $tomcatweb ]; then
			echo -e "\033[31m Downloading tomcatfront images........ \033[0m"
			docker pull $tomcatfront
		else
			echo -e "\033[32m $tomcatfront exits \033[0m"
		fi
}
d_mongodb(){	
		if [ ! $mongodb ]; then
			echo -e "\033[31m Downloading Mongodb images......... \033[0m"
			docker pull $mongodb
		else 
			echo -e "\033[32m $mongodb exits \033[0m"
		fi
}
d_memcach(){
		if [ ! $memcache ]; then
			echo -e "\033[31m Downloading Memcach images........ \033[0m"
			docker pull $memcache
		else
			echo -e "\033[32m $memcach exits \033[0m"
		fi
}
d_mysql(){	
		if [ ! $mysql ]; then
			echo -e "\033[31m Downloading Mysql images.......... \033[0m"
			docker pull $mysql
		else
			echo -e "\033[32m $mysql exits \033[0"
		fi
}
#start all images
solr(){
	docker run -d -p  1028:22 --name solr -v $solrwar_d:/solrdeploy -v $sorlhome_d:/solrhome -v /etc/localtime:/etc/localtime $solr
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Solr start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m Start $solr OK and Browse http://$IP:8080 \033[0m"
}
#-p 3306:3306 
mysql(){
	docker run -d -p 1024:22 -p 3306:3306  --name mysql -v $mysql_d:/var/lib/mysql -v /etc/localtime:/etc/localtime $mysql
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Mysql start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m $mysql Ok user:root password:comall2014 \033[0m"
}
#-p 11211:11211 
memcach(){
	docker run -d -p 1027:22 --name memcache -v /etc/localtime:/etc/localtime $memcache
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "memcach start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start $memcache OK and Prot=11211 \033[0m"
}
# -p 27017:27017
mongodb(){
	docker run -d -p 1026:22 --name mongodb -v $mongodb_d:/data/db -v /etc/localtime:/etc/localtime $mongodb
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Mongodb start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start $mongodb OK port=27017 adminport=28017 user:password=null \033[0m"
}
#S-v $local_upload:/deploy/ROOT/assets/upload -v $local_upload:/deploy/cybershop-web-0.0.1-SNAPSHOT/assets/upload 
tomcatweb(){
	docker run -p 1025:22 -p 8081:8080 -d --name web --link mysql:mysql --link mongodb:mongodb --link memcache:memcache --link solr:solr -v $tomcatweb_d:/deploy -v /etc/localtime:/etc/localtime $tomcatweb:web
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Web start suceessful"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start  $tomcatweb:$t-web OK Browse http://$IP \033[0m"
}
# -v $local_upload:/deployfront/ROOT/assets/upload -v  $local_upload:/deployfront/cybershop-front-0.0.1-SNAPSHOT/assets/upload 
tomcatfront(){
	docker run -p 1030:22 -p 80:8080 -d --name front --link mysql:mysql --link mongodb:mongodb --link memcache:memcache --link solr:solr -v $tomcatfront_d:/deployfront -v /etc/localtime:/etc/localtime $tomcatfront:front
	if [ $? -ne 0 ];then
         echo -en "\\033[1;33m"
                echo "front start suceessful"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start  $tomcatfront:$t-front OK Address http://$IP:8081 \033[0m"
}
#$mount_web/upload  $mount_front1/upload  && mount $mountdir $mount_web/upload && mount $mountdir $mount_front1/upload
mountweb(){
	echo "wait 60S"
	sleep 70
	echo -n "Mount upload"
    mkdir   $mount_web1/upload  $mount_front/upload   && mount  -t nfs $mountdir  $mount_web1/upload && mount -t nfs $mountdir  $mount_front/upload 
		if [ $? -ne 0 ]; then
			echo -e "\033[32m  cerate Fail  Trying \033[0m"
		else
			echo -e "\033[32m cerate Ok \033[0m"
		fi
    echo -e "\033[32m mount all front/web suceessful \033[0m"
}
#umount  $mount_web/upload &&   && umount $mount_front1/upload 
stop(){
	echo "umount "
	umount   $mount_web1/upload && umount $mount_front/upload && docker stop web front mysql mongodb memcache solr
	if [ $? -ne 0 ]; then
		echo -en "\\033[1;33m"
        echo "front/web stop/umount suceessful"
        echo -en "\\033[1;39m"
        exit 1
	fi
}
main(){
case $1 in
	dall)
		create;
		dockerps;
		d_solr;
		d_mongodb;
		d_memcach;
		d_mysql;
		d_tomact-web;
		d_tomcatfront;
		solr;
		mongodb;
		memcach;
		mysql;
		tomcatweb;
		tomcatfront;
		mountweb;
		;;
	stop)
		stop;
		dockerps;
		;;
	restart)
		stop;
		dockerps;
		solr;
		mongodb;
		memcach;
		mysql;
		tomcatweb;
		tomcatfront;
		;;
	* )
		echo "Usage:$0(dall|stop|restart)"
	exit 1
esac
}
main $1