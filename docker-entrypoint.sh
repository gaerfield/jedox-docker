#!/usr/bin/env bash

INITIALIZATION_COMPLETED_FILE=$JEDOX_CONF/.initialized

function log_info {
  echo -e $(date '+%Y-%m-%d %T')"\e[1;32m $@\e[0m"
}

function log_error {
  echo -e >&2 $(date +"%Y-%m-%d %T")"\e[1;31m $@\e[0m"
}

function shutdown_jedox {
  log_info "shutting down jedox"
  $JEDOX_HOME/jedox-suite.sh stop
  exit 0
}

function assert_initialization {
  if [ ! -e $INITIALIZATION_COMPLETED_FILE ]; then
    log_info "initializing jedox"
    mkdir -p $JEDOX_LOG/tomcat
    cp -r $JEDOX_CONF_BOOTSTRAP/* $JEDOX_CONF
    cp -r $JEDOX_DATA_BOOTSTRAP/jedox-data-etl/* $JEDOX_ETL
    cp -r $JEDOX_DATA_BOOTSTRAP/jedox-data-data/* $JEDOX_DATA
    cp -r $JEDOX_DATA_BOOTSTRAP/jedox-data-storage/* $JEDOX_STORAGE
    touch $INITIALIZATION_COMPLETED_FILE
  else
    log_info "skipping initialization, $INITIALIZATION_COMPLETED_FILE already exists"
  fi
}

function replace_config {
  log_info "copying config"
  # palo & core
  cp $JEDOX_CONF/Data/palo.ini $JEDOX_HOME/Data
  cp $JEDOX_CONF/core-Linux-x86_64/etc/config.xml $JEDOX_HOME/core-Linux-x86_64/etc
  cp $JEDOX_CONF/core-Linux-x86_64/etc/palo_config.xml $JEDOX_HOME/core-Linux-x86_64/etc
  cp $JEDOX_CONF/core-Linux-x86_64/etc/ui_backend_config.xml $JEDOX_HOME/core-Linux-x86_64/etc
  cp $JEDOX_CONF/core-Linux-x86_64/etc/macro_engine_config.xml $JEDOX_HOME/core-Linux-x86_64/etc
  # custom docroot and httpd-config
  cp $JEDOX_CONF/etc/php.ini $JEDOX_HOME/etc
  cp -r $JEDOX_CONF/etc/httpd/conf $JEDOX_HOME/etc/httpd
  cp $JEDOX_CONF/htdocs/app/etc/config.php $JEDOX_HOME/htdocs/app/etc
  cp -r $JEDOX_CONF/htdocs/app/docroot/pr/custom $JEDOX_HOME/htdocs/app/docroot/pr
  # tomcat
  cp -r $JEDOX_CONF/tomcat/conf $JEDOX_HOME/tomcat
  cp $JEDOX_CONF/tomcat/bin/setenv.sh $JEDOX_HOME/tomcat/bin
  cp $JEDOX_CONF/tomcat/client/config/profiles.xml $JEDOX_HOME/tomcat/client/config
  cp -r $JEDOX_CONF/tomcat/webapps/etlserver/config $JEDOX_HOME/tomcat/webapps/etlserver
  cp $JEDOX_CONF/tomcat/webapps/rpc/WEB-INF/classes/etl-mngr.properties $JEDOX_HOME/tomcat/webapps/rpc/WEB-INF/classes
  cp $JEDOX_CONF/tomcat/webapps/rpc/WEB-INF/classes/store.properties $JEDOX_HOME/tomcat/webapps/rpc/WEB-INF/classes
  # svs
  cp $JEDOX_CONF/svs-Linux-x86_64/sep.inc.php $JEDOX_HOME/svs-Linux-x86_64
  cp $JEDOX_CONF/svs-Linux-x86_64/php.ini $JEDOX_HOME/svs-Linux-x86_64
  cp -r $JEDOX_CONF/svs-Linux-x86_64/custom_scripts $JEDOX_HOME/svs-Linux-x86_64
  cp -r $JEDOX_CONF/svs-Linux-x86_64/sample_scripts $JEDOX_HOME/svs-Linux-x86_64

  chmod -R a+rw $JEDOX_HOME
  chown -R jedoxweb:jedoxweb $JEDOX_HOME
}

trap "shutdown_jedox" HUP INT QUIT TERM

assert_initialization
replace_config

log_info "starting jedox-suite"
$JEDOX_HOME/jedox-suite.sh start

tail -F $JEDOX_LOG/core.log
