#!/usr/bin/env python3
"""
RocketCEA propellant performance optimizer for low-altitude hopper sizing.

Purpose
-------
This script is intended to avoid the common CEA mistake of comparing vacuum or
exit-pressure-matched Isp values as if they were sea-level Isp values. It reports:

  * ambient-corrected Isp at a specified Pamb,
  * CEA/RocketCEA vacuum Isp,
  * the nozzle area ratio that gives Pe ~= Pamb for each O/F point,
  * c*, chamber temperature, chamber molecular weight/gamma,
  * optional preliminary mass-flow and nozzle geometry for a selected thrust.

Dependencies
------------
    pip install rocketcea numpy pandas matplotlib

Examples
--------
Single case, with plots and raw CEA output at the optimum:

    python optimize_cea.py --ox N2O --fuel IPA --pc 150 --pamb 14.7 \
        --mr-min 2.5 --mr-max 6.5 --thrust 200 --outdir rocket_outputs

Batch run for the propellant set used in the notebook:

    python optimize_cea.py --batch --pc 150 --pamb 14.7 \
        --thrust 200 --outdir rocket_outputs

Notes
-----
RocketCEA propellant names are not always the plain-English names. This script maps
common names such as IPA, ethanol, methanol, oxygen, and peroxide85 to RocketCEA names.
Peroxide blends may be supplied as Peroxide70, Peroxide85, Peroxide90, etc.
"""

from __future__ import annotations

import argparse
import csv
import math
import re
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable, Optional

import numpy as np
import pandas as pd

# Use a non-interactive backend so the script works on headless machines.
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

try:
    from rocketcea.cea_obj import CEA_Obj
except Exception as exc:  # pragma: no cover - user environment check
    raise SystemExit(
        "RocketCEA could not be imported. Install it with `pip install rocketcea` "
        "and ensure a Fortran compiler is available if your Python version has no wheel.\n"
        f"Original error: {exc}"
    )

G0 = 9.80665  # m/s^2
PSI_TO_PA = 6894.757293168361
FT_TO_M = 0.3048
RANKINE_TO_K = 5.0 / 9.0

ALIASES = {
    "oxygen": "GOX",
    "gox": "GOX",
    "go2": "GOX",
    "o2": "GOX",
    "lox": "LOX",
    "n2o": "N2O",
    "nitrous": "N2O",
    "nitrous oxide": "N2O",
    "ethanol": "C2H5OH",
    "etoh": "C2H5OH",
    "c2h5oh": "C2H5OH",
    "ipa": "Isopropanol",
    "isopropanol": "Isopropanol",
    "2-propanol": "Isopropanol",
    "methanol": "CH3OH",
    "meoh": "CH3OH",
    "ch3oh": "CH3OH",
    "rp1": "RP-1",
    "rp-1": "RP-1",
    "h2o2": "H2O2",
    "peroxide": "H2O2",
}

DEFAULT_CASES = [
    # label, oxidizer, fuel, mr_min, mr_max
    ("N2O_Ethanol", "N2O", "C2H5OH", 3.0, 7.0),
    ("N2O_IPA", "N2O", "Isopropanol", 2.5, 6.5),
    ("N2O_Methanol", "N2O", "CH3OH", 2.0, 6.0),
    ("GOX_Ethanol", "GOX", "C2H5OH", 0.8, 3.5),
    ("GOX_IPA", "GOX", "Isopropanol", 0.8, 3.5),
    ("GOX_Methanol", "GOX", "CH3OH", 0.8, 3.5),
    ("Peroxide70_Ethanol", "Peroxide70", "C2H5OH", 1.0, 10.0),
    ("Peroxide70_IPA", "Peroxide70", "Isopropanol", 1.0, 10.0),
    ("Peroxide85_Ethanol", "Peroxide85", "C2H5OH", 1.0, 10.0),
    ("Peroxide85_IPA", "Peroxide85", "Isopropanol", 1.0, 10.0),
]

