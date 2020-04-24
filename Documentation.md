## CIPRES

CIPRES Science Gateway, a web portal designed to provide researchers with transparent access to the fastest available community codes 
for inference of phylogenetic relationships, and implementation of these codes on scalable computational resources. 

We are analysing evolutionary history of SARS-CoV-2 genomes.

## Data description

[Genome](https://github.com/naturalis/bio-cipres/tree/master/data/genomes) - fasta format SARS-CoV2 genomes.

[Genes](https://github.com/naturalis/bio-cipres/tree/master/data/genes) - SARS-CoV-2 genes.

[Alignment output](https://github.com/naturalis/bio-cipres/tree/master/data/alignments) (whole genome phylogeny) - fasta format alignment file of SARS-CoV-2 genomes. 

## Implementation

### Phylogenetic Reconstruction

Entire construct is a two-step process.

1. Alignment

```
mafft --anysymbol sequences > alignment

```

2. iTOL tree generation and visualisatiion.

```

iqtree -s alignment -alrt 1000 -nt 4

iTOL tree visualization

```
#### ciprusrun

cipreusrun is command line interface to the CIPRES analysis portal.

[metacpan repository for bio-phylo-cipres](https://metacpan.org/source/RVOSA/Bio-Phylo-CIPRES-v0.2.1/README.md)

[GitHub repository for bio-phylo-cipres](https://github.com/naturalis/bio-cipres/tree/master/conda/perl-bio-phylo-cipres/v0.2.1)

#### Perl module and dependencies

[Bio::Phylo::CIPRES](https://metacpan.org/pod/release/RVOSA/Bio-Phylo-CIPRES-v0.2.1/lib/Bio/Phylo/CIPRES.pm) - Reusable components for CIPRES REST API access 

[meta CPAN repository for cipresrun](https://metacpan.org/pod/distribution/Bio-Phylo-CIPRES/script/cipresrun)

[GitHub repository for cipresrun](https://github.com/naturalis/bio-cipres/blob/master/lib/Bio/Phylo/CIPRES.pm)


#### Aligning sequences

Command-line usage:

```
cipresrun \
     -t MAFFT_XSEDE \
     -p vparam.anysymbol_=1 \
     -i <infile> \
     -y cipres_appinfo.yml \
     -o output.mafft=/path/to/outfile.fasta
```
Command-line parameters:

[MAFFT_xsede parameters details](http://www.phylo.org/index.php/rest/mafft_xsede.html)

```
-t MAFFT_XSEDE - tool name i.e MAFFT_XSEDE

-p vparam.anysymbol_=1 - key-value paired configuration parameter for tool. Anysymbol for unusal characters. Default value 0.

-i <infile> - path to unaligned fasta files.

-y cipres_appinfo.yml - YML format configuration file.

-o output.mafft=/path/to/outfile.fasta - path along with aligned file name.

```

#### Inferring trees 


Command-line usage:

```
cipresrun \
    -t IQTREE_XSEDE \
    -p vparam.specify_runtype_=2 \
    -p vparam.specify_dnamodel_=HKY \
    -p vparam.bootstrap_type_=bb \
    -p vparam.use_bnni_=1 \
    -p vparam.num_bootreps_=1000 \
    -p vparam.specify_numparts_=1 \
    -i /path/to/outfile.fasta \
    -y cipres_appinfo.yml \    
    -o output.contree=/path/to/tree.dnd
```
Command-line parameters:

[IQTREE_XSEDE parameter details](http://www.phylo.org/index.php/rest/iqtree_xsede.html)  

```
-t IQTREE_XSEDE  - tool name i.e IQTREE_XSEDE 

-p vparam.anysymbol_=1 - key-value paired configuration parameter for tool. Anysymbol for unusal characters. Default value 0.

-p vparam.specify_runtype_=2 - Specify the nrun type - 2 for Tree Inference.

-p vparam.specify_dnamodel_=HKY -Specify a DNA model i.e HKY.

-p vparam.bootstrap_type_=bb - Bootstrap Type.

-p vparam.use_bnni_=1 - 

-p vparam.num_bootreps_=1000 - Specify number of bootstrap replicates (>=1000).

-p vparam.specify_numparts_=1 - How many partitions does your data set have.

-i <infile> - fasta format file for aligned trees.

-y cipres_appinfo.yml - YML format configuration file.

-o output.contree=/path/to/tree.dnd - output file along with storage path or location.

```

Command-line implementation of two step phylogenetic reconstructs

To align sequences in a FASTA file with MAFFT:

```
cipresrun \ -t MAFFT_XSEDE \ -p vparam.anysymbol_=1 \ -i <infile> \ -y cipres_appinfo.yml \ -o output.mafft=/path/to/outfile.fasta 

```

To infer trees from an aligned FASTA file using IQTree:


```
cipresrun \ -t IQTREE_XSEDE \ -p vparam.specify_runtype_=2 \ -p vparam.specify_dnamodel_=HKY \ -p vparam.bootstrap_type_=bb \ -p vparam.use_bnni_=1 \ -p vparam.num_bootreps_=1000 \ -p vparam.specify_numparts_=1 \ -i /path/to/outfile.fasta \ -y cipres_appinfo.yml \ 
-o output.contree=/path/to/tree.dnd 

```

## Results







