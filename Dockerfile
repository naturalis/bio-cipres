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
    ncbi-blast+ \
    paml \
    raxml \
    muscle \
    libipc-run-perl \
    libxml-parser-perl \
    libxml-dom-xpath-perl \
    perl-doc \
    clustalw \
    t-coffee \
    mafft \
    prank \
    curl

# the input/output working directory for data files
RUN mkdir /data

# symlink to please Bio::Tools::Phylo::PAML
RUN ln -s /usr/bin/paml-evolver /usr/bin/evolver

# fetch translatorx
RUN curl -o /usr/local/src/script/translatorx http://pc16141.mncn.csic.es/cgi-bin/translatorx_vLocal.pl
RUN chmod 755 /usr/local/src/script/translatorx

# install packages
RUN cpanm --notest \
	BioPerl \
	https://cpan.metacpan.org/authors/id/C/CJ/CJFIELDS/BioPerl-Run-1.007003.tar.gz \
	Bio::Phylo \
	Bio::DB::NCBIHelper \
	Bio::Tools::Phylo::PAML