PC_SWEEP_DEFAULT = [100.0, 125.0, 150.0, 175.0, 200.0, 250.0, 300.0]


@dataclass
class Optimum:
    case: str
    ox: str
    fuel: str
    chemistry: str
    pc_psia: float
    pamb_psia: float
    mr: float
    eps: float
    pe_psia: float
    isp_amb_s: float
    isp_vac_s: float
    mode: str
    cstar_m_s: float
    t_chamber_k: float
    chamber_mw: float
    chamber_gamma: float
    cf_cea: float
    cf_amb: float
    thrust_n: Optional[float] = None
    mdot_kg_s: Optional[float] = None
    throat_area_m2: Optional[float] = None
    throat_diameter_mm: Optional[float] = None
    exit_diameter_mm: Optional[float] = None


def normalize_name(name: str) -> str:
    raw = name.strip()
    key = raw.lower().strip().replace("_", " ").replace("-", "-")
    if key in ALIASES:
        return ALIASES[key]
    # Preserve RocketCEA peroxide blend naming such as Peroxide70 or peroxide85.
    m = re.fullmatch(r"peroxide\s*([0-9]+(?:\.[0-9]+)?)", key)
    if m:
        pct = m.group(1)
        # Preserve integer concentration strings such as "70" and "85".
        # Only strip insignificant zeros from decimal forms such as "85.0".
        if "." in pct:
            pct = pct.rstrip("0").rstrip(".")
        return f"Peroxide{pct}"
    return raw


def chemistry_flags(chemistry: str) -> tuple[int, int, str]:
    c = chemistry.lower().strip().replace("_", "-")
    if c in {"eq", "equilibrium", "shifting", "shifting-equilibrium"}:
        return 0, 0, "equilibrium"
    if c in {"frozen", "frozen-chamber", "frozen-at-chamber"}:
        return 1, 0, "frozen_chamber"
    if c in {"frozen-throat", "frozen-at-throat", "throat"}:
        return 1, 1, "frozen_throat"
    raise ValueError(f"Unknown chemistry mode: {chemistry}")


def safe_float(x: object) -> float:
    return float(np.asarray(x))


def evaluate_row(
    obj: CEA_Obj,
    mr: float,
    pc_psia: float,
    pamb_psia: float,
    frozen: int,
    frozen_at_throat: int,
) -> dict[str, object]:
    eps = obj.get_eps_at_PcOvPe(
        Pc=pc_psia,
        MR=mr,
        PcOvPe=pc_psia / pamb_psia,
        frozen=frozen,
        frozenAtThroat=frozen_at_throat,
    )
    isp_amb, mode = obj.estimate_Ambient_Isp(
        Pc=pc_psia,
        MR=mr,
        eps=eps,
        Pamb=pamb_psia,
        frozen=frozen,
        frozenAtThroat=frozen_at_throat,
    )
    isp_vac = obj.get_Isp(
        Pc=pc_psia,
        MR=mr,
        eps=eps,
        frozen=frozen,
        frozenAtThroat=frozen_at_throat,
    )
    cstar_m_s = obj.get_Cstar(Pc=pc_psia, MR=mr) * FT_TO_M
    t_chamber_k = obj.get_Tcomb(Pc=pc_psia, MR=mr) * RANKINE_TO_K
    mw, gamma = obj.get_Chamber_MolWt_gamma(Pc=pc_psia, MR=mr, eps=eps)
    pe_psia = pc_psia / obj.get_PcOvPe(
        Pc=pc_psia,
        MR=mr,
        eps=eps,
        frozen=frozen,
        frozenAtThroat=frozen_at_throat,
    )
    if frozen:
        cf_cea, cf_amb, cf_mode = obj.getFrozen_PambCf(
            Pamb=pamb_psia,
            Pc=pc_psia,
            MR=mr,
            eps=eps,
            frozenAtThroat=frozen_at_throat,
        )
    else:
        cf_cea, cf_amb, cf_mode = obj.get_PambCf(
            Pamb=pamb_psia,
            Pc=pc_psia,
            MR=mr,
            eps=eps,
        )
    return {
        "mr": float(mr),
        "eps": safe_float(eps),
        "pe_psia": safe_float(pe_psia),
        "isp_amb_s": safe_float(isp_amb),
        "isp_vac_s": safe_float(isp_vac),
        "mode": str(mode),
        "cstar_m_s": safe_float(cstar_m_s),
        "t_chamber_k": safe_float(t_chamber_k),
        "chamber_mw": safe_float(mw),
        "chamber_gamma": safe_float(gamma),
        "cf_cea": safe_float(cf_cea),
        "cf_amb": safe_float(cf_amb),
        "cf_mode": str(cf_mode),
    }


