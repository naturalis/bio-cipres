# covid19-phylogeny
Dockerized workflow for phylogenetic analysis of SARS-CoV-2 genomes

## Building the Dockerfile
The basic procedure is as follows, assuming you wish to build from source:

    docker build --tag naturalis/covid19-phylogeny .

## Entering into an interactive session

    docker run -it naturalis/covid19-phylogeny /bin/bash
