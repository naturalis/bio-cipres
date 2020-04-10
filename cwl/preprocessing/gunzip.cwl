#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.1
baseCommand: gunzip
arguments:
  - -c
  - $(inputs.sequences_gz)
inputs:
  - id: sequences_gz
    type: File[]
outputs:
  - id: merged_fasta
    type: stdout
stdout: merged.fasta
hints:
  - class: DockerRequirement
    dockerPull: naturalis/covid19-phylogeny
