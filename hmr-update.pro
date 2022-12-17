TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

TARGET = hmr-killer

SOURCES +=\
    src/main.cpp

DESTDIR = $$PWD/../binaries/$${QT_ARCH}

unix:!macx{
include(../gitversion.pri)
}

UPDATEDIR = $$PWD/../hmr-update
URL=https:\/\/wenguo.github.io
exists($$UPDATEDIR){
    PRE_TARGETDEPS +=  $$UPDATEDIR/updates.json

    packingTAR.target = $$UPDATEDIR/$${QT_ARCH}/update.tar
    packingTAR.commands = $$quote(tar cvf $$packingTAR.target -C$$DESTDIR hmr-loader hmr-ui hmr-splash libhmr-lib.so)

    updatingJSON.target =    $$UPDATEDIR/updates.json
    updatingJSON.commands = $$quote(sed -i -E -e \'s/\"latest-version\":\s?\".+?\"/\"latest-version\":\"$${VERSION}\"/g\' \
                                           -e \'s/\"md5\":\s?\".+?\"/\"md5\":\"$$system(md5sum  $$packingTAR.target | cut -c -32)\"/g\' \
                                           -e \'s/\"download-url\":\s?\".+?\"/\"download-url\":\"$${URL}\/$${QT_ARCH}\/update.tar\"/g\' \
                                           $$UPDATEDIR/updates.json)
    updatingJSON.depends = checkingDIR packingTAR

    checkingDIR.commands = $$quote(rm $$packingTAR.target & mkdir -p $$UPDATEDIR/$${QT_ARCH})


    QMAKE_EXTRA_TARGETS += packingTAR checkingDIR updatingJSON
}
