FROM golang:1.16.6-buster
WORKDIR /root/
COPY ./ ./blockcert
WORKDIR /root/blockcert
RUN go build blockcert.go
RUN go install
VOLUME [ "/data" ]
WORKDIR /data
EXPOSE 8080
CMD ["/go/bin/blockcert"]

