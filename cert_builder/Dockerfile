FROM ubuntu

WORKDIR /builder

RUN apt-get -y update && apt-get install openssl

COPY build_certificates.sh /builder/build_certificates.sh
RUN pwd && ls -lart && sh build_certificates.sh

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT [ "/bin/sh", "entrypoint.sh"]