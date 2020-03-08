ARG NODE_VERSION=12
ARG ALPINE_VERSION=3.11

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS base
WORKDIR /workdir
COPY package.json yarn.lock ./
RUN yarn install --no-progress
COPY . .

FROM base AS tester
RUN yarn lint
RUN yarn test --ci --coverage

FROM base AS builder
RUN yarn build

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}
WORKDIR /workdir
ENTRYPOINT [ "node /workdir/server.js" ]
EXPOSE 8080/tcp
COPY --from=builder --chown=1000 /workdir/dist/ ./
USER 1000
