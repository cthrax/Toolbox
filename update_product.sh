#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "Must run as root."
    exit 1
fi

build=""

if [ $# = 2 ]
then
    build=-Dtstamp.build=$2
elif [ $# != 1 ]
then
    echo "Must specify assembly"
    exit -1
fi

assyId=$1
board="O3"
extra=""
if [[ $2 != "" ]]; then
    board=$2
fi

productPath="/home/myles/dev/imaging-products"

case $assyId in
    "9081"|"9080")
        cd $productPath/odyssey/$assyId/trunk
        extra="-Dcompress.js=false"
        board="A1"
        ;;
    "9110"|"9111")
        cd $productPath/iliad/$assyId/trunk
        board="O3"
        ;;
    "9260"|"9261")
        cd $productPath/troy/$assyId/trunk
        board="O2"
        ;;
    "2084")
        cd $productPath/moe/$assyId/trunk
        board="O1"
        ;;
    "9310")
        cd $productPath/evolution/$assyId/trunk
        board="A1"
        ;;
    "local"|"x86")
        cd $productPath/../x86omons
        assyId="omonsx86"
        board="A1"
        extra="-Darch=x86"
        ;;
    "*")
        echo "Invalid assembly"
        ;;
esac

/usr/bin/svn up
#echo "No Precache!!!"
/opt/omtools/bin/ombuild -Dproduct=$assyId -Dboard=$board $extra distclean
/opt/omtools/bin/ombuild -Dproduct=$assyId -Dboard=$board $build $extra precache


if [ $? == 0 ]; then
    /opt/omtools/bin/ombuild -Dprecache=true -Dproduct=$assyId -Dboard=$board install
fi
