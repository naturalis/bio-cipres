#!/usr/bin/env cwl-runner
# Require docker build --tag naturalis/covid19-phylogeny before execution
class: CommandLineTool
cwlVersion: v1.1
requirements:
  - class: DockerRequirement
    dockerPull: naturalis/covid19-phylogeny
baseCommand: dncalign
arguments:
  - -i
  - $(inputs.fasta)
  - -y
  - $(inputs.yaml)
  - -o
  - $(inputs.output)
  - -c
  - $(inputs.chunks)
inputs:
  - id: fasta
    type: File
  - id: yaml
    type: File
  - id: output
    type: string
  - id: chunks
    type: int
outputs:
 - id: alignment
   type: File
   outputBinding:
     glob: "$(inputs.output)"
