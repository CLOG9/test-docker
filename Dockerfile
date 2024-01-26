### spices ^^


#build stage
# base image
FROM node:lts-alpine3.18 AS builder
RUN apk update && apk add curl 

# create a dir
WORKDIR /usr/src/app

COPY package.json package-lock.json* tsconfig.json /usr/src/app/

## install dependencies with "ci" instead of "install"
RUN npm ci && curl -sf https://gobinaries.com/tj/node-prune | sh 
# copy project to the dir
COPY . /usr/src/app/

# build the image
RUN npm run build

#remove the extra files with node-prune
RUN node-prune

#run stage
# base image
FROM node:lts-alpine3.18 AS runner


# create a dir
WORKDIR /usr/src/app

## add the dumb init to avoid node and PID 1 problems
RUN apk update && apk add --no-cache dumb-init

## root user privleges? nuuuh
RUN chown node:node ./
USER node

COPY --chown=node:node --from=builder /usr/src/app/dist ./dist
COPY --chown=node:node --from=builder /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=builder /usr/src/app/package.json .
COPY --chown=node:node --from=builder /usr/src/app/package-lock.json .

EXPOSE 3000

CMD [ "dumb-init","npm" ,"run", "start" ]
