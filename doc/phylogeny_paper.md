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

The main goal proposed by Phylogeny working group at the BioHackaton was to develop a standarized workflow for the reconstruction of SARS-CoV-2 phylogenies using the computational resources provided by the CIPRES server. Additionally, this implementation is available on Conda and CPAN  

# Results

## Sequence processing and Phylogenetic Reconstruction

We tested our framework using publicly available genome sequence for SARS-CoV2 from NCBI database. Sequences were aligned using MAFFT using default parameters. Using this multiple sequence alignment, we inferred a Maximum Likelihood phylogeny using IQTree. 


## Standarized parametrization for SARS-CoV-2

The nucleotide substitution model used in this case was the Hasegawa-Kishino-Yano (HKY) model, which

## CIPRES client for large phylogenetic Trees

## Available in Conda and CPAN repositories

# Discussion

# Future Work

# References