def add_geometry(opt: Optimum, thrust_n: Optional[float]) -> Optimum:
    if thrust_n is None or thrust_n <= 0:
        return opt
    mdot = thrust_n / (opt.isp_amb_s * G0)
    pc_pa = opt.pc_psia * PSI_TO_PA
    throat_area = thrust_n / (opt.cf_amb * pc_pa)
    throat_d = math.sqrt(4.0 * throat_area / math.pi)
    exit_area = throat_area * opt.eps
    exit_d = math.sqrt(4.0 * exit_area / math.pi)
    opt.thrust_n = thrust_n
    opt.mdot_kg_s = mdot
    opt.throat_area_m2 = throat_area
    opt.throat_diameter_mm = throat_d * 1000.0
    opt.exit_diameter_mm = exit_d * 1000.0
    return opt


def run_case(
    case: str,
    ox: str,
    fuel: str,
    pc_psia: float,
    pamb_psia: float,
    mr_min: float,
    mr_max: float,
    mr_step: float,
    chemistry: str,
    thrust_n: Optional[float],
    outdir: Path,
    save_raw_cea: bool = True,
    make_plots: bool = True,
) -> tuple[pd.DataFrame, Optimum]:
    ox = normalize_name(ox)
    fuel = normalize_name(fuel)
    frozen, frozen_at_throat, chemistry_name = chemistry_flags(chemistry)
    obj = CEA_Obj(oxName=ox, fuelName=fuel)

    rows: list[dict[str, object]] = []
    for mr in np.arange(mr_min, mr_max + 0.5 * mr_step, mr_step):
        try:
            row = evaluate_row(obj, float(mr), pc_psia, pamb_psia, frozen, frozen_at_throat)
            # RocketCEA can return formally successful but physically unusable values
            # near invalid mixture-ratio endpoints. Keep only finite, positive rows.
            numeric_keys = ["eps", "pe_psia", "isp_amb_s", "isp_vac_s", "cstar_m_s", "t_chamber_k", "chamber_gamma", "cf_amb"]
            if not all(math.isfinite(float(row[k])) for k in numeric_keys):
                raise ValueError(f"non-finite RocketCEA result at MR={mr}")
            if float(row["eps"]) <= 1.0 or float(row["isp_amb_s"]) <= 0.0 or float(row["cf_amb"]) <= 0.0:
                raise ValueError(f"non-physical RocketCEA result at MR={mr}: {row}")
            row.update({"case": case, "ox": ox, "fuel": fuel, "pc_psia": pc_psia, "pamb_psia": pamb_psia, "chemistry": chemistry_name})
            rows.append(row)
        except Exception as exc:
            rows.append({
                "case": case,
                "ox": ox,
                "fuel": fuel,
                "pc_psia": pc_psia,
                "pamb_psia": pamb_psia,
                "chemistry": chemistry_name,
                "mr": float(mr),
                "error": repr(exc),
            })

    df = pd.DataFrame(rows)
    good = df.dropna(subset=["isp_amb_s"]).copy()
    if good.empty:
        raise RuntimeError(f"No successful CEA rows for {case} ({ox}/{fuel}).")
    idx = good["isp_amb_s"].idxmax()
    best = good.loc[idx]
    opt = Optimum(
        case=case,
        ox=ox,
        fuel=fuel,
        chemistry=chemistry_name,
        pc_psia=pc_psia,
        pamb_psia=pamb_psia,
        mr=float(best["mr"]),
        eps=float(best["eps"]),
        pe_psia=float(best["pe_psia"]),
        isp_amb_s=float(best["isp_amb_s"]),
        isp_vac_s=float(best["isp_vac_s"]),
        mode=str(best["mode"]),
        cstar_m_s=float(best["cstar_m_s"]),
        t_chamber_k=float(best["t_chamber_k"]),
        chamber_mw=float(best["chamber_mw"]),
        chamber_gamma=float(best["chamber_gamma"]),
        cf_cea=float(best["cf_cea"]),
        cf_amb=float(best["cf_amb"]),
    )
    opt = add_geometry(opt, thrust_n)

    # Save data.
    data_dir = outdir / "data"
    fig_dir = outdir / "figures"
    raw_dir = outdir / "cea_raw"
    data_dir.mkdir(parents=True, exist_ok=True)
    fig_dir.mkdir(parents=True, exist_ok=True)
    raw_dir.mkdir(parents=True, exist_ok=True)
    df.to_csv(data_dir / f"{case}_{chemistry_name}_pc{pc_psia:g}.csv", index=False)

    # Plot Isp, eps, cstar, and chamber temperature as separate figures.
    # This is disabled for pressure sweeps to keep batch runs fast.
    if make_plots:
        plot_specs = [
            ("isp_amb_s", "Sea-level ambient-corrected Isp (s)", "ambient_isp"),
            ("isp_vac_s", "Vacuum Isp from CEA/RocketCEA (s)", "vacuum_isp"),
            ("eps", "Nozzle expansion ratio for Pe ≈ Pamb", "epsilon"),
            ("cstar_m_s", "Characteristic velocity c* (m/s)", "cstar"),
            ("t_chamber_k", "Chamber temperature (K)", "tchamber"),
        ]
        for col, ylabel, suffix in plot_specs:
            fig, ax = plt.subplots(figsize=(7.5, 4.7))
            ax.plot(good["mr"], good[col], linewidth=2)
            ax.axvline(opt.mr, linestyle="--", linewidth=1)
            ax.set_xlabel("Mixture ratio O/F (mass)")
            ax.set_ylabel(ylabel)
            ax.set_title(f"{case}: {ylabel}\nPc={pc_psia:g} psia, Pamb={pamb_psia:g} psia, {chemistry_name}")
            ax.grid(True, linestyle=":", alpha=0.6)
            fig.tight_layout()
            fig.savefig(fig_dir / f"{case}_{suffix}_pc{pc_psia:g}.png", dpi=180)
            plt.close(fig)

    if save_raw_cea:
        try:
            raw = obj.get_full_cea_output(
                Pc=pc_psia,
                MR=opt.mr,
                eps=opt.eps,
                frozen=frozen,
                frozenAtThroat=frozen_at_throat,
                pc_units="psia",
                output="siunits",
                short_output=1,
                show_transport=0,
            )
            (raw_dir / f"{case}_{chemistry_name}_optimum_cea.txt").write_text(raw)
        except Exception as exc:
            (raw_dir / f"{case}_{chemistry_name}_optimum_cea_ERROR.txt").write_text(repr(exc))

    return good, opt


