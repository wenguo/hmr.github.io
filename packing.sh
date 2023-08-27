#!/bin/bash
UPDATEDIR=$1
QT_ARCH=$2
GIT_VERSION=$3
DESTDIR=$4
PACKING_TARGET=${UPDATEDIR}/${QT_ARCH}/update-${GIT_VERSION}.tar
JSON_TARGET=$UPDATEDIR/updates.json
URL="http://121.4.142.200:8080/"
mkdir -p $UPDATEDIR/$QT_ARCH
mkdir -p ${DESTDIR}/lib

if [ $QT_ARCH == 'x86_64' ]
then
    cp -rdv ~/workspace/HMR/QSimpleUpdater/build5.15/libQSimpleUpdater.so* ${DESTDIR}/lib
else
    cp -rdv ~/workspace/HMR/QSimpleUpdater/build-px30-5.15.2/libQSimpleUpdater.so* ${DESTDIR}/lib
    cp -rdv ~/workspace/HMR/libnymea-networkmanager/build-px30-5.15/libnymea-networkmanager/libnymea-networkmanager.so* ${DESTDIR}/lib
fi

tar cvf ${PACKING_TARGET}  -C${DESTDIR} hmr-loader hmr-ui hmr-splash libhmr-lib.so lib/
#tar cvf ${PACKING_TARGET} -C${DESTDIR} hmr-loader hmr-ui hmr-splash libhmr-lib.so config audio data HMRDb.sqlite3
echo "tar cvf ${PACKING_TARGET}  hmr-loader hmr-ui hmr-splash libhmr-lib.so lib/"
MD5=`md5sum $PACKING_TARGET|cut -c -32`
FILE_SIZE=`stat -c %s $PACKING_TARGET`
sed -i -E -e "s/\"latest-version\":\s?\".+?\"/\"latest-version\":\"${GIT_VERSION}\"/g" $JSON_TARGET
sed -i -E -e "s/\"md5\":\s?\".+?\"/\"md5\":\"${MD5}\"/g" $JSON_TARGET
sed -i -E -e "s/\"arch\":\s?\".+?\"/\"arch\":\"${QT_ARCH}\"/g" $JSON_TARGET
sed -i -E -e "s/\"download-url\":\s?\".+?\"/\"download-url\":\"http:\/\/121.4.142.200:8080\/${QT_ARCH}\/update-${GIT_VERSION}.tar\"/g" $JSON_TARGET
sed -i -E -e "s/\"file-size\":\s?\".+?\"/\"file-size\":\"$FILE_SIZE\"/g" $JSON_TARGET

if [ $QT_ARCH == 'arm64' ]
#|| [ $QT_ARCH == 'x86_64' ]
then
    scp $JSON_TARGET wliu@121.4.142.200:/var/www/html/
    scp $PACKING_TARGET wliu@121.4.142.200:/var/www/html/$QT_ARCH
fi
