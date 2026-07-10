#!/usr/bin/env python3
"""Generate injector design-point tables and figures for notebook.typ.

Consumes batch_optimum_summary.csv (N2O/IPA baseline). Implements engineering
SPI / approximate-HEM / Dyer-NHNE orifice brackets for planning only — not a
substitute for cold-flow calibration. See notebook Injector Design section and
references.bib (Huzel, SP-8089, Dyer, Solomon, Waxman, Waugh).
"""
from __future__ import annotations

import math
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent
OUT_DATA = ROOT / "rocket_outputs" / "data"
OUT_FIG = ROOT / "rocket_outputs" / "figures"

G0 = 9.80665
PSIA_TO_PA = 6894.757293168361

# Planning densities (notebook cites NIST/CRC/Resonac planning values).
RHO_IPA_KG_M3 = 786.0          # ~20 C anhydrous IPA
RHO_N2O_WARM_KG_M3 = 750.0     # warm saturated liquid planning
RHO_N2O_COOL_KG_M3 = 900.0     # cooler tank planning bound

CD_FUEL = 0.70                 # preliminary sharp-edge orifice Cd; water-flow later
CD_OX = 0.65                   # slightly lower planning Cd for short ox orifices

# Approximate HEM mass-flow factor relative to SPI for saturated short-orifice N2O.
# Planning band only: short-orifice N2O data in Waxman-class work fall between SPI
# and deep-HEM limits; 0.35 is a mid-lower engineering bracket pending cold-flow.
HEM_FACTOR = 0.35


def spi_mdot(cd: float, area_m2: float, rho: float, dp_pa: float) -> float:
    return cd * area_m2 * math.sqrt(2.0 * rho * dp_pa)


def spi_area(cd: float, mdot: float, rho: float, dp_pa: float) -> float:
    return mdot / (cd * math.sqrt(2.0 * rho * dp_pa))


def hem_mdot_approx(cd: float, area_m2: float, rho: float, dp_pa: float) -> float:
    return HEM_FACTOR * spi_mdot(cd, area_m2, rho, dp_pa)


def dyer_mdot(cd: float, area_m2: float, rho: float, dp_pa: float, k: float = 1.0) -> float:
    """Dyer/NHNE-style blend: (m_SPI + k*m_HEM)/(1+k). k~1 saturated planning default."""
    m_s = spi_mdot(cd, area_m2, rho, dp_pa)
    m_h = hem_mdot_approx(cd, area_m2, rho, dp_pa)
    return (m_s + k * m_h) / (1.0 + k)


def dyer_area(cd: float, mdot: float, rho: float, dp_pa: float, k: float = 1.0) -> float:
    """Invert Dyer blend for required area at target mdot."""
    # m = A * cd * sqrt(2 rho dP) * (1 + k*HEM_FACTOR)/(1+k)
    factor = (1.0 + k * HEM_FACTOR) / (1.0 + k)
    return mdot / (cd * math.sqrt(2.0 * rho * dp_pa) * factor)


def load_n2o_ipa_row() -> pd.Series:
    path = OUT_DATA / "batch_optimum_summary.csv"
    df = pd.read_csv(path)
    row = df.loc[df["case"] == "N2O_IPA"].iloc[0]
    return row


def design_point_table(row: pd.Series) -> pd.DataFrame:
    records = []
    for thrust in (200.0, 400.0):
        scale = thrust / float(row["thrust_n"])
        mdot = float(row["mdot_kg_s"]) * scale
        mr = float(row["mr"])
        m_ox = mdot * mr / (1.0 + mr)
        m_f = mdot / (1.0 + mr)
        records.append(
            {
                "thrust_N": thrust,
                "pc_psia": float(row["pc_psia"]),
                "of_ratio": mr,
                "isp_sl_s": float(row["isp_amb_s"]),
                "mdot_total_kg_s": mdot,
                "mdot_ox_kg_s": m_ox,
                "mdot_fuel_kg_s": m_f,
                "ox_mass_fraction": m_ox / mdot,
                "throat_diameter_mm": float(row["throat_diameter_mm"]) * math.sqrt(scale),
                "throat_area_m2": float(row["throat_area_m2"]) * scale,
                "rho_ipa_kg_m3": RHO_IPA_KG_M3,
                "rho_n2o_warm_kg_m3": RHO_N2O_WARM_KG_M3,
                "rho_n2o_cool_kg_m3": RHO_N2O_COOL_KG_M3,
                "vol_flow_ox_warm_L_s": 1e3 * m_ox / RHO_N2O_WARM_KG_M3,
                "vol_flow_fuel_L_s": 1e3 * m_f / RHO_IPA_KG_M3,
                "vol_ratio_ox_to_fuel_warm": (m_ox / RHO_N2O_WARM_KG_M3)
                / (m_f / RHO_IPA_KG_M3),
            }
        )
    return pd.DataFrame(records)


