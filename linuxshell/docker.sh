#!/bin/bash
adds=172.31.1.160:5000
web_d=/deploy
mongodb_d=/install/centos/mongodb/data
mysql_d=/mysql-data
#Install Docker Fro Linux
#To determine whether there is a command
#comd(){
#	docker --version  &>/dev/null
#		if [ $? -ne 0 ]; then
#			#rpm epel  Install Docker start Docker 
#		rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 && sed -i '1,5s/#baseurl/baseurl/g' /etc/yum.repos.d/epel.repo && sed -i '1,5s/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/epel.repo && yum -y install docker-io && service docker restart
#		else
#			echo -e "\033[32m $version \033[0m"
#		fi
#}
##Images list
solr=`docker images | grep solr | awk '{print $1}'`
tomcat=`docker images | grep tomcat | awk '{print $1}'`
mongodb=`docker images | grep mongodb | awk '{print $1}'`
memcach=`docker images | grep memcach | awk '{print $1}'`
mysql=`docker images | grep mysql | awk '{print $1}'`
create_d(){
##Mkdir web deploy mongodb data mysqldata 
	ls $web_d $mongodb_d $mysql_d >/dev/null  2>&1
		if [ $? -ne 0 ];then
			echo -e "\033[31m creat Directory \033[0m"
			mkdir -p $web_d $mongodb_d $mysql_d
		else
			echo -e "\033[31m Directory already exists \033[0m"
		fi
}
###One by one
d_solr(){	
		if [ ! $solr ]; then
			echo -e "\033[31m Downloading Solr images......... \033[0m"
			docker pull $adds/solr
		else
			echo -e "\033[32m $solr \033[0m"
		fi
}
d_tomact(){
		if [ ! $tomcat ]; then
			echo -e "\033[31m Downloading Tomcat images........ \033[0m"
			docker pull $adds/tomcat
		else
			echo -e "\033[32m $tomcat \033[0m"
		fi
}
d_mongodb(){	
		if [ ! $mongodb ]; then
			echo -e "\033[31m Downloading Mongodb images......... \033[0m"
			docker pull $adds/mongodb
		else 
			echo -e "\033[32m $mongodb \033[0m"
		fi
}
d_memcach(){
		if [ ! $memcach ]; then
			echo -e "\033[31m Downloading Memcach images........ \033[0m"
			docker pull $adds/memcach
		else
			echo -e "\033[32m $memcach \033[0m"
		fi
}
d_mysql(){	
		if [ ! $mysql ]; then
			echo -e "\033[31m Downloading Mysql images.......... \033[0m"
			docker pull $adds/mysql
		else
			echo -e "\033[32m $mysql \033[0"
		fi
}
main(){
case $1 in
	down )
#		comd;
		create_d;
		d_solr;
		d_tomact;
		d_mongodb;
		d_memcach;
		d_mysql;
		;;
	* )
		echo "Usage:$0(down)"
	exit 1
esac
}
main $1
