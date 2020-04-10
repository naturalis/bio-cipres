#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.1
baseCommand: sequniqid
arguments:
  - -infile
  - $(inputs.fasta)
inputs:
  - id: fasta
    type: File
outputs:
  - id: deduplicated_fasta
    type: stdout
stdout: deduplicated.fasta
hints:
  - class: DockerRequirement
    dockerPull: naturalis/covid19-phylogeny
