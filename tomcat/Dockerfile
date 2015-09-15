FROM tutum/tomcat:8.0
MAINTAINER Roman Timushev <rtimushev@qubell.com>

ENV MYSQL_PORT=3306

ADD ROOT.xml /tomcat/conf/Catalina/localhost/ROOT.xml
ADD configure_and_run.sh /configure_and_run.sh
CMD ["/configure_and_run.sh"]
