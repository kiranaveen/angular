# syntax=docker/dockerfile:1.4

FROM --platform=$BUILDPLATFORM node:17.0.1-bullseye-slim as builder

RUN mkdir /project
WORKDIR /project

RUN npm install -g @angular/cli@13

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
ARG PORT=8085
ENV PORT_ENV=$PORT
CMD ["sh", "-c", "ng serve --host 0.0.0.0 --port $PORT_ENV"]

FROM builder as dev-envs

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends git
EOF

RUN <<EOF
useradd -s /bin/bash -m vscode
groupadd docker
usermod -aG docker vscode
EOF
# install Docker tools (cli, buildx, compose)
COPY --from=gloursdocker/docker / /

ARG PORT1=8085
ENV PORT_ENV1=$PORT1

CMD ["ng", "serve", "--host", "0.0.0.0", "--port", PORT_ENV1]
