FROM node:18-alpine
WORKDIR /app
## to help support the caching of the dependencies, so as to "only recreate the yarn dependencies if there was a change to the package.json"
COPY package.json yarn.lock ./
RUN yarn install --production
COPY . .
CMD ["node", "src/index.js"]
