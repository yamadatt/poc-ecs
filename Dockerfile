# GitHubActionsからECRへのPUSH検証

# マルチステージビルドで実装
# 322MBが14MBにイメージ削減

FROM golang:1.20.6-alpine3.18 as go_build
WORKDIR /app
COPY src/go.mod src/main.go ./
RUN go mod download \
    && go build -o main /app/main.go


FROM alpine:3.18
WORKDIR /app
COPY --from=go_build /app/main .
USER 1001
CMD [ "/app/main" ]
EXPOSE 8091
