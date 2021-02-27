FROM node:lts-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM nginx
LABEL maintainer="Webbaum <info@webbaum.de>"
COPY --from=builder /app/dist /usr/share/nginx/html