def fuel_orifice_table(m_fuel: float) -> pd.DataFrame:
    rows = []
    for dp_frac in (0.15, 0.20, 0.25):
        dp_psia = 150.0 * dp_frac
        dp_pa = dp_psia * PSIA_TO_PA
        a_tot = spi_area(CD_FUEL, m_fuel, RHO_IPA_KG_M3, dp_pa)
        for n in (4, 6, 8, 10, 12):
            a_i = a_tot / n
            d_mm = 2e3 * math.sqrt(a_i / math.pi)
            rows.append(
                {
                    "propellant": "IPA",
                    "model": "SPI",
                    "dp_frac_of_pc": dp_frac,
                    "dp_psia": dp_psia,
                    "cd": CD_FUEL,
                    "mdot_kg_s": m_fuel,
                    "total_area_mm2": a_tot * 1e6,
                    "n_orifices": n,
                    "orifice_diameter_mm": d_mm,
                    "L_over_d_target": 3.0,
                    "orifice_length_mm": 3.0 * d_mm,
                }
            )
    return pd.DataFrame(rows)


def n2o_bracket_table(m_ox: float) -> pd.DataFrame:
    rows = []
    for rho_name, rho in (
        ("warm_750", RHO_N2O_WARM_KG_M3),
        ("cool_900", RHO_N2O_COOL_KG_M3),
    ):
        for dp_frac in (0.10, 0.15, 0.20, 0.25, 0.30):
            dp_psia = 150.0 * dp_frac
            dp_pa = dp_psia * PSIA_TO_PA
            a_spi = spi_area(CD_OX, m_ox, rho, dp_pa)
            a_hem = spi_area(CD_OX, m_ox / HEM_FACTOR, rho, dp_pa)  # larger area for lower m/A
            # invert: for HEM m = HEM_FACTOR * SPI(A) => A_hem = A_spi / HEM_FACTOR
            a_hem = a_spi / HEM_FACTOR
            a_dyer = dyer_area(CD_OX, m_ox, rho, dp_pa, k=1.0)
            for model, a_tot in (
                ("SPI_upper_mdot_for_fixed_A", a_spi),
                ("Dyer_NHNE_k1_design", a_dyer),
                ("HEM_lower_mdot_for_fixed_A", a_hem),
            ):
                # clarify: areas above are required total area to pass m_ox under each model
                n = 8
                a_i = a_tot / n
                d_mm = 2e3 * math.sqrt(a_i / math.pi)
                # flows if that area were used under each model (consistency check)
                m_spi = spi_mdot(CD_OX, a_tot, rho, dp_pa)
                m_hem = hem_mdot_approx(CD_OX, a_tot, rho, dp_pa)
                m_dyer = dyer_mdot(CD_OX, a_tot, rho, dp_pa, k=1.0)
                rows.append(
                    {
                        "propellant": "N2O",
                        "density_case": rho_name,
                        "rho_kg_m3": rho,
                        "dp_frac_of_pc": dp_frac,
                        "dp_psia": dp_psia,
                        "cd": CD_OX,
                        "target_mdot_kg_s": m_ox,
                        "sizing_model": model,
                        "required_total_area_mm2": a_tot * 1e6,
                        "example_n_orifices": n,
                        "example_orifice_diameter_mm": d_mm,
                        "mdot_if_SPI_kg_s": m_spi,
                        "mdot_if_Dyer_k1_kg_s": m_dyer,
                        "mdot_if_HEM_approx_kg_s": m_hem,
                        "hem_factor_used": HEM_FACTOR,
                        "dyer_k": 1.0,
                    }
                )
    return pd.DataFrame(rows)


