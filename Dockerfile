FROM nginx

RUN mkdir /www \
    && mkdir /www/wwwroot/ \
    && mkdir /www/wwwlogs

COPY ./dist/ /www/wwwroot/treehollow.bifrost.kim/

COPY nginx.conf /etc/nginx/conf.d/default.conf



