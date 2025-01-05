FROM node:18 AS builder

WORKDIR /app

COPY ./../react-frontend/package.json ../react-frontend/package-lock.json ./
RUN npm install

RUN ls
COPY ./../react-frontend .

RUN npm run build

FROM node:18-slim

WORKDIR /app

COPY --from=builder /app /app

RUN npm install --production --omit-dev

EXPOSE 3000

CMD ["npm", "start"]
