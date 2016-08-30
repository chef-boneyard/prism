FROM devchef/node-5.6:latest
MAINTAINER Chef Software, Inc <docker@chef.io>

COPY package.json typings.json tsconfig.json /usr/src/app/
RUN npm install

COPY ./src /usr/src/app/src
COPY gulpfile.js /usr/src/app/

CMD [ "npm", "start" ]

EXPOSE 8585
