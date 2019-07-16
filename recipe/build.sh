#!/usr/bin/env bash

build_linux()
{
    find -type f -exec sed -i'' "s|/etc/cni/net\.d|$PREFIX/etc/cni/net\.d|g" {} \;


    ORG_PATH="github.com/containernetworking"
    REPO_PATH="${ORG_PATH}/cni"

    if [ ! -h gopath/src/${REPO_PATH} ]; then
        mkdir -p gopath/src/${ORG_PATH}
        ln -s ../../../.. gopath/src/${REPO_PATH} || exit 255
    fi

    export GO15VENDOREXPERIMENT=1
    export GOPATH=${PWD}/gopath

    echo "Building API"
    go build "$@" ${REPO_PATH}/libcni

    echo "Building reference CLI"
    go build -o ${PWD}/bin/cnitool "$@" ${REPO_PATH}/cnitool

    cp scripts/*.sh $PREFIX/bin
    cp bin/cnitool $PREFIX/bin
    mkdir -p $PREFIX/lib/cni && touch $PREFIX/lib/cni/.mkdir
    mkdir -p $PREFIX/etc/cni/net.d && touch $PREFIX/etc/cni/net.d/.mkdir

    for i in activate deactivate; do
        dest_dir=$PREFIX/etc/conda/$i.d
        mkdir -p $dest_dir
        cp $RECIPE_DIR/$i.sh $dest_dir/cni.sh
    done
}

case $(uname -s) in
    "Linux")
        build_linux
        ;;
esac
