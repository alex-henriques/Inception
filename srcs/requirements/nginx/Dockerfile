FROM	alpine:3.19

# packages: nginx -> the web server; openssl -> needed to generate self-signed TLS certificate
RUN	apk update && apk add --no-cache nginx openssl

# SSl directories: /etc/ssl/certs: standard location for certificates (public); /etc/ssl/private: standadrd location for private keys
RUN	mkdir -p /etc/ssl/certs /etc/ssl/private

# Certificate generation: the certificate is generated at build time(inside the dockerfile) instead of runtime which means the cert is baked into the image
COPY	tools/generate_cert.sh /tmp/generate_cert.sh
RUN	chmod +x /tmp/generate_cert.sh && /tmp/generate_cert.sh

# NGINX configuration: replace the nginx.config with my own (the default config on Alpine includes a lot of things that aren't needed and doesn't have my TLS or FastCGI setup)
COPY	conf/nginx.conf /etc/nginx/nginx.conf

# WP volume: NGINX needs to share the volume with WP to serve static assets
RUN	mkdir -p /var/www/html

# PORT 443!!!! cannot be changed, the subject demands it
EXPOSE	443

# running nginx in foreground: nginx -g "daemon off" tells nginx not to daemonize (fork itself into the background); needed otherwise it would exit PID 1 and container would stop
CMD ["nginx", "-g", "daemon off;"]