def plot_summary(summary: pd.DataFrame, outdir: Path) -> None:
    fig_dir = outdir / "figures"
    fig_dir.mkdir(parents=True, exist_ok=True)

    fig, ax = plt.subplots(figsize=(9, 5))
    x = np.arange(len(summary))
    ax.bar(x, summary["isp_amb_s"])
    ax.set_xticks(x)
    ax.set_xticklabels(summary["case"], rotation=35, ha="right")
    ax.set_ylabel("Optimized sea-level Isp (s)")
    ax.set_title("RocketCEA batch comparison: optimized sea-level Isp")
    ax.grid(True, axis="y", linestyle=":", alpha=0.6)
    fig.tight_layout()
    fig.savefig(fig_dir / "batch_optimized_sea_level_isp.png", dpi=180)
    plt.close(fig)

    fig, ax = plt.subplots(figsize=(9, 5))
    x = np.arange(len(summary))
    ax.plot(x, summary["mr"], marker="o", linewidth=2)
    ax.set_xticks(x)
    ax.set_xticklabels(summary["case"], rotation=35, ha="right")
    ax.set_ylabel("Optimum mixture ratio O/F")
    ax.set_title("RocketCEA batch comparison: optimum O/F")
    ax.grid(True, linestyle=":", alpha=0.6)
    fig.tight_layout()
    fig.savefig(fig_dir / "batch_optimum_mr.png", dpi=180)
    plt.close(fig)


