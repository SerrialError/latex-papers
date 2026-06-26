# RocketCEA Performance Project

This directory keeps the CEA interpretation details out of the design notebook. The notebook only uses the final corrected sea-level values and cites this generated artifact as `@cea_hopper_runs_2026`.

## Why this exists

RocketCEA wraps NASA CEA and exposes both vacuum and ambient-corrected rocket performance functions. The easy mistake is to compare vacuum or exit-pressure-matched outputs as if they are sea-level values. For the hopper, the relevant sizing value is ambient-corrected sea-level impulse at the actual ambient pressure.

RocketCEA's own function documentation states that `get_Isp` returns `IspVac`. Its ambient-Isp documentation states that standard CEA output includes `Ivac` and an `Isp` value for the case where ambient pressure equals nozzle exit pressure, then gives `estimate_Ambient_Isp` for arbitrary ambient pressure and nozzle-flow mode checks.

## Baseline method

The main comparison uses:

1. `Pc = 150 psia`.
2. `Pamb = 14.7 psia`.
3. A broad O/F sweep for each candidate.
4. For each O/F point, compute `eps` such that `Pe ~= Pamb`.
5. Compute ambient-corrected sea-level Isp with `estimate_Ambient_Isp`, not `get_Isp`.
6. Record `Isp_SL`, `Isp_vac`, `eps`, `Pe`, `c*`, chamber temperature, molecular weight, gamma, thrust coefficient, and optional sizing geometry.
7. Use equilibrium chemistry for the design comparison. Frozen-at-chamber and frozen-at-throat are sensitivity checks, not the main ranking basis.

## Key corrected performance results

From `rocket_outputs/data/batch_optimum_summary.csv`:

| Candidate | O/F | eps | Sea-level Isp (s) | Vacuum Isp at same eps (s) | c* (m/s) | Tc (K) |
|---|---:|---:|---:|---:|---:|---:|
| GOX / IPA | 1.65 | 2.432 | 230.056 | 272.888 | 1762.488 | 3237.142 |
| GOX / Ethanol | 1.55 | 2.455 | 225.617 | 267.975 | 1726.617 | 3187.056 |
| GOX / Methanol | 1.20 | 2.463 | 221.276 | 262.950 | 1692.791 | 3074.402 |
| N2O / IPA | 5.10 | 2.366 | 207.000 | 244.610 | 1590.456 | 3119.523 |
| N2O / Ethanol | 4.65 | 2.375 | 204.836 | 242.177 | 1573.149 | 3064.179 |
| 85% H2O2 / IPA | 5.65 | 2.368 | 203.196 | 240.162 | 1562.363 | 2553.497 |
| N2O / Methanol | 3.50 | 2.378 | 203.038 | 240.091 | 1559.253 | 2972.114 |
| 85% H2O2 / Ethanol | 5.00 | 2.364 | 201.126 | 237.660 | 1546.657 | 2506.996 |
| 70% H2O2 / IPA | 7.20 | 2.307 | 186.868 | 220.083 | 1440.896 | 2183.620 |
| 70% H2O2 / Ethanol | 6.30 | 2.304 | 184.981 | 217.824 | 1426.203 | 2139.202 |

## N2O/Ethanol sanity check

For `N2O/Ethanol`, `Pc = 150 psia`, `MR = 4.65`, and sea-level ambient pressure:

| Case | eps | Pe (psia) | Isp_SL (s) | Isp_vac (s) | Mode |
|---|---:|---:|---:|---:|---|
| Sea-level matched | 2.375 | 14.699 | 204.836 | 242.177 | Pe ~= Pamb |
| Forced eps = 4.1 | 4.100 | 6.555 | 195.594 | 260.049 | Overexpanded |

The `eps = 4.1` point looks attractive in vacuum output, but it is worse at sea level because the nozzle exit pressure is far below ambient pressure.

## Chemistry-mode sensitivity

For the same N2O/Ethanol point:

| Chemistry mode | eps case | eps | Pe (psia) | Isp_SL (s) | Mode |
|---|---|---:|---:|---:|---|
| Equilibrium | own matched | 2.375 | 14.699 | 204.836 | Pe ~= Pamb |
| Frozen at chamber | own matched | 2.196 | 14.700 | 197.613 | Pe ~= Pamb |
| Frozen at throat | own matched | 2.191 | 14.700 | 201.031 | Pe ~= Pamb |
| Frozen at throat | eps = 2.38 | 2.380 | 12.911 | 200.844 | overexpanded |

This means a ~200 s result is plausible under frozen-flow or slightly different ambient/nozzle assumptions. It is not a contradiction of the RocketCEA equilibrium value.

## Generated files

- `rocket_outputs/data/batch_optimum_summary.csv`
- `rocket_outputs/data/pressure_sweep_summary.csv`
- `rocket_outputs/data/system_sizing_and_cost_summary.csv`
- `rocket_outputs/data/selection_matrix.csv`
- `rocket_outputs/data/propellant_price_assumptions.csv`
- `rocket_outputs/data/*_equilibrium_pc150.csv`
- `rocket_outputs/figures/pressure_sensitivity.png`
- `rocket_outputs/figures/finalist_of_vs_isp_combined.png`
- `rocket_outputs/figures/*_of_isp_and_oxidizer_mass.png`
- `rocket_outputs/figures/oxidizer_storage_volume_comparison.png`
- `rocket_outputs/figures/N2O_Ethanol_overexpansion_demo_pc150_mr4p65.png`
- `rocket_outputs/cea_raw/*_optimum_cea.txt`

## How to regenerate

```bash
python optimize_cea.py --batch --pressure-sweep --pc 150 --pamb 14.7 --thrust 200 --outdir rocket_outputs --mr-step 0.05
python generate_selection_assets.py
```

Install dependencies first:

```bash
python -m pip install rocketcea numpy pandas matplotlib tabulate
```

`generate_selection_assets.py` assumes it is run from the package root after `optimize_cea.py` has created `rocket_outputs/`.
