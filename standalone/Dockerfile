FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
LABEL maintainer="Laurent GRATEAU <laurent.grateau@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Laurent GRATEAU <laurent.grateau@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV APP_NAME StandaloneOdm
ENV SCRIPT /script
RUN mkdir /config/resources && \
	mkdir -p $SCRIPT && \
	mkdir -p /config/dbdata

COPY ${ODMDOCKERDIR}/decisioncenter/config/application.xml /config
RUN mv /config/application.xml /config/decisioncenter_application.xml

COPY ${ODMDOCKERDIR}/decisionserver/decisionrunner/config/application.xml /config
RUN mv /config/application.xml /config/decisionrunner_application.xml

COPY ${ODMDOCKERDIR}/decisionserver/decisionserverconsole/config/application.xml /config
RUN mv /config/application.xml /config/decisionserverconsole_application.xml

COPY ${ODMDOCKERDIR}/decisionserver/decisionserverruntime/config/application.xml /config
RUN mv /config/application.xml /config/decisionserverruntime_application.xml

COPY ${ODMDOCKERDIR}/standalone/config /config
COPY ${ODMDOCKERDIR}/standalone/script $SCRIPT

# Begin - Configuration for the database
ENV DRIVER_URL http://central.maven.org/maven2/org/apache/derby/derby/10.12.1.1/derby-10.12.1.1.jar
RUN wget -nv $DRIVER_URL && mv derby* /config/resources
# End - Configuration for the database

ENV CONNECTION_POOL_SIZE 20
ENV SCRIPT /script
RUN chmod -R a+x $SCRIPT

# Sample DB
ADD ${ODMDOCKERDIR}/standalone/data.tar.gz /upload/

# Decision Center
COPY ./teamserver/lib/commons-logging-1.1.jar /config/lib/
COPY ./teamserver/applicationservers/WLP855/teamserver.war /config/apps/
COPY ./teamserver/applicationservers/WLP855/decisioncenter.war /config/apps/
RUN mkdir -p /config/apps/extract && \
    cd /config/apps/extract && \
    unzip -q ../decisioncenter.war && \
    cd ../ && \
    rm -rf decisioncenter.war && \
    mv extract decisioncenter.war && \
    mkdir -p /config/apps/extract && \
    cd /config/apps/extract && \
    unzip -q ../teamserver.war && \
    cd ../ && \
    rm -rf teamserver.war && \
    mv extract teamserver.war && \
    mkdir -p /config/apps/decisioncenter.war/WEB-INF/classes/config && \
    perl -i -p0e 's/(<param-name>com\.ibm\.rules\.decisioncenter\.setup\.configuration-file<\/param-name>.*?<param-value>)(.*?)(<\/param-value>)/\1\/config\/decisioncenter-configuration\.properties\3/s' /config/apps/decisioncenter.war/WEB-INF/web.xml
COPY ${ODMDOCKERDIR}/standalone/decisioncenter-configuration.properties /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties

# Decision Server Console
RUN mkdir -p /config/apps/res.war
COPY ./executionserver/applicationservers/WLP855/res.war /config/apps/res-file.war
RUN cd /config/apps/res.war && \
    unzip -q ../res-file.war && \
    rm ../res-file.war && \
    chmod -R a+x $SCRIPT && \
    perl -i -p0e 's/(<param-name>autoCreateSchema<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml && \
    perl -i -p0e 's/(<param-name>onDocker<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml

# Decision Server Runtime
COPY ./executionserver/applicationservers/WLP855/DecisionService.war /config/apps/
RUN mkdir -p /config/apps/extract && \
    cd /config/apps/extract && \
    unzip -q ../DecisionService.war && \
	cd ../ && \
    rm -rf DecisionService.war && \
    mv extract DecisionService.war && \
    cd /config/apps/DecisionService.war

# Decision Runner
COPY ./executionserver/applicationservers/WLP855/DecisionRunner.war /config/apps/
RUN mkdir -p /config/apps/extract && \
    cd /config/apps/extract && \
    unzip -q ../DecisionRunner.war && \
	cd ../ && \
    rm -rf DecisionRunner.war && \
    mv extract DecisionRunner.war && \
    /opt/ibm/wlp/bin/installUtility install concurrent-1.0 --acceptLicense && \
    cd /config/apps/DecisionRunner.war && \
    chmod -R a+x $SCRIPT
RUN    perl -i -p0e 's/(<param-name>ForceDatabaseTableCreation<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/DecisionRunner.war/WEB-INF/web.xml
VOLUME ["/config/dbdata/"]
EXPOSE 9060 9453

CMD ["/script/runserver.sh"]
