#!/bin/bash
#Use supervisor start all docker
addrs=172.31.1.250
#Get HostIP
IP=`ifconfig | grep 'inet addr' | grep -v '127.0.0.1' | tail -1 | cut -d: -f2  | awk '{print $1}'`
#Get All images name 
tomcat=`docker images | grep 172.31.1.250 | awk '{print $1}' | grep tomcat`
solr=`docker images | grep 172.31.1.250 | awk '{print $1}' | grep solr`
mysql=`docker images | grep 172.31.1.250 | awk '{print $1}' | grep mysql`
memcache=`docker images | grep 172.31.1.250 | awk '{print $1}' | grep memcache`
mongodb=`docker images | grep 172.31.1.250 | awk '{print $1}' | grep mongodb`
#Create the required runtime
mysql_d=/mysqldata
tomcat_d=/deploy
mongodb_d=/data/db
solrwar_d=/solrdeplpy
sorlhome_d=/dockersolr
create(){
	ls $mysql $tomcat_d $mongodb_d $solrwar_d $sorlhome_d >/dev/null  2>&1
	if [ $? -ne 0 ]; then
		echo -e "\033[31m creat Directory \033[0m"
		mkdir -p $mysql $tomcat_d $mongodb_d $solrwar_d $sorlhome_d
	else
		echo -e "\033[31m Directory already exists \033[0m"
	fi

}
#docker(){
#	service docker status | grep running
#	if [ $? -ne 0 ]; then
#		echo -e  "\033[31m docker is NotRunning /var/lib/docker \033[0m"
#		rm -rf /var/lib/docker/* && service docekr restart
#	else
#		echo -e "\033[31m Docker service is running \033[0m"
#	fi
#}
d_solr(){	
		if [ ! $solr ]; then
			echo -e "\033[31m Downloading Solr images......... \033[0m"
			docker pull $adds/solr
		else
			echo -e "\033[32m $solr exits \033[0m"
		fi
}
d_tomact(){
		if [ ! $tomcat ]; then
			echo -e "\033[31m Downloading Tomcat images........ \033[0m"
			docker pull $adds/tomcat
		else
			echo -e "\033[32m $tomcat exits \033[0m"
		fi
}
d_mongodb(){	
		if [ ! $mongodb ]; then
			echo -e "\033[31m Downloading Mongodb images......... \033[0m"
			docker pull $adds/mongodb
		else 
			echo -e "\033[32m $mongodb exits \033[0m"
		fi
}
d_memcach(){
		if [ ! $memcach ]; then
			echo -e "\033[31m Downloading Memcach images........ \033[0m"
			docker pull $adds/memcach
		else
			echo -e "\033[32m $memcach exits \033[0m"
		fi
}
d_mysql(){	
		if [ ! $mysql ]; then
			echo -e "\033[31m Downloading Mysql images.......... \033[0m"
			docker pull $adds/mysql
		else
			echo -e "\033[32m $mysql exits \033[0"
		fi
}
#start all images
solr(){
	docker run -d -p  1028:22 --name solr -v $solrwar_d:/solrdeploy -v $sorlhome_d:/solrhome $solr
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Solr start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m Start $SOLR OK and Browse http://$IP:8080 \033[0m"
}
#-p 3306:3306 
mysql(){
	docker run -d -p 1024:22 --name mysql -v $mysql_d:/var/lib/mysql $mysql
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Mysql start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m $MYSQL Ok and user:root password:comall2014 \033[0m"
}
#-p 11211:11211 
memcach(){
	docker run -d -p 1027:22 --name memcache $memcache
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "memcach start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start $MEMCACHE:$MEMCACHE_TAG OK and Prot=11211 \033[0m"
}
# -p 27017:27017
mongodb(){
	docker run -d -p 1026:22 --name mongodb -v $mongodb_d:/data/db $mongodb
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Mongodb start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start $MONGODB:$MONGODB_TAG OK  and port=27017 adminport=28017 user:password=null \033[0m"
}
#Start Web  --link db:db --link solr:solr --link memcach:memcach --link mongodb:mongodb 
tomcat(){
	docker run -p 1025:22 -p 80:8080 -it --name web --link mysql:mysql --link mongodb:mongodb --link memcache:memcach --link solr:solr -v $tomcat_d:/deploy
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Web start suceessful"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start  $TOMCAT:$TOMCAT_TAG OK Browse http://$IP \033[0m"
}
main(){
case $1 in
	dsolr)
		create;
		d_solr;
		solr;
		;;
	dmongodb)
		d_mongodb;
		mongodb;
		;;
	dmemcach)
		d_memcach;
		memcach;
		;;
	dmysql)
		d_mysql;
		mysql;
		;;
	dtomcat)
		d_tomact;
		tomcat;
		;;	
	dall)
		create;
		d_solr;
		d_mongodb;
		d_memcach;
		d_mysql;
		d_tomact;
		solr;
		mongodb;
		memcach;
		mysql;
		tomcat;
		;;
	* )
		echo "Usage:$0(dsolr|dmongodb|dmysql|dtomcat|dall|dmemcach)"
	exit 1
esac
}
main $1