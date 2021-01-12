ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG spark_uid=185
ARG MLFLOW_VERSION
ARG GLOW_PY_VERSION
ARG JUPYTER_KERNEL_NAME

ARG BWA_VERSION=0.7.17
ARG VEP_VERSION
ENV VEP_VERSION=$VEP_VERSION


USER root
RUN if [ $JUPYTER_KERNEL_NAME == "datascience" ]; then \
        pip3 install mlflow==${MLFLOW_VERSION} \
                     PyArrow==0.15.1 ; \
    fi

RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
        apk add gcc \
                g++ \
                python3-dev \
                zlib-dev \
                bzip2-dev \
                xz-dev \
                curl-dev \
                make \
                perl \
                perl-dev \
                perl-dbi \
                perl-dbd-mysql \
                perl-archive-zip \
                apkbuild-cpan \
                perl-app-cpanminus \
                git  \
                curl && \
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
         perl INSTALL.pl -a a && \
         mkdir -p /opt && mv /tmp/ensembl-vep /opt/ && \
         pip3.6 install glow.py==$GLOW_PY_VERSION; \
    fi

ENV PATH=$PATH:/opt/ensembl-vep

ADD http://downloads.sourceforge.net/project/bio-bwa/bwa-${BWA_VERSION}.tar.bz2 /tmp/

RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
        apk add --update --no-cache ncurses \
                && apk add --virtual=deps --update --no-cache  musl-dev zlib-dev make  gcc \
                && cd /tmp/ && tar xjvf bwa-${BWA_VERSION}.tar.bz2 \
                && cd /tmp/bwa-${BWA_VERSION} \
                && sed -i '1i#include <stdint.h>' kthread.c \
                && sed -i[.bak] "s/u_int32_t/uint32_t/g" *.c  \
                && sed -i[.bak] "s/u_int32_t/uint32_t/g" *.h  \
                && make \
                && mv /tmp/bwa-${BWA_VERSION}/bwa /usr/bin \
                && rm -rf /var/cache/apk/* /tmp/* \
                && apk del deps ; \
    fi
RUN mkdir -p /mnt/data && chown -R $spark_uid /mnt/data
RUN chown -R $spark_uid /opt/spark/work-dir
USER ${spark_uid}