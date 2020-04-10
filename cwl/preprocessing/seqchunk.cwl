#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.1
baseCommand: seqchunk
requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.outdir)
        writable: true
arguments:
  - -infile
  - $(inputs.fasta)
  - -outdir
  - $(inputs.outdir)
inputs:
  - id: fasta
    type: File
  - id: outdir
    type: Directory
outputs:
  - id: outdir
    type: Directory
    outputBinding:
      glob: "$(inputs.outdir.basename)"
hints:
  - class: DockerRequirement
    dockerPull: naturalis/covid19-phylogeny
