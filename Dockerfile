# Docker file with a multi-stage build process
# See this link for more info about docker multi-stage builds:
# https://docs.docker.com/develop/develop-images/multistage-build/

# ********************************************
# STAGE 1
# First, install the node dependencies and
# compile the typescript code
# ********************************************

# Start with a lightweight Linux distro (Alpine Linux)
# We call this stage ts-compiler so we can reference it
# in our other stages, if needed
FROM node:lts-alpine AS ts-compiler

# Create app directory
# This is changing our working directory
# so all future commands will be performed here.
# We've bound this directory as a volume to our
# repository's root, so our docker has access to
# all of our repo's files. Note that volume binding
# is read-only, so we cannot write out files.
WORKDIR /home/node/app

# Change ownership to non-root user
# so a non-root user can do things!
RUN chown node:node /home/node/app

# Set user to non-root "node"
# This ensures that any files created
# will be accessible to non-root users and programs
USER node

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY --chown=node:node package.json ./

# Install our node dependencies!
RUN npm install

# Bundle app source
COPY --chown=node:node . ./

# Build application using the script defined in package.json
# This will place our built website files into the built/ directory
# In this case, our typescript files are transpiled into js files
RUN npm run build

# This results in an image with our website

# ********************************************
# STAGE 2
# Generate self-signed certificates
# ********************************************

# Create a separate container for generating certificates
# We don't need node in this container, regular alpine will do
# Also note that we could've combined stages 1 and 2, but it's
# a nice example of a multistage build to leave them separated
# We'll call this container "generate-certs"
FROM alpine AS generate-certs

# We're using lts-apine's apk installer
# to install openssl in this container
# The no-cache option helps keep containers small
# We also remove any existing caches from installs
RUN apk update && \
  apk add --no-cache openssl && \
  rm -rf "/var/cache/apk/*"

# Create a folder to hold our generated certificates
RUN mkdir openssl-certs

# Run an openssl command to generate certs and copy them into openssl-certs
# x509 means we want a self-signed certificate
# -days is how long the cert if valid for
# -nodes means we skip the option to secure our certificate
# with a passphrase, so that nginx can read it
# CA is the company name generating the cert
# CN is the common name (or domain)
# AltName is other domains the cert can be used for

# We will be using our certs to access our site via https!
RUN openssl req -x509 -nodes -days 365 -subj "/C=US/ST=CA/O=Valtech, Inc./CN=${DOMAIN_NAME}.com" \
-addext "subjectAltName=DNS:*.${DOMAIN_NAME}.com" -newkey rsa:2048 -keyout /openssl-certs/nginx-selfsigned.key \
-out /openssl-certs/nginx-selfsigned.crt;

# We now have another container that has our certicates
# Why didn't we just generate these in our nginx docker?
# The Nginx docker doesn't have apk to make it even more dedicated and lightweight!

# ********************************************
# STAGE 3
# Deploying our simple website in an Nginx Docker
# This will not include all the cruft we need to build our code
# Just the bare minimum - built files and nginx!
# ********************************************

# Start from the vanilla nginx Docker container
FROM nginx

# Copy over our certs from our "generate-certs" container
COPY --from=generate-certs /openssl-certs/*.crt /etc/ssl/certs/
COPY --from=generate-certs /openssl-certs/*.key /etc/ssl/private/

# Copy nginx config from ts-compiler container, which is bound to our repo
# The configuration specifies that we serve our pages with https
COPY --from=ts-compiler /home/node/app/nginx/nginx.conf /etc/nginx/conf.d

# Copy the built files from ts-compiler to the place where nginx
# expects to find the files to serve up!
COPY --from=ts-compiler /home/node/app/built /usr/share/nginx/html

# Expose our HTTPS port (443)
# EXPOSE 80 # for regular http
EXPOSE 443