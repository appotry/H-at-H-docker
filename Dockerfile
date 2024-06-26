FROM alpine AS builder

ENV HatH_VERSION 1.6.2
ENV HatH_SHA256 b8889b2c35593004be061064fcb6d690ff8cbda9564d89f706f7e3ceaf828726

RUN apk --no-cache add unzip \
    && wget https://github.com/Disappear9/H-at-H-docker/archive/master.zip \
    && unzip master.zip \
    && mkdir -p /builder \
    && cp -R H-at-H-docker-master/build/* /builder \
    && mkdir -p /hath \
    && cd /hath \
    && wget https://repo.e-hentai.org/hath/HentaiAtHome_$HatH_VERSION.zip -O hath.zip \
    && echo -n ""$HatH_SHA256"  hath.zip" | sha256sum -c \
    && unzip hath.zip \
    && rm hath.zip \
    && mkdir -p /hath/data \
    && mkdir -p /hath/download

FROM openjdk:8-jre-alpine AS release

ENV HatH_ARGS --cache-dir=/hath/data/cache --data-dir=/hath/data/data --download-dir=/hath/download --log-dir=/hath/data/log --temp-dir=/hath/data/temp

ENV TZ Asia/Shanghai

RUN apk --no-cache add tzdata && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && apk del tzdata

COPY --from=builder /hath /hath
COPY --from=builder /builder/start.sh /hath/start.sh
WORKDIR /hath

RUN apk --no-cache add sqlite \
    && chmod +x /hath/start.sh

CMD ["/hath/start.sh"]


