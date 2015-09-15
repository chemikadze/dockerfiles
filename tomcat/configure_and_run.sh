#!/bin/bash -ex

trim() {
    echo "$*" | tr -d '\r\n ' 
}

if [ -z ${MYSQL_HOST} ]; then
  MYSQL_HOST=`env | grep PORT_${MYSQL_LINK_PORT}_TCP_ADDR | sed -E 's/.*=(.*)/\1/'`
  MYSQL_PORT=`env | grep PORT_${MYSQL_LINK_PORT}_TCP_PORT | sed -E 's/.*=(.*)/\1/'`
fi

sed -i "s/MYSQL_HOST/`trim ${MYSQL_HOST}`/" /tomcat/conf/Catalina/localhost/ROOT.xml
sed -i "s/MYSQL_PORT/`trim ${MYSQL_PORT}`/" /tomcat/conf/Catalina/localhost/ROOT.xml
sed -i "s/MYSQL_USERNAME/`trim ${MYSQL_USERNAME}`/" /tomcat/conf/Catalina/localhost/ROOT.xml
sed -i "s/MYSQL_PASSWORD/`trim ${MYSQL_PASSWORD}`/" /tomcat/conf/Catalina/localhost/ROOT.xml

rm -rf /tomcat/webapps/ROOT

case $WAR_URL in
  http*) 
    wget -v `trim ${WAR_URL}` -O /tomcat/webapps/ROOT.war
    ;;
  file*)
    cp -v `echo $WAR_URL | sed -E 's|^file://||'` /tomcat/webapps/ROOT.war
    ;;
esac

/run.sh
