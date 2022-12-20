UPDATEDIR=$1
QT_ARCH=$2
GIT_VERSION=$3
DESTDIR=$4
PACKING_TARGET=${UPDATEDIR}/${QT_ARCH}/update-${GIT_VERSION}.tar
JSON_TARGET=$UPDATEDIR/updates.json
URL="https://wenguo.github.io"
mkdir -p $UPDATEDIR/$QT_ARCH
tar cvf ${PACKING_TARGET} -C${DESTDIR} hmr-loader hmr-ui hmr-splash libhmr-lib.so
MD5=`md5sum $PACKING_TARGET|cut -c -32`
FILE_SIZE=`stat -c %s $PACKING_TARGET`
sed -i -E -e "s/\"latest-version\":\s?\".+?\"/\"latest-version\":\"${GIT_VERSION}\"/g" $JSON_TARGET
sed -i -E -e "s/\"md5\":\s?\".+?\"/\"md5\":\"${MD5}\"/g" $JSON_TARGET
sed -i -E -e "s/\"download-url\":\s?\".+?\"/\"download-url\":\"https:\/\/wenguo.github.io\/${QT_ARCH}\/update-${GIT_VERSION}.tar\"/g" $JSON_TARGET
sed -i -E -e "s/\"file-size\":\s?\".+?\"/\"file-size\":\"$FILE_SIZE\"/g" $JSON_TARGET
                                           
