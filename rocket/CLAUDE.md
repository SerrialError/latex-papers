# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

An engineering notebook (`notebook.typ`) for propellant selection of a VTVL hopper rocket engine (storable pressure-fed liquid bipropellant). Two Python scripts generate all supporting data and figures that the notebook references.

## How to regenerate all outputs

```bash
# Install dependencies (once)
pip install rocketcea numpy pandas matplotlib tabulate

# Step 1: CEA performance sweep — generates rocket_outputs/data/*.csv, figures/*.png, cea_raw/*.txt
python optimize_cea.py --batch --pressure-sweep --pc 150 --pamb 14.7 --thrust 200 --outdir rocket_outputs --mr-step 0.05

# Step 2: sizing, cost, and selection assets — consumes rocket_outputs/ from step 1
python generate_selection_assets.py

# Step 3: compile the notebook
typst compile notebook.typ
```

`generate_selection_assets.py` must be run from the repo root and assumes `rocket_outputs/` already exists.

## Single-case CEA run

```bash
python optimize_cea.py --ox N2O --fuel IPA --pc 150 --pamb 14.7 \
    --mr-min 2.5 --mr-max 6.5 --thrust 200 --outdir rocket_outputs
```

## Script architecture

**`optimize_cea.py`** — wraps RocketCEA to compute ambient-corrected sea-level Isp (not vacuum Isp). Key design decision: always uses `estimate_Ambient_Isp` at the actual ambient pressure rather than `get_Isp` (which returns vacuum Isp). For each propellant pair, it sweeps O/F ratio and finds the `eps` (area ratio) where `Pe ≈ Pamb`, then selects the O/F point that maximizes ambient Isp. Outputs per-pair CSVs, five diagnostic plots per pair, raw CEA text, and a batch summary CSV.

**`generate_selection_assets.py`** — reads `batch_optimum_summary.csv` from step 1 and adds: system sizing (propellant mass/volume for 200 N and 400 N / 60 s burns), propellant cost ranges from public price anchors, storage hardware cost estimates, a vessel-selection map (real GOX cylinder and N2O bottle SKUs), a weighted selection matrix scoring all candidates on 9 criteria, and combined finalist plots.

## Output structure

```
rocket_outputs/
  data/                    # CSVs consumed by notebook.typ
  figures/                 # PNGs embedded in notebook.typ
  cea_raw/                 # Full CEA output text at the optimum point for each pair
  README_rocketcea_outputs.md
```

## Propellant candidates

Ten combinations are in `DEFAULT_CASES` (N2O, GOX, Peroxide70, Peroxide85 × Ethanol, IPA, Methanol). The finalist/selected architecture is **N2O/IPA** (selected baseline) and **N2O/Ethanol** (backup). GOX/Ethanol and GOX/IPA are the alternates if two-phase N2O injection is unacceptable.

## Typst document

`notebook.typ` is a Typst (not LaTeX) document. It defines four callout box macros (`warn-box`, `elim-box`, `finalist-box`, `info-box`) and a table fill helper. Figures and tables are embedded from `rocket_outputs/`.

## Important CEA interpretation rule

Vacuum Isp and exit-pressure-matched Isp are not the same as sea-level Isp for an arbitrary nozzle. All performance comparisons in this project use `isp_amb_s` (ambient-corrected), not `isp_vac_s`. Overexpanded nozzles lose sea-level performance even if they show higher vacuum Isp — `N2O_Ethanol_overexpansion_demo_pc150_mr4p65` files document this explicitly.
