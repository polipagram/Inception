#!/bin/bash

set -e

if [ ! -f /etc/ssl/certs/nginx-selfsigned.crt ]; then
    echo "Generating a certificate..."
    

    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx-selfsigned.key \
        -out /etc/ssl/certs/nginx-selfsigned.crt \
        -subj "/C=MO/ST=Rabat/L=Sale/O=42/OU=42/CN=kbouarfa.42.fr"
            
else
    echo "Certificate already exists"
fi

exec "$@"