FROM golang:alpine as builder

LABEL maintainer="Yohei Uema <winuim@gmail.com>"

RUN apk add --no-cache gcc git make musl-dev \
    && go get -d -v github.com/mackerelio/mackerel-agent \
    && cd $GOPATH/src/github.com/mackerelio/mackerel-agent \
    && make build \
    && cp ./build/mackerel-agent $GOPATH/bin/ \
    && mkdir -p /etc/mackerel-agent/ \
    && cp ./mackerel-agent.sample.conf /etc/mackerel-agent/mackerel-agent.conf \
    && cd $GOPATH && go get -d -v github.com/mackerelio/mackerel-agent-plugins \
    && cd $GOPATH/src/github.com/mackerelio/mackerel-agent-plugins \
    && make build/mackerel-plugin \
    && cp ./build/mackerel-plugin $GOPATH/bin/mackerel-agent-plugins \
    && cd $GOPATH && go get -d -v github.com/mackerelio/go-check-plugins \
    && cd $GOPATH/src/github.com/mackerelio/go-check-plugins \
    && make build/mackerel-check \
    && cp ./build/mackerel-check $GOPATH/bin/go-check-plugins \
    && cd $GOPATH && go get github.com/pierrec/lz4 && cd $GOPATH/src/github.com/pierrec/lz4 && git fetch && git checkout v3.0.1 \
    && cd $GOPATH && go get -d -v github.com/mackerelio/mkr \
    && cd $GOPATH/src/github.com/mackerelio/mkr \
    && make build \
    && cp ./mkr $GOPATH/bin/

FROM golang:alpine as runner
COPY --from=builder /go/bin /go/bin
COPY --from=builder /etc/mackerel-agent /etc/mackerel-agent

WORKDIR /app
COPY . /app
RUN apk add --no-cache bash coreutils iproute2 tzdata \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo "Asia/Tokyo" > /etc/timezone \
    && chmod +x ./entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "run" ]
