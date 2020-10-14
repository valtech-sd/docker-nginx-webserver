# Docker Nginx Webserver example

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview 
This is a simple example of how to build, generate certificates for, and serve a website using [Docker](https://docs.docker.com/)! In particular, you'll see how to use multi-stage builds and an Nginx container to build and serve up a website, without having a bloated container as your final result.

## What can I learn?
* How to use [multi stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) in Docker files. This lets you perform intermediate tasks in multiple Docker containers, for example building a website, without bloating your final Docker container. You can perform some tasks in one container, and then pass whatever you need to subsequently-created containers. Neato!
* How to pass environment variables from a `.env` file to your Docker container, using a Docker-Compose setting
* How to bind volumes and use files on your local machine in your Docker container
* How to generate self-signed ssl keys
* How to deploy a website using the Nginx Docker image

## What are the important files?
* `src` contains the source code for our website. In this case, it's a dirt simple HTML page that includes a Typescript file. That's literally it. You can replace this source with whatever fancy React page you want.
* `Package.json` contains our Node pre-requisites for our webpage, and our script for building our website. Since we're using typescript, our `npm run build` command uses `tsc` to transpile our files to Javascript and puts the resulting built files in a `./built` directory.
* `Dockerfile` contains the steps for our multi stage Docker build! Here, you will see different containers being used to install node packages / build our source, genreate certs, and ultimately deploy our site.
* `docker-compose.yml` passes environment variables to our Docker file, binds the root of our repository to a [Docker volume](https://docs.docker.com/storage/volumes/), and exposes a port from our final nginx image.
* `.env` contains our environment variables that will be passed to our Docker container. In this case, it's just a single `DOMAIN_NAME` value for generating certificates for a certain domain.
* `nginx/nginx.conf` is an nginx config that says we want to serve a webpage using ssl. It will be copied to our nginx Docker container.
* `tsconfig.json`, `.prettierrc`, and other files are convenience files for using Typescript and linting

## Pre-Requisite installation

1. [Install NPM](https://www.npmjs.com/get-npm), if you have not already done so.
2. [Install Docker](https://www.docker.com/products/docker-desktop), if you have not already done so.
2. Clone or download this repository.

## Building Docker containers 

Much of this repo was made using [Coding with Manny's very useful blogpost](https://medium.com/@codingwithmanny/configure-self-signed-ssl-for-nginx-docker-from-a-scratch-7c2bcd5478c6), which outlines exactly how to generate ssl certificates and use Nginx with Docker to serve up a webpage. We've tweaked the process slightly, but it's very helpful!

1. If desired, change the domain name you're serving up your webpage in the `.env` environment variables file. We're just using `mydomain.com` for testing. This domain is used to generate our self-signed certificates.
2. Run the multistage build with `docker-compose build`
2. Start the Docker container by running `docker-compose up`

This will perform the multi-stage build process, and the result will be an Nginx Docker container serving your website files. In this example, we are serving and exposing the files on both port `80` (mapped to port `8005`) and port `443` (mapped to `443`), just for debugging purposes. To take a look at what we're serving up, you can type in your terminal:

`curl https://localhost:443 --insecure`
or
`curl http://localhost:8005`
to see the raw HTML of the webpage.

Now we technically have a website that's being served up at `https://localhost.com:443`, but there's a few more steps to make things even better. If you try to access this URL from your browser, you will get a warning because the website is using self-signed certificates and is considered insecure. That's why we had to add the `--insecure` option when calling our curl command from the terminal. 

## Trusting our website and domain mapping
For more detailed instructions with pretty pictures, you can follow Manny's blogpost linked above.

1. In your terminal, open up your `/etc/hosts` file from your favorite text editor:
`sudo nano /etc/hosts;`
2. Add a line mapping from the localhost IP to your domain:
`127.0.0.1       mydomain.com`
3. Copy the self-signed certificate you generated during the multi-stage Docker build:
`docker cp nginx-alpine-ssl:/etc/ssl/certs/nginx-selfsigned.crt ~/Desktop`
4. Open up `Keychain Access > Certificates` (in the left panel). Drag the copied certificate file to the list of certificates.
5. Double click your self-signed certificate in Keychain and change `Secure Sockets Layer (SSL)` to `Always trust`.
6. Now you should be able to see your website at `https://mydomain.com`! And it's being served in a tidy, lightweight Nginx Docker.

## For the future:

-  Notes about Nginx setup in general and debugging
-  More detailed breakdown of the multistage Docker file