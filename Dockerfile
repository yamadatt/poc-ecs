# マルチステージビルドで実装
# 322MBが14MBにイメージ削減

FROM golang:1.23.4-alpine3.21 AS go_build
WORKDIR /app
COPY src/go.mod src/main.go ./
RUN go mod download \
    && go build -o main /app/main.go


FROM alpine:3.21
WORKDIR /app
COPY --from=go_build /app/main .
USER 1001
CMD [ "/app/main" ]
EXPOSE 8091


