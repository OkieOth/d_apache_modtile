#!/bin/bash

scriptPos=${0%/*}

source "$scriptPos/conf.sh"
source "$scriptPos/../../../bin/image_conf.sh"

if [ -z "$contOsmDb" ]; then
    echo -en "\033[1;34mVariable contOsmDb not set in conf.sh \033[0m\n"
    exit 1
fi

docker ps -f name="$contNameServer" | grep "$contNameServer" > /dev/null && echo -en "\033[1;31m  the container already runs: $contNameServer \033[0m\n" && exit 1

if ! docker ps -f name="$contOsmDb" | grep "$contOsmDb" > /dev/null
then
    echo -en "\033[1;34mThe needed osm database container don't run: $contOsmDb \033[0m\n"
    exit 1
fi

aktImgName=`docker images |  grep -G "$imageBase *$imageTag *" | awk '{print $1}'`
aktImgVers=`docker images |  grep -G "$imageBase *$imageTag *" | awk '{print $2}'`

if [ "$aktImgName" == "$imageBase" ] && [ "$aktImgVers" == "$imageTag" ]
then
        echo "run container from image: $aktImgName:$aktImgVers"
else
	if docker build -t $imageName $scriptPos/../../../image
    then
        echo -en "\033[1;34m  image created: $imageName \033[0m\n"
    else
        echo -en "\033[1;31m  error while build image: $imageName \033[0m\n"
        exit 1
    fi
fi

extConfDir=$scriptPos/../extraConf
if ! [ -d $extConfDir ]; then
    mkdir -p $extConfDir
fi
extConfDir=`pushd $extConfDir > /dev/null; pwd ; popd > /dev/null`

extSitesConfDir=$scriptPos/../extraSitesConf
if ! [ -d $extSitesConfDir ]; then
    mkdir -p $extSitesConfDir
fi
extSitesConfDir=`pushd $extSitesConfDir > /dev/null; pwd ; popd > /dev/null`

extDataDir=$scriptPos/../extraData
if ! [ -d $extDataDir ]; then
    mkdir -p $extDataDir
fi
extDataDir=`pushd $extDataDir > /dev/null; pwd ; popd > /dev/null`

extMapnikConfDir=$scriptPos/../extraMapnikConf
if ! [ -d $extMapnikConfDir ]; then
    mkdir -p $extMapnikConfDir
fi
extMapnikConfDir=`pushd $extMapnikConfDir > /dev/null; pwd ; popd > /dev/null`

tilesDir=$scriptPos/../tiles
if ! [ -d $tilesDir ]; then
    mkdir -p $tilesDir
fi
tilesDir=`pushd $tilesDir > /dev/null; pwd ; popd > /dev/null`

echo "$toHostPort"

if docker ps -a -f name="$contNameServer" | grep "$contNameServer" > /dev/null; then
    docker start $contNameServer
else
    if [ -z "$toHostPort" ]; then
        docker run -d --name "$contNameServer" --cpuset-cpus=0-2 -v ${extConfDir}:/opt/extra-conf-enabled -v ${extSitesConfDir}:/opt/extra-sites-enabled -v ${extDataDir}:/opt/extra-data -v ${extMapnikConfDir}:/opt/extra-mapnik-conf -v ${tilesDir}:/opt/tiles --link $contOsmDb:osm_db "$imageName"
    else
        echo "map container port 80 -> host port $toHostPort"
#        docker run -it --rm --name "$contNameServer" --cpuset-cpus=0-2 -p $toHostPort:80 -v ${extConfDir}:/opt/extra-conf-enabled -v ${extSitesConfDir}:/opt/extra-sites-enabled -v ${extDataDir}:/opt/extra-data -v ${extMapnikConfDir}:/opt/extra-mapnik-conf -v ${tilesDir}:/opt/tiles --link $contOsmDb:osm_db "$imageName" /bin/bash
        docker run -d --name "$contNameServer" --cpuset-cpus=0-2 -p $toHostPort:80 -v ${extConfDir}:/opt/extra-conf-enabled -v ${extSitesConfDir}:/opt/extra-sites-enabled -v ${extDataDir}:/opt/extra-data -v ${extMapnikConfDir}:/opt/extra-mapnik-conf -v ${tilesDir}:/opt/tiles --link $contOsmDb:osm_db "$imageName"
    fi
fi


