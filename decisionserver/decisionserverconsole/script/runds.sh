#!/bin/bash
set -x
if [ -n "$DECISION_SERVICE_URL" ] 
then 
	sed -i 's|/DecisionService|'$DECISION_SERVICE_URL'|g' /config/apps/res.war/WEB-INF/web.xml 
else 
	sed -i 's|/DecisionService|http://localhost:9090/DecisionService|g' /config/apps/res.war/WEB-INF/web.xml 
fi
if [ -n "$DBSERVER_NAME" ] 
then 
	sed -i 's|dbserver|'$DBSERVER_NAME'|g' /config/datasource.xml
fi
/opt/ibm/docker/docker-server run defaultServer