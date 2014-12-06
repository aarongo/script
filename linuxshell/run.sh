#!/bin/bash
#这个是启动不带有supervisor的所有images
#Host IP addrs
IP=`ifconfig | grep 'inet addr' | grep -v '127.0.0.1' | tail -1 | cut -d: -f2  | awk '{print $1}'`
#This is images names test
SOLR=`docker images | grep solr | awk '{print $1}'`
MYSQL=`docker images | grep mysql | awk '{print $1}'`
MEMCACHE=`docker images | grep memcach | awk '{print $1}'`
MONGODB=`docker images | grep mongodb | awk '{print $1}'`
TOMCAT=`docker images | grep tomcat | awk '{print $1}'`
#This is images Tag
SOLR_TAG=`docker images | grep solr | awk '{print $2}'`
MYSQL_TAG=`docker images | grep mysql | awk '{print $2}'`
MEMCACHE_TAG=`docker images | grep memcach | awk '{print $2}'`
MONGODB_TAG=`docker images | grep mongodb | awk '{print $2}'`
TOMCAT_TAG=`docker images | grep tomcat | awk '{print $2}'`
#Docker Process
SOLR_P=solr
TOMCAT_P=web
MEMCACHE_P=memcach
MONGODB_P=mongodb
MYSQL_P=db
#Output mirror and tags
echo $SOLR:$SOLR_TAG
echo $MYSQL:$MYSQL_TAG
echo $MEMCACHE:$MEMCACHE_TAG
echo $MONGODB:$MONGODB_TAG
echo $TOMCAT:$TOMCAT_TAG
#Dependent on container for web start -p 8983:8983
solr(){
	docker run -d  --name solr $SOLR:$SOLR_TAG
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Solr start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m Start $SOLR:$SOLR_TAG OK and Browse http://$IP:8983/solr \033[0m"
}
#-p 3306:3306 
mysql(){
	docker run -d -v /mysql-data:/var/lib/mysql --name db $MYSQL:$MYSQL_TAG
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Mysql start Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m $MYSQL:$MYSQL_TAG Ok and user:comall password:comall2014 \033[0m"
}
#-p 11211:11211 
memcach(){
	docker run -d  --name memcach $MEMCACHE:$MEMCACHE_TAG
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
	docker run -d -v /install/centos/mongodb/data:/data/db --name mongodb $MONGODB:$MONGODB_TAG
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
	docker run -d -p 80:8080 -v /deploy:/deploy --name web --link db:db --link solr:solr --link memcach:memcach --link mongodb:mongodb $TOMCAT:$TOMCAT_TAG
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Web start suceessful"
                echo -en "\\033[1;39m"
                exit 1
        fi
	echo -e "\033[32m start  $TOMCAT:$TOMCAT_TAG OK Browse http://$IP \033[0m"
}
#Delete solr Docker process
_solr(){
	if [ ! $SOLR_P ]; then
			echo -e "\033[31m Solr Process is NOT Running \033[0m"
		else
			echo -e "\033[32m Kill solr \033[0m"
			docker stop $SOLR_P
		fi
}
#Delete mysql Docker process
_mysql(){
	if [ ! $MYSQL_P ]; then
			echo -e "\033[31m Mysql Process is NOT Running \033[0m"
		else
			echo -e "\033[32m Kill Mysql \033[0m"
			docker stop $MYSQL_P
		fi
}
#Delete memcach Docker process
_memcach(){
	if [ ! $MEMCACHE_P ]; then
			echo -e "\033[31m MEMCACHE Process is NOT Running \033[0m"
		else
			echo -e "\033[32m Kill MEMCACHE \033[0m"
			docker stop $MEMCACHE_P
		fi
}
#Delet mongodb Docker process
_mongodb(){
	if [ ! $MONGODB_P ]; then
			echo -e "\033[31m Mongodb Process is NOT Running \033[0m"
		else
			echo -e "\033[32m Kill Mongodb \033[0m"
			docker stop $MONGODB_P
		fi
}
#Delet mongodb Docker process
_tomact(){
		if [ ! $TOMCAT_P ]; then
			echo -e "\033[31m tomcat Process is NOT Running \033[0m"
		else
			echo -e "\033[32m Kill tomcat \033[0m"
			docker stop $MTOMCAT_P
		fi
}
#Stop All
_all(){
	docker stop $SOLR_P  $TOMCAT_P $MEMCACHE_P $MONGODB_P  $MYSQL_P
}
#Remove residual container
_all_(){
	docker rm $(docker ps -a)
}
#Must be performed in order
main(){
case $1 in
	solr)
		solr;
		;;
	mysql)
		mysql;
		;;
	memcach)
		memcach;
		;;
	mongodb)
		mongodb;
		;;
	tomcat)
		tomcat;
		;;
	all)
		solr;
		mysql;
		memcach;
		mongodb;
		tomcat;
		;;
	rmsolr)
		_solr;
		;;
	rmmysql)
		_mysql;
		;;
	rmmemcach)
		_memcach;
		;;
	rmmongodb)
		_mongodb;
		;;
	rmtomact)
		_tomact;
		;;
	rmall)
		_all;
		;;
	remove)
		_all_;
		;;
	*)
	echo "Usage:$0(solr|mysql|memcach|mongodb|tomcat|all|rmsolr|rmmysql|rmmemcach|rmmongodb|rmtomact|rmall|remove)"
	exit 1
esac
}
main $1
