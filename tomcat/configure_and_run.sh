#!/bin/bash -ex

trim() {
    echo "$*" | tr -d '\r\n ' 
}

sed -i "s/MYSQL_HOST/`trim ${MYSQL_HOST}`/" /tomcat/conf/Catalina/localhost/ROOT.xml
sed -i "s/MYSQL_PORT/`trim ${MYSQL_PORT}`/" /tomcat/conf/Catalina/localhost/ROOT.xml
sed -i "s/MYSQL_USERNAME/`trim ${MYSQL_USERNAME}`/" /tomcat/conf/Catalina/localhost/ROOT.xml
sed -i "s/MYSQL_PASSWORD/`trim ${MYSQL_PASSWORD}`/" /tomcat/conf/Catalina/localhost/ROOT.xml

rm -rf /tomcat/webapps/ROOT

wget -v `trim ${WAR_URL}` -O /tomcat/webapps/ROOT.war

/run.sh
