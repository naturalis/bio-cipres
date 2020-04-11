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
      - entry: $(inputs.aln_dir)
        writable: true
baseCommand: alngather
arguments:
  - -i
  - $(inputs.aln_dir)
  - -o
  - $(inputs.output_name)
inputs:
  - id: aln_dir
    type: Directory
  - id: output_name
    type: string
outputs:
  - id: output_dir
    type: Directory
    outputBinding:
      glob: "$(inputs.fasta_dir.basename)"
