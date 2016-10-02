#!/bin/bash
scriptPos=${0%/*}

extraMapnikConfDir=/opt/extra-mapnik-conf

if [ -d $extraMapnikConfDir ]; then
    if [ -f $extraMapnikConfDir/style.xml ]; then
        cp $extraMapnikConfDir/style.xml /opt/mapnik
    fi
    if [ -f $extraMapnikConfDir/datasource-settings.xml.inc ]; then
        cp $extraMapnikConfDir/datasource-settings.xml.inc /opt/mapnik/inc
    fi
fi

if ! [ -d /var/run/renderd ]; then
    mkdir -p /var/run/renderd
fi

/usr/local/bin/renderd

/startApache.sh
