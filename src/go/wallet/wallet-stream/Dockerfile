FROM golang:1.16-alpine

WORKDIR /go/src/app
COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

CMD ["wallet-stream-app"]

#RUN go build -t wallet-stream-app .