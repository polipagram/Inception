FROM debian:12

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/private.key \
    -out /etc/nginx/ssl/certificate.crt \
    -subj "/CN=localhost"

COPY conf/nginx.cnf /etc/nginx/nginx.conf
COPY tools/index.html /var/www/html/index.html
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]