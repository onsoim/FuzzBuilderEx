FROM fuzzbuilderex:base

LABEL maintainer="onsoim <onsoim@gmail.com>"

# [expat]
ENV NAME expat

COPY . /exp/expat

# 1. Prepare source codes
RUN mkdir -p /exp/expat/source && cd /exp/expat/source && git clone https://github.com/libexpat/libexpat && cd /exp/expat/source/libexpat && git checkout 39e487da353b20bb3a724311d179ba0fddffc65b && cp /exp/expat/fuzzer_main.cc /exp/expat/source/libexpat/expat && cp /exp/oss-fuzz/source/projects/expat/parse_fuzzer.cc /exp/expat/source/libexpat/expat && cp /exp/expat/build_new.sh /exp/expat/source/libexpat/expat && cp /exp/expat/StandaloneFuzzTargetMain.c /exp/expat/source/libexpat/expat

# 2. FuzzBuilder (seed)
WORKDIR /exp/expat/source/libexpat/expat
RUN chmod +x build_new.sh && ./build_new.sh seed && /tool/afl-2.52b/afl-clang -emit-llvm -DHAVE_CONFIG_H -I. -I.. -DHAVE_EXPAT_CONFIG_H -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -c lib/xmlparse.c -fPIC -DPIC && /tool/fuzzbuilder seed /exp/expat/seed.conf && /tool/afl-2.52b/afl-clang -DHAVE_CONFIG_H -I. -I.. -DHAVE_EXPAT_CONFIG_H -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -c xmlparse.bc.mod.bc -fPIC -DPIC -o xmlparse.o && ar r lib/.libs/libexpat.a xmlparse.o && rm -f tests/runtests && make check && mv /tmp/fuzzbuilder.collect . && python /tool/seed_maker.py fuzzbuilder.collect seed_fb && mkdir -p /exp/expat/seed/fuzzbuilder && mv /exp/expat/source/libexpat/expat/seed_fb /exp/expat/seed/fuzzbuilder/org

