# covid19-phylogeny
Dockerized [workflow](https://drive.google.com/file/d/1V1vR73uflUV383IgcHxkmu27TulWSu38/view?usp=sharing) 
for phylogenetic analysis of [SARS-CoV-2 genomes](https://www.ncbi.nlm.nih.gov/nuccore/NC_045512)

## Prerequisites
The workflow requires a DEVELOPER account (not a normal user account) on 
CIPRES, and a registration for the app `corvid19_phylogeny`. Note the underscore
in the name, which is different from the repo name (sorry). With the account
and app key, you can then populate a YAML file `data/cipres_appinfo.yml` thusly, 
substituting the fields with pointy brackets with the appropriate values:

```yaml
---
URL: https://cipresrest.sdsc.edu/cipresrest/v1
KEY: <app key>
CRA_USER: <user>
PASSWORD: <pass>
```

## Orchestrating the workflow
Workflow steps will be orchestrated by wrapping scripts that are inside a
docker container (and which in turn are wrapping some executables). The
outside wrapping will be [CWL](https://www.commonwl.org/user_guide/07-containers/index.html).
Steps to wrap are:

### 1. preprocessing

I'm setting up a preprocessing pipeline that does the following:

1. **seqfilter** - filter out short sequence records (default: <25k, change with `--length=20000`)
2. **sequniqid** - filter out duplicate accession numbers (e.g. when merging from multiple taxon levels)
3. **sequniqseq** - filter out duplicate sequence data (i.e. exact same genome in multiple samples)
4. **seqchunk** - split stream into files with 25 records (default for CIPRES, change with `--chunk=30`)

Example usage:

```
gunzip -c /data/genomes/*.gz | seqfilter | sequniqid | sequniqseq | seqchunk -o /data/tmp
```

### 2. align the viral genomes

```
dncalign \
    -i /data/genomes/sars-cov-2.fasta \
    -y /data/cipres_appinfo.yml \
    -o /data/alignments/sars-cov-2.aln.fasta \
    -c 25
```

<!--
2. preprocess the reference genome using `script/refseqpp -v`, results ending up in `/data/genes/*`
3. makeblastdb on the concatenated genomes in `data/genomes/\*.fasta`, e.g. 
    `makeblastdb -in gisaid_cov2020_sequences.fasta -dbtype nucl`
-->

## Building the Dockerfile
The basic procedure is as follows, assuming you wish to build from source:

    docker build --tag naturalis/covid19-phylogeny .

## Entering into an interactive session
To check the sanity of the environment, you can log into a shell thusly:

    docker run -v `pwd`/data:/data -it naturalis/covid19-phylogeny /bin/bash
