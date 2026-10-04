FROM node:22-slim AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package.json package-lock.json .npmrc ./
COPY quartz/ ./quartz/
COPY quartz.lock.json* quartz.config.yaml* quartz.ts* ./

RUN npm ci \
    && npx quartz plugin install

FROM node:22-slim
WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/ /usr/src/app/
COPY . .

EXPOSE 8080 3001
CMD ["npx", "quartz", "build", "--directory", "/vault", "--serve", "--port", "8080", "--wsPort", "3001"]
