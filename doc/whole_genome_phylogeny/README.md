# Phylogenetic Reconstruction

Sequences with less than 20 Kbp were discarded (there are a lot of short sequences). 

Steps:

- mafft --anysymbol sequences > alignment
- iqtree -s alignment -alrt 1000 -nt 4
- iTOL tree visualization
