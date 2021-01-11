ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG spark_uid=1000
ARG MLFLOW_VERSION
ARG GLOW_PY_VERSION
ARG JUPYTER_KERNEL_NAME

ARG BWA_VERSION=0.7.17


USER root
RUN if [ $JUPYTER_KERNEL_NAME == "datascience" ]; then \
        pip3 install mlflow==${MLFLOW_VERSION} \
                     PyArrow==0.15.1 ; \
    fi

RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
        pip3.6 install glow.py==$GLOW_PY_VERSION; \
    fi

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

USER ${spark_uid}