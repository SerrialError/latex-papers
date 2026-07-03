# Cost and Sizing Model Notes

The notebook includes quantitative cost and sizing because a propellant decision without storage and sourcing numbers is not defensible. The numbers here are planning estimates, not final procurement data.

## What is calculated

`rocket_outputs/data/system_sizing_and_cost_summary.csv` calculates, for each surviving candidate:

- total propellant mass for 200 N and 400 N, 60 s burns,
- oxidizer mass,
- fuel mass,
- oxidizer storage volume including margin,
- fuel volume,
- propellant consumable cost range,
- oxidizer-architecture storage/feed hardware cost range.

`rocket_outputs/data/oxidizer_storage_hardware_map.csv` maps every corner of the
thrust/burn-time requirement envelope (200/400 N x 30/60 s) onto real, priced
storage vessels for both architectures:

- GOX: stored mass = burned mass / 0.78, from blowdown between 2265 psia
  service pressure and a 500 psia regulator floor, then the smallest public
  cylinder that holds it (80/125/250 cf steel, Gas Cylinder Source prices,
  tares from Gas Cylinder Source and Airgas listings).
- N2O: planning load = 1.25 x burned mass (retained vapor, pressure sag near
  depletion, fill tolerance), then the smallest motorsport bottle that holds it
  (10/15/20 lb, Nitrous Outlet prices and tares), manifolding 15 lb bottles
  when one is not enough.

`rocket_outputs/figures/architecture_campaign_cost.png` plots architecture
hardware plus N tests of consumables at the 200 N / 60 s reference (mid-band
lines, low/high shading) so the hardware-vs-consumables break-even is visible.

The equations are:

```text
m_total = T * t / (Isp_SL * g0)
m_ox = m_total * OF / (1 + OF)
m_fuel = m_total / (1 + OF)
V_liquid = m / rho
V_GOX = m * R_O2 * T_storage / P_storage
m_GOX_stored = m_ox / (1 - 500/2265)
m_N2O_loaded = 1.25 * m_ox
```

## Current planning assumptions

| Item | Planning price | Anchors |
|---|---:|---|
| N2O | $12-22/kg | FAR 56 lb racing-grade cylinder $292 (~$11.5/kg); SK Speed motorsport refills $8.49-9.79/lb ($18.7-21.6/kg). Higher one-off retail fills reported. Do not size around 8 g cream chargers. |
| GOX | $4-16/kg | Welding-trade refill/exchange guides ~$4-12/kg; FAR filled 125 cf cylinder $71.84 incl. tax/delivery (~$15/kg). Gas is not the main cost; the regulator and oxygen-clean hardware are. |
| LOX | $2-4/kg | FAR 230 L (~262 kg) $540 (~$2.1/kg); ~$200/180 L dewar quotes reported. Dewar deposit/rental and boiloff excluded. Screened out for the first article; kept for the reconsideration section. |
| IPA 99% | $8-12/kg | Public 99% IPA gallon pricing before shipping/hazmat. |
| Anhydrous ethanol | $13-30/kg | 200-proof or compatible denatured/tax-paid public anchors. Avoid 190-proof baseline. |
| 85% H2O2 | $20-60+/kg | Quote-only hazardous/specialty oxidizer placeholder. |

Architecture hardware bands (oxidizer storage/feed only, 200 N / 60 s sizing):

| Architecture | Band | Itemization |
|---|---:|---|
| GOX | $1,190-1,870 | 125 cf cylinder $194.50 + regulator $699-1,077 (Harris 3000-2500 / Victor SR4J-540, 16,600 scfh rated vs ~5,300 scfh needed at 200 N) + O2-clean valves/plumbing $250-450 allowance + CGA G-4.1 cleaning $50-150 allowance. |
| N2O | $725-1,175 | 15 lb bottle with high-flow valve $374.99 + run valve/solenoid and -AN plumbing $250-550 allowance + fill adapter and scale $100-250 allowance. |

Shared subsystems (fuel tank, fuel-side pressurant, commodity transducers,
harness, stand) are excluded from both columns because both architectures need
them. All anchor listings are cited in `references.bib` with access dates.

## Important limitations

1. Industrial gas prices are often not public and are location/account dependent. Before buying hardware, replace the planning ranges with local quotes.
2. The GOX tank-volume calculation assumes ideal-gas storage at 2200 psia and 293 K. This is good enough for architecture comparison, not final vessel sizing.
3. The N2O tank-volume calculation assumes saturated liquid near room temperature (750 kg/m3 warm-tank planning value; saturated-liquid density is roughly 745-790 kg/m3 over 20-25 C and falls steeply toward the critical point) and a 20% ullage/design margin. Actual fill limits depend on cylinder rating, valve, temperature envelope, and supplier rules.
4. The 0.78 GOX usable fraction and 1.25x N2O load factor are stated planning factors, not measured residuals; both must be replaced with data from the actual feed system.
5. Hardware cost ranges include only oxidizer storage/feed-specific items and use public bottle/cylinder/regulator anchors where available. They do not include the chamber, injector, cooling jacket, test stand, instrumentation, or avionics.
6. All high-pressure oxygen hardware must be oxygen-cleaned and compatible with oxygen service; N2O plumbing requires the same hydrocarbon-free discipline because contamination catalyzes decomposition.
