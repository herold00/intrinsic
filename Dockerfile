FROM node:12-alpine
RUN apk -U upgrade --available
RUN apk add --no-cache circusd openrc python3-dev musl-dev g++ linux-headers libev-dev caddy
COPY . .
RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade setuptools
RUN pip3 install pdm
RUN mkdir node00
WORKDIR node00
RUN pdm init -n
RUN pdm add wagtail bjoern bjcli
RUN pdm run wagtail start myproject
WORKDIR myproject
RUN pdm run python3 manage.py migrate
RUN pdm run python3 manage.py createsuperuser --username heroldzer0 --email 00@node00.net
ENV DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD
RUN echo "secret is: $DJANGO_SUPERUSER_PASSWORD"
WORKDIR /root
RUN caddy start
RUN python3 circusd circus.ini
EXPOSE 80
