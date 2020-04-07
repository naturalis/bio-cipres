# covid19-phylogeny
Dockerized [workflow](https://drive.google.com/file/d/1V1vR73uflUV383IgcHxkmu27TulWSu38/view?usp=sharing) 
for phylogenetic analysis of SARS-CoV-2 genomes

## Orchestrating the workflow
Workflow steps will be orchestrated by wrapping scripts that are inside a
docker container (and which in turn are wrapping some executables). The
outside wrapping will be [CWL](https://www.commonwl.org/user_guide/07-containers/index.html).
Steps to wrap are:

1. preprocess the reference genome using script/refseqpp, ending up in data/genes/*
2. makeblastdb on the concatenated genomes in data/genomes/\*.fasta

## Building the Dockerfile
The basic procedure is as follows, assuming you wish to build from source:

    docker build --tag naturalis/covid19-phylogeny .

## Entering into an interactive session
To check the sanity of the environment, you can log into a shell thusly:

    docker run -it naturalis/covid19-phylogeny /bin/bash
