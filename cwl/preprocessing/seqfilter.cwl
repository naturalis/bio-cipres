#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.1
baseCommand: seqfilter
arguments:
  - -infile
  - $(inputs.fasta)
inputs:
  - id: fasta
    type: File
outputs:
  - id: filtered_fasta
    type: stdout
stdout: filtered.fasta
hints:
  - class: DockerRequirement
    dockerPull: naturalis/covid19-phylogeny
