#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.1
inputs:
  sequences_gz:
    type: File[]
  outdir:
    type: Directory
outputs:
  sequence_dir:
    type: Directory
    outputSource: seqchunk/outdir
steps:
  gunzip:
    in:
      sequences_gz: sequences_gz
    out: [merged_fasta]
    run: gunzip.cwl
  seqfilter:
    in:
      fasta: gunzip/merged_fasta
    out: [filtered_fasta]
    run: seqfilter.cwl
  sequniqid:
    in:
      fasta: seqfilter/filtered_fasta
    out: [deduplicated_fasta]
    run: sequniqid.cwl
  sequniqseq:
    in:
      fasta: sequniqid/deduplicated_fasta
    out: [unique_fasta]
    run: sequniqseq.cwl
  seqchunk:
    in:
      fasta: sequniqseq/unique_fasta
      outdir: outdir
    out: [outdir]
    run: seqchunk.cwl
