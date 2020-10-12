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

1. Run the multistage build with `docker-compose build`
2. Start the Docker container by running `docker-compose up`

Now we technically have a website that's being served up at `https://localhost.com:4343`, but there's a few more steps to make things even better. [TODO]



