FROM ubuntu:18.04

# feel free to change / update
MAINTAINER Rutger Vos <rutger.vos@naturalis.nl>

# XXX at this point this is voodoo that got it to run 
# apt-get without warnings. this should probably
# be improved.
ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

# the script folder in the repo is for standalone executable scripts,
# which end up on the $PATH inside the container
ENV PATH /usr/local/src/script:$PATH
ADD ./script /usr/local/src/script

# install build tool essentials and NCBI BLAST+
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    libomp-dev \
    build-essential \
    autoconf \
    autotools-dev \
    automake \
    libtool \
    cpanminus \
    ncbi-blast+

# the input/output working directory for data files
RUN mkdir /data

# ENTRYPOINT ["/usr/local/src/treePL/src/treePL"]