def run_pressure_sweep(
    cases: Iterable[tuple[str, str, str, float, float]],
    pc_values: Iterable[float],
    pamb_psia: float,
    mr_step: float,
    chemistry: str,
    outdir: Path,
) -> pd.DataFrame:
    rows = []
    for case, ox, fuel, mr_min, mr_max in cases:
        for pc in pc_values:
            _, opt = run_case(
                case=case,
                ox=ox,
                fuel=fuel,
                pc_psia=float(pc),
                pamb_psia=pamb_psia,
                mr_min=mr_min,
                mr_max=mr_max,
                mr_step=mr_step,
                chemistry=chemistry,
                thrust_n=None,
                outdir=outdir,
                save_raw_cea=False,
                make_plots=False,
            )
            rows.append(asdict(opt))
    df = pd.DataFrame(rows)
    df.to_csv(outdir / "data" / "pressure_sweep_summary.csv", index=False)

    fig, ax = plt.subplots(figsize=(8, 5))
    for case in df["case"].unique():
        sub = df[df["case"] == case]
        ax.plot(sub["pc_psia"], sub["isp_amb_s"], marker="o", linewidth=2, label=case)
    ax.set_xlabel("Chamber pressure Pc (psia)")
    ax.set_ylabel("Optimized sea-level Isp (s)")
    ax.set_title(f"Pressure sensitivity, Pamb={pamb_psia:g} psia")
    ax.grid(True, linestyle=":", alpha=0.6)
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(outdir / "figures" / "pressure_sensitivity.png", dpi=180)
    plt.close(fig)
    return df