def pattern_trade_table() -> pd.DataFrame:
    """Qualitative scores 1-5; weights documented in notebook. Not a substitute for judgment."""
    # criteria: mixing, N2O_two_phase_tolerance, throttle_fit, fab_simplicity, unequal_OF_ok, stability_heritage
    rows = [
        ("Unlike-doublet", 4.5, 2.5, 3.0, 3.5, 2.0, 3.5),
        ("Like-doublet", 4.0, 3.5, 3.0, 3.5, 4.5, 4.0),
        ("Fixed pintle", 3.5, 3.0, 4.5, 3.0, 4.0, 4.5),
        ("Triplet F-O-F", 4.0, 2.5, 3.0, 2.5, 3.0, 3.5),
    ]
    cols = [
        "archetype",
        "mixing",
        "n2o_two_phase",
        "throttle_fit",
        "fab_simplicity",
        "unequal_OF_ok",
        "stability_heritage",
    ]
    df = pd.DataFrame(rows, columns=cols)
    weights = {
        "mixing": 0.15,
        "n2o_two_phase": 0.25,
        "throttle_fit": 0.15,
        "fab_simplicity": 0.20,
        "unequal_OF_ok": 0.15,
        "stability_heritage": 0.10,
    }
    df["weighted_score"] = sum(df[c] * w for c, w in weights.items())
    df = df.sort_values("weighted_score", ascending=False)
    return df


def plot_fuel_orifices(fuel_df: pd.DataFrame, out: Path) -> None:
    fig, ax = plt.subplots(figsize=(7.2, 4.2))
    sub = fuel_df[fuel_df["dp_frac_of_pc"] == 0.20]
    ax.plot(sub["n_orifices"], sub["orifice_diameter_mm"], "o-", color="#1d4ed8", lw=2)
    ax.set_xlabel("Number of IPA orifices")
    ax.set_ylabel("Orifice diameter (mm)")
    ax.set_title("IPA SPI orifice diameter vs count (200 N, ΔP = 0.20 Pc, Cd = 0.70)")
    ax.grid(True, alpha=0.3)
    ax.axhline(0.5, color="#b45309", ls="--", lw=1, label="0.5 mm shop-practical floor (project)")
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(out, dpi=150)
    plt.close(fig)


def plot_n2o_brackets(n2o_df: pd.DataFrame, out: Path) -> None:
    fig, ax = plt.subplots(figsize=(7.5, 4.4))
    sub = n2o_df[
        (n2o_df["density_case"] == "warm_750")
        & (n2o_df["sizing_model"] == "Dyer_NHNE_k1_design")
    ].drop_duplicates(subset=["dp_frac_of_pc"])
    # For each dp, plot required areas for three models at warm density
    for model, color, label in (
        ("SPI_upper_mdot_for_fixed_A", "#16a34a", "SPI (under-sizes A if flashing)"),
        ("Dyer_NHNE_k1_design", "#2563eb", "Dyer/NHNE k=1 design"),
        ("HEM_lower_mdot_for_fixed_A", "#dc2626", "HEM approx (larger A)"),
    ):
        s = n2o_df[
            (n2o_df["density_case"] == "warm_750") & (n2o_df["sizing_model"] == model)
        ].drop_duplicates(subset=["dp_frac_of_pc"]).sort_values("dp_frac_of_pc")
        ax.plot(
            s["dp_frac_of_pc"] * 100,
            s["required_total_area_mm2"],
            "o-",
            color=color,
            lw=2,
            label=label,
        )
    ax.set_xlabel("Injector ΔP as % of Pc")
    ax.set_ylabel("Required total N₂O orifice area (mm²)")
    ax.set_title("N₂O orifice area brackets at 200 N warm-tank density (planning models)")
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(out, dpi=150)
    plt.close(fig)


