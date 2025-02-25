FROM ubuntu:22.04 as builder

RUN apt update && \
    apt install -y \
      build-essential \
      debhelper \
      fakeroot \
      git \
      libbladerf-dev \
      libhackrf-dev \
      liblimesuite-dev \
      libncurses-dev \
      librtlsdr-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flightaware/dump1090.git /dump1090
WORKDIR /dump1090
#RUN git checkout 849a3b73299b4f56620ab16a6b62d88e17f35608
RUN make

From ubuntu:22.04

RUN apt update && \
    apt install -y \
      libbladerf2 \
      libhackrf0 \
      #liblimesuite-dev \
      liblimesuite20.10-1 \
      libncurses6 \
      librtlsdr0 \
      nginx && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /dump1090/dump1090 /usr/bin/dump1090
COPY --from=builder /dump1090/public_html/ /dump1090/public_html/
# fixes https://github.com/jeanralphaviles/dump1090-docker/issues/2
RUN echo '{"type": "dump1090-docker"}' > /dump1090/public_html/status.json && \
    echo '{"rings": []}' > /dump1090/public_html/upintheair.json

COPY nginx.conf /nginx.conf
COPY mime.types /mime.types

COPY run.sh /run.sh

EXPOSE 8080 30001 30002 30003 30004 30005 30104

ENTRYPOINT ["/run.sh"]
