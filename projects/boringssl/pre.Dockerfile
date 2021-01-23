FROM fuzzbuilder:latest
MAINTAINER Sanghoon(Kevin) Jeon <kppw99@gmail.com>

# Set environment variable of afl-gcc, afl-g++
ENV PATH=$PATH:/tool/afl-2.52b
ENV AFL_PATH=/tool/afl-2.52b
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ninja-build golang

# Download source code
RUN mkdir -p /exp/boringssl/source
WORKDIR /exp/boringssl/source
RUN git clone https://boringssl.googlesource.com/boringssl
WORKDIR /exp/boringssl/source/boringssl
RUN git checkout d2a0ffdfa781dd6fde482ccb924b4a756731f238
RUN cp -rf /exp/boringssl/fuzzer_main.cc /exp/boringssl/source/boringssl && cp -rf /exp/boringssl/build_new.sh /exp/boringssl/source/boringssl && cp -rf /exp/boringssl/StandaloneFuzzTargetMain.c /exp/boringssl/source/boringssl

# Build project
WORKDIR /exp/boringssl/source/boringssl
RUN chmod 744 ./build_new.sh
RUN rm -f $(find . -name ".bc") && ./build_new.sh seed

WORKDIR /