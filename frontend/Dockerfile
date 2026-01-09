FROM node:20-alpine AS build
WORKDIR /app
COPY triage-ui/package*.json ./triage-ui/
WORKDIR /app/triage-ui
RUN npm install
COPY triage-ui/ .
RUN npm run build -- --configuration=production

FROM nginx:1.25-alpine
COPY --from=build /app/triage-ui/dist/triage-ui /usr/share/nginx/html
EXPOSE 80

