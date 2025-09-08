# Disfluency Analysis Starter Repo

A minimal scaffold to analyze disfluencies in interpreted speech (EPIC/EPTIC or raw EU data).

## Folder layout
- `data/` : raw inputs (audio + transcripts) and metadata
- `derivatives/` : outputs from ASR, alignment, and feature extraction
- `schema/` : CSV templates
- `scripts/` : modeling and processing scripts
- `notebooks/` : exploratory/EDA notebooks
- `configs/` : environment and config files

## Quickstart
1. Place audio & transcripts into `data/` subfolders.
2. Generate segments & alignment into `derivatives/alignments/`.
3. Detect disfluencies (ASR + VAD or parse annotations) and aggregate per segment.
4. Fill `schema/df_analysis.csv` with one row per segment (see header).
5. Run `scripts/model_disfluency_brms.R` to fit the Bayesian model in brms.
6. Inspect posterior, IRRs, and pp_check outputs.
