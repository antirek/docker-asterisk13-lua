# Asterisk with Lua support
# 
# VERSION 0.0.2
#
# Contain
#  - Asterisk 13
#  - Lua 5.1
#  - LuaRocks
#  - mongodb driver & luamongo
#  - g729

FROM ubuntu:14.04.4

MAINTAINER Sergey Dmitriev <serge.dmitriev@gmail.com>


## update ubuntu & install reqs

RUN apt-get check && \
    apt-get update && \
    apt-get install -y \ 
        build-essential zip unzip libreadline-dev curl libncurses-dev mc aptitude \
        tcsh scons libpcre++-dev libboost-dev libboost-all-dev libreadline-dev \
        libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev \
        libboost-date-time-dev gcc g++ git lua5.1-dev make libmongo-client-dev \
        dh-autoreconf lame sox libzmq3-dev libzmqpp-dev libtiff-tools && \
    apt-get clean


## PJSIP

RUN apt-get install -y bzip2 && \
    mkdir /tmp/pjproject && \
    curl -sf -o /tmp/pjproject.tar.bz2 -L http://www.pjsip.org/release/2.4.5/pjproject-2.4.5.tar.bz2 && \
    tar -xjvf /tmp/pjproject.tar.bz2 -C /tmp/pjproject --strip-components=1 && \
    cd /tmp/pjproject && \
    ./configure --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr 1> /dev/null && \
    make dep 1> /dev/null && \
    make 1> /dev/null && \
    make install && \
    ldconfig


## Asterisk

RUN curl -sf \
        -o /tmp/asterisk.tar.gz \
        -L http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz && \
    mkdir /tmp/asterisk && \
    tar -xzf /tmp/asterisk.tar.gz -C /tmp/asterisk --strip-components=1 && \
    cd /tmp/asterisk && \
    contrib/scripts/install_prereq install

RUN cd /tmp/asterisk && \
    ./configure --with-pjproject-bundled

RUN cd /tmp/asterisk && \
    make menuselect.makeopts && \
    menuselect/menuselect \
        --disable BUILD_NATIVE \
        --enable chan_pjsip \
        menuselect.makeopts && \
    make && make install && \
    apt-get clean
