ARG GOLANG_VERSION=1.22
FROM golang:${GOLANG_VERSION} as builder

ARG VERSION
ARG GIT_COMMITSHA
WORKDIR /build
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY internal/ internal/
COPY nighthawk/ nighthawk/
# Build
COPY build/ build/
RUN GOPROXY=https://proxy.golang.org,direct CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -ldflags="-w -s -X main.version=$VERSION -X main.gitsha=$GIT_COMMITSHA" -a -o meshplay-nighthawk main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
ENV DISTRO="debian"
ENV GOARCH="amd64"
ENV SERVICE_ADDR="meshplay-nighthawk"
ENV MESHPLAY_SERVER="http://meshplay:9081"
# COPY templates/ ./templates
WORKDIR /
COPY --from=builder /build/meshplay-nighthawk .
USER nonroot:nonroot

ENTRYPOINT ["/meshplay-nighthawk"]
