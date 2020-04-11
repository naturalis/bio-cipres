#!/usr/bin/env cwl-runner
# Require docker build --tag naturalis/covid19-phylogeny before execution
class: CommandLineTool
cwlVersion: v1.1
requirements:
  - class: DockerRequirement
    dockerPull: naturalis/covid19-phylogeny
  - class: NetworkAccess
    networkAccess: true
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.fasta_dir)
baseCommand: alnspread
arguments:
  - -i
  - $(inputs.fasta_dir)
  - -y
  - $(inputs.yaml)
inputs:
  - id: fasta_dir
    type: Directory
  - id: yaml
    type: File
outputs:
  - id: output_dir
    type: File
    outputBinding:
      glob: "$(inputs.output_name)"