def plot_pattern_scores(trade: pd.DataFrame, out: Path) -> None:
    fig, ax = plt.subplots(figsize=(7.2, 4.0))
    t = trade.sort_values("weighted_score")
    ax.barh(t["archetype"], t["weighted_score"], color="#0f766e")
    ax.set_xlabel("Weighted score (see notebook weights)")
    ax.set_title("Injector archetype trade scores (survivors only)")
    ax.set_xlim(0, 5)
    ax.grid(True, axis="x", alpha=0.3)
    fig.tight_layout()
    fig.savefig(out, dpi=150)
    plt.close(fig)


def main() -> None:
    OUT_DATA.mkdir(parents=True, exist_ok=True)
    OUT_FIG.mkdir(parents=True, exist_ok=True)

    row = load_n2o_ipa_row()
    dp = design_point_table(row)
    dp.to_csv(OUT_DATA / "injector_design_point.csv", index=False)

    m_fuel = float(dp.loc[dp["thrust_N"] == 200.0, "mdot_fuel_kg_s"].iloc[0])
    m_ox = float(dp.loc[dp["thrust_N"] == 200.0, "mdot_ox_kg_s"].iloc[0])

    fuel = fuel_orifice_table(m_fuel)
    fuel.to_csv(OUT_DATA / "injector_orifice_sizing_fuel.csv", index=False)

    n2o = n2o_bracket_table(m_ox)
    n2o.to_csv(OUT_DATA / "injector_orifice_sizing_n2o_brackets.csv", index=False)

    trade = pattern_trade_table()
    trade.to_csv(OUT_DATA / "injector_pattern_trade.csv", index=False)

    # Spec sheet for like-doublet baseline at Dyer ox + SPI fuel, dP=0.20 Pc
    dp_pa = 0.20 * 150.0 * PSIA_TO_PA
    a_fuel = spi_area(CD_FUEL, m_fuel, RHO_IPA_KG_M3, dp_pa)
    a_ox = dyer_area(CD_OX, m_ox, RHO_N2O_WARM_KG_M3, dp_pa, k=1.0)
    n_f_pairs = 2  # 2 like-doublet fuel pairs => 4 fuel orifices (~0.6 mm class)
    n_o_pairs = 6  # 6 like-doublet ox pairs => 12 ox orifices
    spec = pd.DataFrame(
        [
            {
                "baseline_archetype": "like_doublet",
                "thrust_N": 200.0,
                "pc_psia": 150.0,
                "target_dp_frac_pc": 0.20,
                "target_dp_psia": 30.0,
                "mdot_fuel_kg_s": m_fuel,
                "mdot_ox_kg_s": m_ox,
                "fuel_model": "SPI",
                "ox_model": "Dyer_NHNE_k1",
                "fuel_total_area_mm2": a_fuel * 1e6,
                "ox_total_area_mm2": a_ox * 1e6,
                "fuel_n_orifices": 2 * n_f_pairs,
                "ox_n_orifices": 2 * n_o_pairs,
                "fuel_n_like_doublet_pairs": n_f_pairs,
                "ox_n_like_doublet_pairs": n_o_pairs,
                "fuel_orifice_diameter_mm": 2e3 * math.sqrt((a_fuel / (2 * n_f_pairs)) / math.pi),
                "ox_orifice_diameter_mm": 2e3 * math.sqrt((a_ox / (2 * n_o_pairs)) / math.pi),
                "impingement_angle_deg": 60.0,
                "L_over_d_target": 3.0,
                "cd_fuel_planning": CD_FUEL,
                "cd_ox_planning": CD_OX,
                "status": "preliminary_pending_cold_flow",
            }
        ]
    )
    spec.to_csv(OUT_DATA / "injector_baseline_spec_preliminary.csv", index=False)

    plot_fuel_orifices(fuel, OUT_FIG / "injector_fuel_orifice_diameter_vs_count.png")
    plot_n2o_brackets(n2o, OUT_FIG / "injector_n2o_area_model_brackets.png")
    plot_pattern_scores(trade, OUT_FIG / "injector_archetype_trade_scores.png")

    print("Wrote injector design assets to rocket_outputs/")
    print(spec.to_string(index=False))


if __name__ == "__main__":
    main()
