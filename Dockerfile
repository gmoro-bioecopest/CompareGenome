FROM continuumio/miniconda3

RUN mkdir /app
WORKDIR /app
COPY . /app/

RUN bash install.sh -p 8