def write_n2o_ethanol_interpretation_demo(outdir: Path, pc_psia: float, pamb_psia: float) -> None:
    """Write a focused demo showing why vacuum/exit-matched Isp is not sea-level Isp.

    The notebook uses this as a sanity check for the specific N2O/ethanol discrepancy:
    Pc=150 psia, MR=4.65, and eps either matched to sea-level Pamb or forced to a
    larger value such as 4.1.  The function also writes a small equilibrium/frozen
    chemistry comparison.
    """
    data_dir = outdir / "data"
    fig_dir = outdir / "figures"
    raw_dir = outdir / "cea_raw"
    data_dir.mkdir(parents=True, exist_ok=True)
    fig_dir.mkdir(parents=True, exist_ok=True)
    raw_dir.mkdir(parents=True, exist_ok=True)

    obj = CEA_Obj(oxName="N2O", fuelName="C2H5OH")
    mr = 4.65
    eps_matched = obj.get_eps_at_PcOvPe(Pc=pc_psia, MR=mr, PcOvPe=pc_psia / pamb_psia)
    eps_values = np.unique(np.round(np.concatenate([np.linspace(1.2, 8.0, 137), [eps_matched, 2.38, 4.1, 5.0, 10.0]]), 6))

    rows: list[dict[str, object]] = []
    for eps in eps_values:
        try:
            isp_amb, mode = obj.estimate_Ambient_Isp(Pc=pc_psia, MR=mr, eps=float(eps), Pamb=pamb_psia)
            isp_vac = obj.get_Isp(Pc=pc_psia, MR=mr, eps=float(eps))
            pe_psia = pc_psia / obj.get_PcOvPe(Pc=pc_psia, MR=mr, eps=float(eps))
            rows.append({"eps": float(eps), "pe_psia": pe_psia, "isp_amb_s": isp_amb, "isp_vac_s": isp_vac, "mode": mode})
        except Exception as exc:
            rows.append({"eps": float(eps), "error": repr(exc)})
    over_df = pd.DataFrame(rows)
    over_df.to_csv(data_dir / "N2O_Ethanol_overexpansion_demo_pc150_mr4p65.csv", index=False)

    good = over_df.dropna(subset=["isp_amb_s"]).copy()
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(good["eps"], good["isp_amb_s"], linewidth=2, label="Ambient-corrected sea-level Isp")
    ax.plot(good["eps"], good["isp_vac_s"], linewidth=2, label="Vacuum Isp")
    for eps, label in [(eps_matched, "Pe ≈ Pamb"), (4.1, "eps = 4.1")]:
        ax.axvline(eps, linestyle="--", linewidth=1)
        row = good.iloc[(good["eps"] - eps).abs().argmin()]
        ax.annotate(label, xy=(eps, row["isp_amb_s"]), xytext=(eps + 0.15, row["isp_amb_s"] + 8), arrowprops={"arrowstyle": "->"})
    ax.set_xlabel("Expansion ratio eps = Ae/At")
    ax.set_ylabel("Specific impulse (s)")
    ax.set_title(f"N2O/Ethanol: vacuum Isp gain vs sea-level overexpansion penalty\nPc={pc_psia:g} psia, MR=4.65, Pamb={pamb_psia:g} psia")
    ax.grid(True, linestyle=":", alpha=0.6)
    ax.legend()
    fig.tight_layout()
    fig.savefig(fig_dir / "N2O_Ethanol_overexpansion_demo_pc150_mr4p65.png", dpi=180)
    plt.close(fig)

    chem_rows: list[dict[str, object]] = []
    for chem, frozen, frozen_at_throat in [("equilibrium", 0, 0), ("frozen_chamber", 1, 0), ("frozen_throat", 1, 1)]:
        for eps, label in [(eps_matched, "matched_equilibrium_eps"), (2.38, "eps_2p38"), (4.1, "eps_4p1")]:
            try:
                isp_amb, mode = obj.estimate_Ambient_Isp(Pc=pc_psia, MR=mr, eps=eps, Pamb=pamb_psia, frozen=frozen, frozenAtThroat=frozen_at_throat)
                isp_vac = obj.get_Isp(Pc=pc_psia, MR=mr, eps=eps, frozen=frozen, frozenAtThroat=frozen_at_throat)
                pe_psia = pc_psia / obj.get_PcOvPe(Pc=pc_psia, MR=mr, eps=eps, frozen=frozen, frozenAtThroat=frozen_at_throat)
                chem_rows.append({"chemistry": chem, "eps_case": label, "eps": eps, "pe_psia": pe_psia, "isp_amb_s": isp_amb, "isp_vac_s": isp_vac, "mode": mode})
            except Exception as exc:
                chem_rows.append({"chemistry": chem, "eps_case": label, "eps": eps, "error": repr(exc)})
    for chem, frozen, frozen_at_throat in [("frozen_chamber", 1, 0), ("frozen_throat", 1, 1)]:
        eps = obj.get_eps_at_PcOvPe(Pc=pc_psia, MR=mr, PcOvPe=pc_psia / pamb_psia, frozen=frozen, frozenAtThroat=frozen_at_throat)
        isp_amb, mode = obj.estimate_Ambient_Isp(Pc=pc_psia, MR=mr, eps=eps, Pamb=pamb_psia, frozen=frozen, frozenAtThroat=frozen_at_throat)
        isp_vac = obj.get_Isp(Pc=pc_psia, MR=mr, eps=eps, frozen=frozen, frozenAtThroat=frozen_at_throat)
        pe_psia = pc_psia / obj.get_PcOvPe(Pc=pc_psia, MR=mr, eps=eps, frozen=frozen, frozenAtThroat=frozen_at_throat)
        chem_rows.append({"chemistry": chem, "eps_case": "own_matched_eps", "eps": eps, "pe_psia": pe_psia, "isp_amb_s": isp_amb, "isp_vac_s": isp_vac, "mode": mode})
    pd.DataFrame(chem_rows).to_csv(data_dir / "N2O_Ethanol_chemistry_mode_comparison_pc150_mr4p65.csv", index=False)

    raw_parts: list[str] = []
    for frozen, frozen_at_throat, eps, label in [
        (0, 0, eps_matched, "equilibrium_matched"),
        (0, 0, 4.1, "equilibrium_eps4p1"),
        (1, 1, 2.38, "frozen_throat_eps2p38"),
    ]:
        raw_parts.append("\n" + "=" * 80 + f"\n{label}: Pc={pc_psia:g} psia, MR={mr}, eps={eps}\n" + "=" * 80 + "\n")
        raw_parts.append(obj.get_full_cea_output(Pc=pc_psia, MR=mr, eps=eps, frozen=frozen, frozenAtThroat=frozen_at_throat, pc_units="psia", output="siunits", short_output=1, show_transport=0))
    (raw_dir / "N2O_Ethanol_CEA_matched_vs_overexpanded.txt").write_text("\n".join(raw_parts))

