#! /usr/bin/zsh

if [ "$(id -u)" != "0" ]; then
    echo "Must run as root."
    exit 1
fi

productPath="/home/myles/dev/imaging-products"

for assyId in 9081 9310 2084
do
    /home/myles/bin/update_product.sh $assyId
    if [ $? != 0 ]; then
        echo "Failed to update $assyId"
        exit
    fi

    board="A1"
    buildConf=""
    extra=""
    case $assyId in
        "9081"|"9080")
            buildConf=$productPath/odyssey/$assyId/trunk/build.conf
            board="A1"
            ;;
        "9110"|"9111")
            buildConf=$productPath/iliad/$assyId/trunk/build.conf
            board="O3"
            ;;
        "9260"|"9261")
            buildConf=$productPath/troy/$assyId/trunk/build.conf
            board="O2"
            ;;
        "2084")
            buildConf=$productPath/moe/$assyId/trunk/build.conf
            board="O1"
            ;;
        "9310")
            buildConf=$productPath/evolution/$assyId/trunk/build.conf
            board="A1"
            ;;
        "*")
            echo "Invalid assembly"
            exit
            ;;
    esac

    /opt/omtools/bin/ombuild distclean && /opt/omtools/bin/ombuild configure -Dproduct=$assyId -Dboard=$board && /opt/omtools/bin/ombuild build-rpm -Dis-configured=true -Dcustom.prop.file=$buildConf

    if [ $? != 0 ]; then
        echo "Failed to build rpm for $assyId"
    fi
done

