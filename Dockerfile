FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# EXPOSE 3000
# Correccion 
EXPOSE 8080
CMD ["node", "server.js"]