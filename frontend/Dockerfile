FROM gitlab.praktikum-services.ru:5050/std-009-060/sausage-store/node:8.17-alpine AS base
RUN mkdir -p /home/node/app
RUN chown -R node:node /home/node && chmod -R 770 /home/node
WORKDIR /home/node/app

FROM base AS builder-server
WORKDIR /home/node/app
USER node
COPY --chown=node:node *.json ./
RUN npm install --no-audit --no-progress --only=prod http-server

FROM base AS builder-client
WORKDIR /home/node/app
USER node
COPY --chown=node:node *.json ./
RUN npm install --no-audit --no-progress
COPY --chown=node:node src/ ./src/
RUN npm run build

FROM gitlab.praktikum-services.ru:5050/std-009-060/sausage-store/node:16.17.1-bullseye-slim
WORKDIR /home/node/app
USER node
COPY --chown=node:node --from=builder-client /home/node/app/dist ./dist/
COPY --chown=node:node --from=builder-server /home/node/app/node_modules ./node_modules

EXPOSE 80
ENTRYPOINT ["node", "node_modules/.bin/http-server" , "dist/frontend/", "-p", "80","--proxy", "http://sausage-backend:8080"]