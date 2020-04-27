---
title: 'Phylogenetic pipeline for SARS-CoV-2 powered by the Cipres Server'
title_short: 'Phylogenetic pipeline for SARS-CoV-2 powered by the Cipres Server'
tags:
  - SARS-CoV-2 Phylogenetic Analysis
authors:
  - name: Rutger Vos
    orcid: 
    affiliation: 1
  - name: Tomás Masson
    orcid: 0000-0002-2634-6283 
    affiliation: 2
  - name: 
    orcid: 
    affiliation: 
  - name: 
    orcid: 
    affiliation: 
affiliations:
  - name: 
    index: 1
  - name: Instituto de Biotecnología y Biología Molecular (IBBM)
    index: 2
  - name: 
    index: 3
  - name: 
    index: 4
date: 22 April 2020
bibliography: paper.bib
event: BioHackaton COVID19 
group: Phylogeny
authors_short: John Doe \emph{et al.}
---

# Introduction

Given the severity of the current COVID-19 pandemic, real-time monitoring of circulating isolates is a fundamental tool to speed-up vaccine development and improve public health policy-making. In this context, phylogenetics anaysis can provide useful insights to understand the determinants of SARS-CoV-2 virulence. 

Modern sequencing technologies have made possible the fast accumulation of genomic data for a wide range of species. However, algorithms employed to reconstruct evolutionary relationships between organism are computationally expensive and require high-performance computing resource for large datasets. In this context, the CIPRES Science Gateway offers a web portal which provides researchers with access to several phylogenetic tools running on scalable resources. Moreover, user can interact with this server through a RESTful application interface that allows task automation.

The main goal proposed by Phylogeny working group at the BioHackaton was to develop a standarized workflow for the reconstruction of SARS-CoV-2 phylogenies using the computational resources provided by the CIPRES server. Additionally, this implementation is available on Conda and CPAN  

# Results

## Sequence processing and Phylogenetic Reconstruction

We tested our framework using publicly available whole genome sequences for SARS-CoV2 from the NCBI database. In the first place, sequence were filtered in order to discard smaller sub-genomic fragments. Then, sequences were aligned using MAFFT using default parameters. The resulting multiple sequence alignment (MSA) was used to reconstruct a Maximum Likelihood phylogeny using IQTree. Support values for each partition was calculated using the Ultrafast Bootstrap (UFBoot2) implemented in IQTree. The nucleotide substitution model used in this case was the Hasegawa-Kishino-Yano (HKY) model, which as been used in other studies (INSERT CITE).

## CIPRES client for large phylogenetic Trees

The CIPRES portal has a web browser interface wre users can interact and specify the desired analysis, but also provides a REST interface which allows jobs posting from the command line. The architecture of this client involves a HTTP POST the creates the configuration for the analysis and uploads the data. Job status is checked periodically until completion, and then the results are fetched. 

## Available in Conda and CPAN repositories

# Discussion

# Future Work

# References
