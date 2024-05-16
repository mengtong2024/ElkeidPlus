#!/bin/bash
rm -rf /ko_output || true
mkdir -p /ko_output
BUILD_VERSION=$(cat LKM/src/init.c | grep MODULE_VERSION | awk -F '"' '{print $2}')
KO_NAME=$(grep "MODULE_NAME" ./LKM/Makefile | grep -m 1 ":=" | awk '{print $3}')

enableGcc8(){
    export CC=/opt/rh/devtoolset-8/root/usr/bin/gcc
    export CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp
    export CXX=/opt/rh/devtoolset-8/root/usr/bin/c++
}

enableGcc9(){
    export CC=/opt/rh/devtoolset-9/root/usr/bin/gcc
    export CPP=/opt/rh/devtoolset-9/root/usr/bin/cpp
    export CXX=/opt/rh/devtoolset-9/root/usr/bin/c++
}

enableGcc10(){
    export CC=/opt/rh/devtoolset-10/root/usr/bin/gcc
    export CPP=/opt/rh/devtoolset-10/root/usr/bin/cpp
    export CXX=/opt/rh/devtoolset-10/root/usr/bin/c++
}

disableGcc(){
    unset CC
    unset CPP
    unset CXX
}

yum remove -y kernel-devel kernel-lt-devel kernel-ml-devel &> /dev/null
yum remove -y kernel-tools kernel-lt-tools kernel-ml-tools  &> /dev/null
yum remove -y kernel-tools-libs kernel-lt-tools-libs kernel-ml-tools-libs   &> /dev/null

cd /root
wget https://mirrors.portworx.com/mirrors/http/mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-devel-4.15.4-1.el7.elrepo.x86_64.rpm
wget https://mirrors.portworx.com/mirrors/http/mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-tools-4.15.4-1.el7.elrepo.x86_64.rpm
wget https://mirrors.portworx.com/mirrors/http/mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-tools-libs-4.15.4-1.el7.elrepo.x86_64.rpm

rpm -i --force ./kernel-ml-devel-4.15.4-1.el7.elrepo.x86_64.rpm ./kernel-ml-tools-4.15.4-1.el7.elrepo.x86_64.rpm ./kernel-ml-tools-libs-4.15.4-1.el7.elrepo.x86_64.rpm

cp /usr/src/kernels/4.15.4-1.el7.elrepo.x86_64/tools/objtool/objtool /usr/bin/objtool
cp /usr/bin/objtool /bin/objtool
cd -

SPECS_VERSION="4.15."

for each_tag in `curl https://mirror.rcg.sfu.ca/mirror/ELRepo/kernel/el7/x86_64/RPMS/ | grep el7.elrepo.x86_64.rpm | grep kernel-ml-devel | sed -r 's/.*href="([^"]+).*/\1/g' | sed -r 's/kernel-ml-devel-([^"]+).el7.elrepo.x86_64.rpm/\1/g'`
do 
    wget -q "https://mirror.rcg.sfu.ca/mirror/ELRepo/kernel/el7/x86_64/RPMS/kernel-ml-devel"-$each_tag.el7.elrepo.x86_64.rpm
    wget -q "https://mirror.rcg.sfu.ca/mirror/ELRepo/kernel/el7/x86_64/RPMS/kernel-ml-tools"-$each_tag.el7.elrepo.x86_64.rpm
    wget -q "https://mirror.rcg.sfu.ca/mirror/ELRepo/kernel/el7/x86_64/RPMS/kernel-ml-tools-libs"-$each_tag.el7.elrepo.x86_64.rpm
    
    yum remove -y kernel-devel kernel-lt-devel kernel-ml-devel &> /dev/null
    yum remove -y kernel-tools kernel-lt-tools kernel-ml-tools  &> /dev/null
    yum remove -y kernel-tools-libs kernel-lt-tools-libs kernel-ml-tools-libs   &> /dev/null

    if [[ $each_tag =~ $SPECS_VERSION ]]
    then
        cp /usr/bin/objtool /usr/src/kernels/$each_tag.el7.elrepo.x86_64/tools/objtool/objtool 
    fi

    disableGcc
    if [[ $each_tag == 4.18* || $each_tag == 4.19*  ||  $each_tag == 4.20* || $each_tag == 5.* ]]; then
        enableGcc8
    fi

    if [[ $each_tag == 5.10.* || $each_tag == 5.11.*  ||  $each_tag == 5.12.*  ||  $each_tag == 5.13.*  ||  $each_tag == 5.14.*  ||  $each_tag == 5.15.*  ||  $each_tag == 5.16.*  ||  $each_tag == 5.17.*  || $each_tag == 5.18.*  ||  $each_tag == 5.19.*  ||  $each_tag == 5.20.* ]] ; then
        enableGcc9
    fi

    if [[ $each_tag == 6.* ]]; then
        enableGcc10
    fi

    rpm -i --force ./kernel*.rpm 
    rm -f ./kernel*.rpm 
    KV=$each_tag.el7.elrepo.x86_64
    KVERSION=$KV make -C ./LKM clean || true 
    if [ -z $CC ];then
        export CC=gcc
    fi
    echo "$CC --version =>"
    $CC --version
    BATCH=true KVERSION=$KV make -C ./LKM -j all | tee /ko_output/${KO_NAME}_${BUILD_VERSION}_${KV}_amd64.log || true 
    sha256sum  ./LKM/${KO_NAME}.ko | awk '{print $1}' > /ko_output/${KO_NAME}_${BUILD_VERSION}_${KV}_amd64.sign  || true  

    if [ -s /ko_output/${KO_NAME}_${BUILD_VERSION}_${KV}_amd64.sign ]; then
        # The file is not-empty.
        echo ok > /dev/null
    else
        # The file is empty.
        rm -f /ko_output/${KO_NAME}_${BUILD_VERSION}_${KV}_amd64.sign
    fi
    mv ./LKM/${KO_NAME}.ko /ko_output/${KO_NAME}_${BUILD_VERSION}_${KV}_amd64.ko || true 
    KVERSION=$KV  make -C ./LKM clean || true
done