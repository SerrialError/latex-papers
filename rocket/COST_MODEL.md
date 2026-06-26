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
- rough storage-hardware cost range.

The equations are:

```text
m_total = T * t / (Isp_SL * g0)
m_ox = m_total * OF / (1 + OF)
m_fuel = m_total / (1 + OF)
V_liquid = m / rho
V_GOX = m * R_O2 * T_storage / P_storage
```

## Current planning assumptions

| Item | Planning price | Notes |
|---|---:|---|
| N2O | $10-20/kg | Local refill/cylinder exchange pricing varies. Do not size around 8 g cream chargers. |
| GOX | $5-12/kg gas | Gas refill is not the main cost. Cylinder/regulator/cleaning hardware is. |
| IPA 99% | $6-13/kg | Based on gallon/5-gallon retail/industrial planning ranges. |
| Anhydrous ethanol | $20-45/kg | 200-proof or compatible denatured ethanol. Avoid 190-proof baseline. |
| 85% H2O2 | $20-60+/kg | Quote-only hazardous/specialty oxidizer placeholder. |

## Important limitations

1. Industrial gas prices are often not public and are location/account dependent. Before buying hardware, replace the planning ranges with local quotes.
2. The GOX tank-volume calculation assumes ideal-gas storage at 2200 psia and 293 K. This is good enough for architecture comparison, not final vessel sizing.
3. The N2O tank-volume calculation assumes saturated liquid near room temperature and a 20% ullage/design margin. Actual fill limits depend on cylinder rating, valve, temperature envelope, and supplier rules.
4. Hardware cost ranges include only oxidizer storage/feed-specific items. They do not include the chamber, injector, cooling jacket, test stand, instrumentation, or avionics.
5. All high-pressure oxygen hardware must be oxygen-cleaned and compatible with oxygen service.
