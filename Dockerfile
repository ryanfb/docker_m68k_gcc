FROM ubuntu:latest

ENV BINUTILS_VERSION binutils-2.27
ENV GCC_VERSION gcc-6.3.0
ENV ISL_VERSION isl-0.16.1
ENV CLOOG_VERSION cloog-0.18.1
ENV NEWLIB_VERSION newlib-2.4.0

ENV PREFIX /opt/m68k/$GCC_VERSION
ENV TARGET m68k-elf
ENV ENABLE_LANGUAGES c,c++

RUN apt-get update && apt-get install -y wget unzip build-essential gcc-5 libgmp-dev libmpfr-dev libmpc-dev

RUN mkdir /tmp/downloads
WORKDIR /tmp/downloads
RUN wget http://ftp.gnu.org/pub/gnu/binutils/$BINUTILS_VERSION.tar.bz2
RUN wget http://ftp.gnu.org/pub/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.bz2
RUN wget ftp://gcc.gnu.org/pub/gcc/infrastructure/$ISL_VERSION.tar.bz2
RUN wget ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOG_VERSION.tar.gz
RUN wget ftp://sourceware.org/pub/newlib/$NEWLIB_VERSION.tar.gz

RUN mkdir /tmp/build
WORKDIR /tmp/build
RUN tar jxvf ../downloads/$BINUTILS_VERSION.tar.bz2
RUN mkdir /tmp/build/binutils-obj
WORKDIR /tmp/build/binutils-obj
RUN ../$BINUTILS_VERSION/configure --prefix=$PREFIX --target=$TARGET
RUN make
RUN make install
WORKDIR /tmp/build
RUN tar jxvf ../downloads/$GCC_VERSION.tar.bz2
RUN tar jxvf ../downloads/$ISL_VERSION.tar.bz2
RUN tar zxvf ../downloads/$CLOOG_VERSION.tar.gz
RUN mv $ISL_VERSION ./$GCC_VERSION/isl
RUN mv $CLOOG_VERSION ./$GCC_VERSION/cloog
RUN mkdir /tmp/build/gcc-obj
WORKDIR /tmp/build/gcc-obj
RUN ../$GCC_VERSION/configure --prefix=$PREFIX --target=$TARGET --enable-languages=$ENABLE_LANGUAGES --with-newlib --disable-libmudflap --disable-libssp --disable-libgomp --disable-libstdcxx-pch --disable-threads --disable-nls --disable-libquadmath --with-gnu-as --with-gnu-ld --without-headers
RUN make all-gcc
RUN make install-gcc

ENV PATH=$PATH:$PREFIX/bin

WORKDIR /tmp/build
RUN tar zvxf ../downloads/$NEWLIB_VERSION.tar.gz
RUN mv $NEWLIB_VERSION/libgloss/m68k/io-read.c $NEWLIB_VERSION/libgloss/m68k/io-read.bak
RUN sed -e 's/ssize_t/_READ_WRITE_RETURN_TYPE/g' $NEWLIB_VERSION/libgloss/m68k/io-read.bak > $NEWLIB_VERSION/libgloss/m68k/io-read.c
RUN rm $NEWLIB_VERSION/libgloss/m68k/io-read.bak
RUN mv $NEWLIB_VERSION/libgloss/m68k/io-write.c $NEWLIB_VERSION/libgloss/m68k/io-write.bak
RUN sed -e 's/ssize_t/_READ_WRITE_RETURN_TYPE/g' $NEWLIB_VERSION/libgloss/m68k/io-write.bak > $NEWLIB_VERSION/libgloss/m68k/io-write.c
RUN rm $NEWLIB_VERSION/libgloss/m68k/io-write.bak
RUN mkdir /tmp/build/newlib-obj
WORKDIR /tmp/build/newlib-obj
RUN ../$NEWLIB_VERSION/configure --prefix=$PREFIX --target=$TARGET --disable-newlib-multithread --disable-newlib-io-float --enable-lite-exit --disable-newlib-supplied-syscalls
RUN make
RUN make install

WORKDIR /tmp/build/gcc-obj
RUN make all-target-libgcc all-target-libstdc++-v3
RUN make install-target-libgcc install-target-libstdc++-v3
