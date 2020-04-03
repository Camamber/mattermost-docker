#!/bin/sh

# Define default value for app container hostname and port
APP_HOST=${APP_HOST:-app}
APP_PORT_NUMBER=${APP_PORT_NUMBER:-8000}

# Check if SSL should be enabled (if certificates exists)
if [ ! -f " /cert/default.crt" ]; then
    openssl genrsa -out "/cert/default.key" 2048
    openssl req -new -key "/cert/default.key" -out "/cert/default.csr" -subj "/CN=default/O=default/C=UK"
    openssl x509 -req -days 365 -in "/cert/default.csr" -signkey "/cert/default.key" -out "/cert/default.crt"
fi

# Ensure that the configuration file is not present before linking. 
test -w /etc/nginx/conf.d/mattermost.conf && rm /etc/nginx/conf.d/mattermost.conf
# Linking Nginx configuration file
ln -s -f /etc/nginx/sites-available/mattermost-ssl /etc/nginx/conf.d/mattermost.conf

# Setup app host and port on configuration file
sed -i "s/{%APP_HOST%}/${APP_HOST}/g" /etc/nginx/conf.d/mattermost.conf
sed -i "s/{%APP_PORT%}/${APP_PORT_NUMBER}/g" /etc/nginx/conf.d/mattermost.conf

# Run Nginx
exec nginx -g 'daemon off;'
