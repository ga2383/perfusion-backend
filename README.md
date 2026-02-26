Perfusion Backend

This folder contains a minimal backend for the Liver Perfusion dashboard.

Quick start

1) Copy `.env.example` to `.env` and set `DATABASE_URL` to your Aiven Postgres connection string (include `?sslmode=require`).

2) Install dependencies:

   npm install

3) Generate Prisma client and run migrations against the DB:

   npx prisma generate --schema=./prisma/schema.prisma
   npx prisma migrate deploy --schema=./prisma/schema.prisma

4) Start

   npm start

WebSocket server

- Run `npm run ws` to start the WebSocket broadcaster (defaults to port 8080). The docker image also provides this via `docker-compose`.

Docker

Build and run the image:

  docker build -t perfusion-backend .
  docker run -e DATABASE_URL="$DATABASE_URL" -p 3001:3001 -p 8080:8080 perfusion-backend

Docker Compose

If you add a `frontend` folder (React app) and build it into `frontend/build`, the backend will automatically serve it. Use the included `docker-compose.yml` to run Postgres + backend + ws together:

   docker-compose up -d --build

