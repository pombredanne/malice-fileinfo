FROM gliderlabs/alpine:3.3

MAINTAINER blacktop, https://github.com/blacktop

ENV SSDEEP ssdeep-2.13

COPY trid/trid /usr/bin/trid
COPY . /go/src/github.com/maliceio/malice-fileinfo
RUN apk-install exiftool file libstdc++
RUN apk-install -t build-deps build-base curl go git mercurial \
  && set -x \
  && echo "Downloading TRiD Database..." \
  && curl -Ls http://mark0.net/download/triddefs.zip > /tmp/triddefs.zip \
  && cd /tmp \
  && unzip triddefs.zip \
  && mv triddefs.trd /usr/bin/ \
  && echo "Installing ssdeep..." \
  && curl -Ls https://downloads.sourceforge.net/project/ssdeep/$SSDEEP/$SSDEEP.tar.gz > /tmp/$SSDEEP.tar.gz \
  && cd /tmp \
  && tar zxvf $SSDEEP.tar.gz \
  && cd $SSDEEP \
  && ./configure --enable-shared=no \
  && make \
  && make install \
  && rm -rf /tmp/* /root/.cache \
  && echo "Building info Go binary..." \
	&& cd /go/src/github.com/maliceio/malice-fileinfo \
	&& export GOPATH=/go \
	&& go get \
	&& go build -ldflags "-X main.Version=0.1.0" -o /bin/info \
	&& rm -rf /go \
	&& apk del --purge build-deps

ENTRYPOINT ["/bin/info"]
