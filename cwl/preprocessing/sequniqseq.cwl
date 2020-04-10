#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.1
baseCommand: sequniqseq
arguments:
  - -infile
  - $(inputs.fasta)
inputs:
  - id: fasta
    type: File
outputs:
  - id: unique_fasta
    type: stdout
stdout: unique.fasta
hints:
  - class: DockerRequirement
    dockerPull: naturalis/covid19-phylogeny
