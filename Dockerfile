FROM node:18-alpine

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm install --production

COPY . .

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3001 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["node","src/server.js"]
