#!/bin/bash
UPDATEDIR=$1
QT_ARCH=$2
GIT_VERSION=$3
DESTDIR=$4
PACKING_TARGET=${UPDATEDIR}/${QT_ARCH}/update-${GIT_VERSION}.tar
JSON_TARGET=$UPDATEDIR/updates.json
URL="http://121.4.142.200:8080/"
mkdir -p $UPDATEDIR/$QT_ARCH
tar cvf ${PACKING_TARGET} -C${DESTDIR} hmr-loader hmr-ui hmr-splash libhmr-lib.so
#tar cvf ${PACKING_TARGET} -C${DESTDIR} hmr-loader hmr-ui hmr-splash libhmr-lib.so config audio data HMRDb.sqlite3
echo "tar cvf ${PACKING_TARGET} -C${DESTDIR}"
MD5=`md5sum $PACKING_TARGET|cut -c -32`
FILE_SIZE=`stat -c %s $PACKING_TARGET`
sed -i -E -e "s/\"latest-version\":\s?\".+?\"/\"latest-version\":\"${GIT_VERSION}\"/g" $JSON_TARGET
sed -i -E -e "s/\"md5\":\s?\".+?\"/\"md5\":\"${MD5}\"/g" $JSON_TARGET
sed -i -E -e "s/\"download-url\":\s?\".+?\"/\"download-url\":\"http:\/\/121.4.142.200:8080\/${QT_ARCH}\/update-${GIT_VERSION}.tar\"/g" $JSON_TARGET
sed -i -E -e "s/\"file-size\":\s?\".+?\"/\"file-size\":\"$FILE_SIZE\"/g" $JSON_TARGET

echo $JSON_TARGET

scp $JSON_TARGET wliu@121.4.142.200:/var/www/html/
scp $PACKING_TARGET wliu@121.4.142.200:/var/www/html/$QT_ARCH

