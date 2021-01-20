FROM node:12.8-alpine

RUN npm i -g pnpm

WORKDIR /usr/src/app

COPY rollup.config.js ./
COPY package.json ./
COPY pnpm-lock.yaml ./

RUN pnpm install

COPY ./src ./src
COPY ./public ./public

RUN pnpm run build

EXPOSE 5000

ENV HOST=0.0.0.0

CMD [ "npm", "start" ]
