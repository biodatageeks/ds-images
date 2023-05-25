ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG spark_uid=185
ARG MLFLOW_VERSION
ARG GLOW_PY_VERSION
ARG JUPYTER_KERNEL_NAME

ARG BWA_VERSION=0.7.17
ARG VEP_VERSION=101
ENV VEP_VERSION=$VEP_VERSION


USER root
RUN if [ $JUPYTER_KERNEL_NAME == "datascience" ]; then \
        pip3 install mlflow==${MLFLOW_VERSION}; \
    fi

RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
        apt-get update && \
        apt-get -qq -y install \
            gcc \
            g++ \
            python3-dev \
            bzip2 \
            zlib1g-dev \
            curl \
            make \
            perl \
            git  \
            curl \
            cpanminus \
            libmodule-build-perl \
            libdbi-perl \
            libdbd-mysql-perl \
            libbz2-dev \
            liblzma-dev \
            build-essential \
            libcurl3-dev \
            unzip \
            libssl-dev \
            samtools \
            openssl && \
        cd /tmp && \
        git clone https://github.com/atks/vt.git  && \
        cd vt && \
        git checkout 0.57721 && \
        make && \
        mv vt /usr/bin && \
        cd /tmp/ && git clone https://github.com/Ensembl/ensembl-vep.git && \
        cd ensembl-vep/ && \
        cpanm inc::latest && \
        cpanm Module::Build && \
        git checkout release/$VEP_VERSION && \
        perl INSTALL.pl -n -a a && \
        mkdir -p /opt && mv /tmp/ensembl-vep /opt/ && \
        pip3 install glow.py==$GLOW_PY_VERSION; \
    fi

ENV PATH=$PATH:/opt/ensembl-vep

#ADD http://downloads.sourceforge.net/project/bio-bwa/bwa-${BWA_VERSION}.tar.bz2 /tmp/
#
#RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
#        apk add --update --no-cache ncurses \
#                && apk add --virtual=deps --update --no-cache  musl-dev zlib-dev make  gcc \
#                && cd /tmp/ && tar xjvf bwa-${BWA_VERSION}.tar.bz2 \
#                && cd /tmp/bwa-${BWA_VERSION} \
#                && sed -i '1i#include <stdint.h>' kthread.c \
#                && sed -i[.bak] "s/u_int32_t/uint32_t/g" *.c  \
#                && sed -i[.bak] "s/u_int32_t/uint32_t/g" *.h  \
#                && make \
#                && mv /tmp/bwa-${BWA_VERSION}/bwa /usr/bin \
#                && rm -rf /var/cache/apk/* /tmp/* \
#                && apk del deps ; \
#    fi
#ENV BOWTIE2_VERSION 2.2.8
#
#RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
#    apk add --no-cache \
#        perl \
#        wget \
#        openssl \
#        ca-certificates \
#        libc6-compat \
#        libstdc++ \
#        && cd /tmp && wget https://github.com/BenLangmead/bowtie2/archive/v${BOWTIE2_VERSION}.tar.gz  && tar zxvf  v${BOWTIE2_VERSION}.tar.gz && \
#        cd bowtie2-${BOWTIE2_VERSION}/ && make && make install ; \
#    fi
#
#ARG SAMTOOLS_VERSION=1.11
#
#RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
#     apk add --update pcre-dev openssl-dev \
#     && apk add --virtual build-dependencies build-base curl \
#     && curl -L -o samtools-${SAMTOOLS_VERSION}.tar.bz2 \
#        http://jaist.dl.sourceforge.net/project/samtools/samtools/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
#     && tar jxvf samtools-${SAMTOOLS_VERSION}.tar.bz2  \
#     && cd samtools-${SAMTOOLS_VERSION}/ \
#     && ./configure --without-curses \
#     && make \
#     && make install; \
#    fi
RUN mkdir -p /mnt/data && chown -R $spark_uid /mnt/data
RUN chown -R $spark_uid /opt/spark/work-dir
USER ${spark_uid}