FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
    JEDOX_HOME=/opt/jedox/ps \
    JEDOX_CONF_BOOTSTRAP=/jedox_bootstrap \
    JEDOX_DATA_BOOTSTRAP=/jedox_data_bootstrap \
    JEDOX_CONF=/jedox_conf

ENV JEDOX_LOG=$JEDOX_HOME/log \
    JEDOX_ETL=$JEDOX_HOME/tomcat/webapps/etlserver/data \
    JEDOX_DATA=$JEDOX_HOME/Data \
    JEDOX_OLAP=$JEDOX_HOME/olap/data \
    JEDOX_STORAGE=$JEDOX_HOME/storage

#ARG JEDOX_DIST=http://cdn.jedox.com/wp-content/downloads/software/2019/1/Jedox_2019_1_lin.tar
#ADD $JEDOX_DIST /tmp/Jedox.tar

COPY Jedox.tar /tmp/Jedox.tar
COPY docker-entrypoint.sh /

RUN    dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get -y -u dist-upgrade \
    && apt-get -y --no-install-recommends install \
            bash iputils-ping libc6-i386 libfreetype6:i386 libfontconfig1:i386 libstdc++6:i386 vim wget \
    && tar -xvf /tmp/Jedox.tar -C /tmp \
    && cd /tmp \
    && ./install.sh --automatic \
    # bootstrap for config-Files - crazy-shit:
    # https://knowledgebase.jedox.com/knowledgebase/backup-jedox-data-batch-files/
    # https://knowledgebase.jedox.com/knowledgebase/jedox-installation-linux-update/
    && mkdir -p  \
        $JEDOX_CONF_BOOTSTRAP/Data/ \
        $JEDOX_CONF_BOOTSTRAP/core-Linux-x86_64/etc/ \
        $JEDOX_CONF_BOOTSTRAP/htdocs/app/etc/ \
        $JEDOX_CONF_BOOTSTRAP/etc/httpd \
        $JEDOX_CONF_BOOTSTRAP/htdocs/app/etc \
        $JEDOX_CONF_BOOTSTRAP/htdocs/app/docroot/pr \
        $JEDOX_CONF_BOOTSTRAP/tomcat/bin/ \
        $JEDOX_CONF_BOOTSTRAP/tomcat/client/config/ \
        $JEDOX_CONF_BOOTSTRAP/tomcat/webapps/etlserver \
        $JEDOX_CONF_BOOTSTRAP/tomcat/webapps/rpc/WEB-INF/classes/ \
        $JEDOX_CONF_BOOTSTRAP/svs-Linux-x86_64/ \
        $JEDOX_DATA_BOOTSTRAP \
        $JEDOX_DATA \
    && chown -R jedoxweb:jedoxweb $JEDOX_HOME \
    # palo & core
    && cp $JEDOX_HOME/Data/palo.ini $JEDOX_CONF_BOOTSTRAP/Data \
    && cp $JEDOX_HOME/core-Linux-x86_64/etc/config.xml $JEDOX_CONF_BOOTSTRAP/core-Linux-x86_64/etc \
    && cp $JEDOX_HOME/core-Linux-x86_64/etc/palo_config.xml $JEDOX_CONF_BOOTSTRAP/core-Linux-x86_64/etc \
    && cp $JEDOX_HOME/core-Linux-x86_64/etc/ui_backend_config.xml $JEDOX_CONF_BOOTSTRAP/core-Linux-x86_64/etc \
    && cp $JEDOX_HOME/core-Linux-x86_64/etc/macro_engine_config.xml $JEDOX_CONF_BOOTSTRAP/core-Linux-x86_64/etc \
    # custom docroot and httpd-config
    && cp $JEDOX_HOME/etc/php.ini $JEDOX_CONF_BOOTSTRAP/etc \
    && cp -r $JEDOX_HOME/etc/httpd/conf $JEDOX_CONF_BOOTSTRAP/etc/httpd \
    && cp $JEDOX_HOME/htdocs/app/etc/config.php $JEDOX_CONF_BOOTSTRAP/htdocs/app/etc \
    && cp -r $JEDOX_HOME/htdocs/app/docroot/pr/custom $JEDOX_CONF_BOOTSTRAP/htdocs/app/docroot/pr \
    # tomcat
    && cp -r $JEDOX_HOME/tomcat/conf $JEDOX_CONF_BOOTSTRAP/tomcat \
    && cp $JEDOX_HOME/tomcat/bin/setenv.sh $JEDOX_CONF_BOOTSTRAP/tomcat/bin \
    && cp $JEDOX_HOME/tomcat/client/config/profiles.xml $JEDOX_CONF_BOOTSTRAP/tomcat/client/config \
    && cp -r $JEDOX_HOME/tomcat/webapps/etlserver/config $JEDOX_CONF_BOOTSTRAP/tomcat/webapps/etlserver \
    && cp $JEDOX_HOME/tomcat/webapps/rpc/WEB-INF/classes/etl-mngr.properties $JEDOX_CONF_BOOTSTRAP/tomcat/webapps/rpc/WEB-INF/classes \
    && cp $JEDOX_HOME/tomcat/webapps/rpc/WEB-INF/classes/store.properties $JEDOX_CONF_BOOTSTRAP/tomcat/webapps/rpc/WEB-INF/classes \
    # svs
    && cp $JEDOX_HOME/svs-Linux-x86_64/sep.inc.php $JEDOX_CONF_BOOTSTRAP/svs-Linux-x86_64 \
    && cp $JEDOX_HOME/svs-Linux-x86_64/php.ini $JEDOX_CONF_BOOTSTRAP/svs-Linux-x86_64 \
    && cp -r $JEDOX_HOME/svs-Linux-x86_64/custom_scripts $JEDOX_CONF_BOOTSTRAP/svs-Linux-x86_64 \
    && cp -r $JEDOX_HOME/svs-Linux-x86_64/sample_scripts $JEDOX_CONF_BOOTSTRAP/svs-Linux-x86_64 \
    # data
    && cp -r $JEDOX_ETL $JEDOX_DATA_BOOTSTRAP/jedox-data-etl \
    && cp -r $JEDOX_DATA $JEDOX_DATA_BOOTSTRAP/jedox-data-data \
    && cp -r $JEDOX_STORAGE $JEDOX_DATA_BOOTSTRAP/jedox-data-storage \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose ports
EXPOSE 80 7777 7775

VOLUME $JEDOX_CONF $JEDOX_LOG $JEDOX_ETL $JEDOX_DATA $JEDOX_OLAP $JEDOX_STORAGE
ENTRYPOINT /docker-entrypoint.sh
