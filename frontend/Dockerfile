FROM gitlab.praktikum-services.ru:5050/std-009-060/sausage-store/node:8.17-alpine AS base
RUN mkdir -p /home/node/app
RUN chown -R node:node /home/node && chmod -R 770 /home/node
WORKDIR /home/node/app

FROM base AS builder-client
WORKDIR /home/node/app
USER node
COPY --chown=node:node *.json ./
RUN npm ci && npm cache clean
COPY --chown=node:node src/ ./src/
RUN npm run build

FROM gitlab.praktikum-services.ru:5050/std-009-060/sausage-store/node:16.17.1-bullseye-slim
RUN mkdir -p /home/node/app
RUN chown -R node:node /home/node && chmod -R 770 /home/node
WORKDIR /home/node/app
USER node
RUN npm install --no-audit http-server

COPY --chown=node:node --from=builder-client /home/node/app/dist ./dist/

EXPOSE 80
ENTRYPOINT ["node", "node_modules/.bin/http-server" , "dist/frontend/", "-p", "81","--proxy", "http://sausage-backend:8080"]