def write_markdown_report(summary: pd.DataFrame, pc_sweep: Optional[pd.DataFrame], outdir: Path) -> None:
    lines = []
    lines.append("# RocketCEA Output Summary\n")
    lines.append("This folder was generated by `optimize_cea.py`. The main comparison uses RocketCEA `estimate_Ambient_Isp` at the specified sea-level ambient pressure, not CEA vacuum Isp.\n")
    lines.append("## Batch optimum summary\n")
    cols = ["case", "ox", "fuel", "pc_psia", "pamb_psia", "mr", "eps", "pe_psia", "isp_amb_s", "isp_vac_s", "cstar_m_s", "t_chamber_k", "mode"]
    lines.append(summary[cols].round(3).to_markdown(index=False))
    lines.append("\n")
    if pc_sweep is not None and not pc_sweep.empty:
        lines.append("## Pressure sensitivity at optimized O/F and Pe≈Pamb\n")
        piv = pc_sweep.pivot_table(index="pc_psia", columns="case", values="isp_amb_s")
        lines.append(piv.round(2).to_markdown())
        lines.append("\n")
    lines.append("## N2O/Ethanol interpretation demo\n")
    lines.append("Additional files `N2O_Ethanol_overexpansion_demo_pc150_mr4p65.csv`, `N2O_Ethanol_chemistry_mode_comparison_pc150_mr4p65.csv`, and `N2O_Ethanol_CEA_matched_vs_overexpanded.txt` document the sea-level/overexpansion and equilibrium/frozen-flow checks.\n")
    lines.append("## Important interpretation rule\n")
    lines.append("CEA/RocketCEA vacuum Isp and CEA's exit-pressure-matched Isp are not automatically sea-level Isp for an arbitrary nozzle. For sea-level sizing use the `isp_amb_s` column, which applies the ambient pressure correction and reports separation/overexpansion mode.\n")
    (outdir / "README_rocketcea_outputs.md").write_text("\n".join(lines))