# 3. OSS-Fuzz (exec, seed)
RUN cd /exp/expat/source/libexpat/expat && ./build_new.sh && mkdir -p /exp/expat/bin/fuzz/oss-fuzz && mv /exp/expat/source/libexpat/expat/*_fuzzer /exp/expat/bin/fuzz/oss-fuzz && mkdir -p /exp/expat/seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer /exp/expat/seed/oss-fuzz/org/parse_UTF_16BE_fuzzer /exp/expat/seed/oss-fuzz/org/parse_UTF_16LE_fuzzer /exp/expat/seed/oss-fuzz/org/parse_US_ASCII_fuzzer /exp/expat/seed/oss-fuzz/org/parse_UTF_16_fuzzer /exp/expat/seed/oss-fuzz/org/parse_UTF_8_fuzzer && echo "AAAAAAAA" > /exp/expat/seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer/seed.1 && echo "AAAAAAAA" > /exp/expat/seed/oss-fuzz/org/parse_UTF_16BE_fuzzer/seed.1 && echo "AAAAAAAA" > /exp/expat/seed/oss-fuzz/org/parse_UTF_16LE_fuzzer/seed.1 && echo "AAAAAAAA" > /exp/expat/seed/oss-fuzz/org/parse_US_ASCII_fuzzer/seed.1 && echo "AAAAAAAA" > /exp/expat/seed/oss-fuzz/org/parse_UTF_16_fuzzer/seed.1 && echo "AAAAAAAA" > /exp/expat/seed/oss-fuzz/org/parse_UTF_8_fuzzer/seed.1

# 5. FuzzBuilder (exec)
RUN cd /exp/expat/source/libexpat/expat/tests && /tool/afl-2.52b/afl-clang -emit-llvm -DHAVE_CONFIG_H -I. -I.. -I./../lib -DHAVE_EXPAT_CONFIG_H -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -c runtests.c && /tool/fuzzbuilder exec /exp/expat/XML_Parse.conf && /tool/afl-2.52b/afl-clang -DHAVE_CONFIG_H -I. -I.. -I./../lib -DHAVE_EXPAT_CONFIG_H -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -o runtests.o -c runtests.bc.mod.bc && AFL_USE_ASAN=1 /tool/afl-2.52b/afl-clang -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -m32 -g -fno-strict-aliasing -o XML_Parse_fuzzer runtests.o libruntests.a ../lib/.libs/libexpat.a && mkdir -p /exp/expat/bin/fuzz/fuzzbuilder && mv XML_Parse_fuzzer /exp/expat/bin/fuzz/fuzzbuilder && /tool/fuzzbuilder exec /exp/expat/bug.conf && /tool/afl-2.52b/afl-clang -DHAVE_CONFIG_H -I. -I.. -I./../lib -DHAVE_EXPAT_CONFIG_H -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -o runtests.o -c runtests.bc.mod.bc && AFL_USE_ASAN=1 /tool/afl-2.52b/afl-clang -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -m32 -g -fno-strict-aliasing -o XML_Parse_fuzzer runtests.o libruntests.a ../lib/.libs/libexpat.a && mkdir -p /exp/expat/bin/fuzz/fuzzbuilder && mv XML_Parse_fuzzer /exp/expat/bin/fuzz/fuzzbuilder/bug_fuzzer

# 5. Oss-Fuzz (cov)
RUN cd /exp/expat/source/libexpat/expat && rm -rf $(find . -name "*.bc") && ./build_new.sh cov && mkdir -p /exp/expat/bin/cov/oss-fuzz && mv /exp/expat/source/libexpat/expat/*_fuzzer /exp/expat/bin/cov/oss-fuzz

# 6. FuzzBuilder (cov)
RUN cd /exp/expat/source/libexpat/expat/tests && /tool/afl-2.52b/afl-clang -emit-llvm -DHAVE_CONFIG_H -I. -I.. -I./../lib -DHAVE_EXPAT_CONFIG_H -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -c runtests.c && /tool/fuzzbuilder exec /exp/expat/XML_Parse.conf && /tool/afl-2.52b/afl-clang -DHAVE_CONFIG_H -I. -I.. -I./../lib -DHAVE_EXPAT_CONFIG_H -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -o runtests.o -c runtests.bc.mod.bc && /tool/afl-2.52b/afl-clang -fprofile-arcs -ftest-coverage -m32 -g -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -fno-strict-aliasing -m32 -g -fno-strict-aliasing -o XML_Parse_fuzzer runtests.o  libruntests.a ../lib/.libs/libexpat.a && mkdir -p /exp/expat/bin/cov/fuzzbuilder && mv XML_Parse_fuzzer /exp/expat/bin/cov/fuzzbuilder

# 7. Seed Optimization
RUN cd /exp/expat && mkdir -p seed/eval/parse_ISO_8859_1_fuzzer/oss-fuzz seed/eval/parse_US_ASCII_fuzzer/oss-fuzz seed/eval/parse_UTF_16BE_fuzzer/oss-fuzz seed/eval/parse_UTF_16_fuzzer/oss-fuzz seed/eval/parse_UTF_16LE_fuzzer/oss-fuzz seed/eval/parse_UTF_8_fuzzer/oss-fuzz && cp seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer/seed.1 seed/eval/parse_ISO_8859_1_fuzzer/oss-fuzz && cp seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer/seed.1 seed/eval/parse_US_ASCII_fuzzer/oss-fuzz && cp seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer/seed.1 seed/eval/parse_UTF_16BE_fuzzer/oss-fuzz && cp seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer/seed.1 seed/eval/parse_UTF_16_fuzzer/oss-fuzz && cp seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer/seed.1 seed/eval/parse_UTF_16LE_fuzzer/oss-fuzz && cp seed/oss-fuzz/org/parse_ISO_8859_1_fuzzer/seed.1 seed/eval/parse_UTF_8_fuzzer/oss-fuzz && /tool/afl-2.52b/afl-cmin -m 1024 -i seed/fuzzbuilder/org/XML_Parse -o seed/eval/parse_ISO_8859_1_fuzzer/fuzzbuilder bin/fuzz/oss-fuzz/parse_ISO_8859_1_fuzzer @@ && /tool/afl-2.52b/afl-cmin -m 1024 -i seed/fuzzbuilder/org/XML_Parse -o seed/eval/parse_US_ASCII_fuzzer/fuzzbuilder bin/fuzz/oss-fuzz/parse_US_ASCII_fuzzer @@ && /tool/afl-2.52b/afl-cmin -m 1024 -i seed/fuzzbuilder/org/XML_Parse -o seed/eval/parse_UTF_16BE_fuzzer/fuzzbuilder bin/fuzz/oss-fuzz/parse_UTF_16BE_fuzzer @@ && /tool/afl-2.52b/afl-cmin -m 1024 -i seed/fuzzbuilder/org/XML_Parse -o seed/eval/parse_UTF_16_fuzzer/fuzzbuilder bin/fuzz/oss-fuzz/parse_UTF_16_fuzzer @@ && /tool/afl-2.52b/afl-cmin -m 1024 -i seed/fuzzbuilder/org/XML_Parse -o seed/eval/parse_UTF_16LE_fuzzer/fuzzbuilder bin/fuzz/oss-fuzz/parse_UTF_16LE_fuzzer @@ && /tool/afl-2.52b/afl-cmin -m 1024 -i seed/fuzzbuilder/org/XML_Parse -o seed/eval/parse_UTF_8_fuzzer/fuzzbuilder bin/fuzz/oss-fuzz/parse_UTF_8_fuzzer @@ && mkdir -p /exp/expat/seed/fuzzbuilder/opt && /tool/afl-2.52b/afl-cmin -m 1024 -i seed/fuzzbuilder/org/XML_Parse -t 1000 -o seed/fuzzbuilder/opt/XML_Parse bin/fuzz/fuzzbuilder/XML_Parse_fuzzer

# docker build -t fuzzbuilder:expat . -f expat.Dockerfile