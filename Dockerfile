
# base image
FROM node:lts-alpine3.18 

# copy project to the dir
COPY . .

# install and build the image
RUN npm install && npm run build

EXPOSE 3000

CMD [ "npm" ,"run","start" ]