def main() -> None:
    parser = argparse.ArgumentParser(description="Optimize RocketCEA ambient Isp for hopper propellant comparisons.")
    parser.add_argument("--ox", default="N2O", help="Oxidizer name, e.g. N2O, GOX, Peroxide85")
    parser.add_argument("--fuel", default="C2H5OH", help="Fuel name, e.g. C2H5OH, IPA, methanol")
    parser.add_argument("--pc", type=float, default=150.0, help="Chamber pressure in psia")
    parser.add_argument("--pamb", type=float, default=14.7, help="Ambient pressure in psia")
    parser.add_argument("--mr-min", type=float, default=3.0, help="Minimum O/F mass ratio")
    parser.add_argument("--mr-max", type=float, default=7.0, help="Maximum O/F mass ratio")
    parser.add_argument("--mr-step", type=float, default=0.05, help="O/F sweep step")
    parser.add_argument("--chemistry", default="equilibrium", choices=["equilibrium", "frozen", "frozen-throat"], help="CEA chemistry model")
    parser.add_argument("--thrust", type=float, default=None, help="Optional thrust in newtons for mdot/throat sizing")
    parser.add_argument("--case-name", default=None, help="Label for output files")
    parser.add_argument("--outdir", default="rocket_outputs", help="Output directory")
    parser.add_argument("--batch", action="store_true", help="Run default notebook propellant comparison batch")
    parser.add_argument("--pressure-sweep", action="store_true", help="Run chamber pressure sensitivity for finalist cases")
    args = parser.parse_args()

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    if args.batch:
        opts = []
        for case, ox, fuel, mr_min, mr_max in DEFAULT_CASES:
            _, opt = run_case(
                case=case,
                ox=ox,
                fuel=fuel,
                pc_psia=args.pc,
                pamb_psia=args.pamb,
                mr_min=mr_min,
                mr_max=mr_max,
                mr_step=args.mr_step,
                chemistry=args.chemistry,
                thrust_n=args.thrust,
                outdir=outdir,
            )
            opts.append(asdict(opt))
        summary = pd.DataFrame(opts).sort_values("isp_amb_s", ascending=False)
        summary.to_csv(outdir / "data" / "batch_optimum_summary.csv", index=False)
        plot_summary(summary, outdir)
        write_n2o_ethanol_interpretation_demo(outdir, args.pc, args.pamb)
        pc_sweep = None
        if args.pressure_sweep:
            finalist_cases = [c for c in DEFAULT_CASES if c[0] in {"N2O_Ethanol", "N2O_IPA", "GOX_Ethanol", "GOX_IPA"}]
            pc_sweep = run_pressure_sweep(finalist_cases, PC_SWEEP_DEFAULT, args.pamb, args.mr_step, args.chemistry, outdir)
        write_markdown_report(summary, pc_sweep, outdir)
        print(summary[["case", "mr", "eps", "isp_amb_s", "isp_vac_s", "cstar_m_s", "t_chamber_k", "mode"]].round(3).to_string(index=False))
    else:
        case = args.case_name or f"{normalize_name(args.ox)}_{normalize_name(args.fuel)}".replace("/", "_").replace(" ", "_")
        _, opt = run_case(
            case=case,
            ox=args.ox,
            fuel=args.fuel,
            pc_psia=args.pc,
            pamb_psia=args.pamb,
            mr_min=args.mr_min,
            mr_max=args.mr_max,
            mr_step=args.mr_step,
            chemistry=args.chemistry,
            thrust_n=args.thrust,
            outdir=outdir,
        )
        pd.DataFrame([asdict(opt)]).to_csv(outdir / "data" / f"{case}_optimum_summary.csv", index=False)
        print(pd.DataFrame([asdict(opt)]).round(4).to_string(index=False))


if __name__ == "__main__":
    main()
