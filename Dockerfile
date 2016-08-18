FROM busybox:latest

WORKDIR /src

RUN wget --no-check-certificate https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux -O hab.tar.gz
RUN tar -xf ./hab.tar.gz && cp ./hab-*/hab /usr/local/bin

COPY ./build-prism-hab.sh ./

CMD ./build-prism-hab.sh
