#!/usr/bin/expect -f 
 set ip 172.31.2.4
 set password comall2014
 set port 1030
 set timeout 10 
 spawn ssh root@$ip -p $port
 expect {
 "*yes/no" { send "yes\r"; exp_continue}
 "*password:" { send "$password\r" }
 }
 expect "#*"
 send "mount /deployfront/ROOT/assets/upload\r"
 send "umount /deployfront/cybershop-front-0.0.1-SNAPSHOT/assets/upload\r"
 send  "exit\r"
 expect eof
