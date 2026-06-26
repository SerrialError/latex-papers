// ============================================================
// PROPELLANT SELECTION — ENGINEERING NOTEBOOK ENTRY
// VTVL Hopper Engine · storable pressure-fed liquid bipropellant
// ============================================================
#set page(
  paper: "us-letter",
  margin: (top: 1.1in, bottom: 1in, left: 1.15in, right: 1.0in),
  numbering: "1",
  header: context {
    set text(size: 8pt, fill: luma(120))
    [VTVL Hopper] + h(1fr) + [Engineering Notebook]
    line(length: 100%, stroke: 0.4pt + luma(160))
  },
  footer: context {
    line(length: 100%, stroke: 0.4pt + luma(160))
    set text(size: 8pt, fill: luma(120))
    h(1fr) + [Page ] + counter(page).display()
  },
)

#set text(size: 10.3pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

// ---- Callout box macros ----
#let warn-box(title, body) = block(
  width: 100%,
  fill: rgb("#fffbeb"),
  stroke: (left: 4pt + rgb("#d97706")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 10pt),
  radius: (right: 2pt),
  below: 1.2em,
)[
  #text(weight: "bold")[#sym.triangle.stroked.r #title]
  #v(3pt)
  #body
]

#let elim-box(body) = block(
  width: 100%,
  fill: rgb("#fef2f2"),
  stroke: (left: 4pt + rgb("#dc2626")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 10pt),
  radius: (right: 2pt),
  below: 1.2em,
)[
  #text(weight: "bold", fill: rgb("#b91c1c"))[Screen result: remove]
  #h(6pt) #body
]

#let finalist-box(body) = block(
  width: 100%,
  fill: rgb("#f0fdf4"),
  stroke: (left: 4pt + rgb("#16a34a")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 10pt),
  radius: (right: 2pt),
  below: 1.2em,
)[
  #text(weight: "bold", fill: rgb("#15803d"))[Decision]
  #h(6pt) #body
]

#let info-box(title, body) = block(
  width: 100%,
  fill: rgb("#eff6ff"),
  stroke: (left: 4pt + rgb("#2563eb")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 10pt),
  radius: (right: 2pt),
  below: 1.2em,
)[
  #text(weight: "bold")[#title]
  #v(3pt)
  #body
]

#let tfill(col, row) = {
  if row == 0 { rgb("#d1d5db") }
  else if calc.odd(row) { rgb("#f9fafb") }
  else { white }
}

#let compact-table(body) = text(size: 8.2pt)[#body]
#let micro-table(body) = text(size: 7.6pt)[#body]

// =============================================================
// TITLE BLOCK
// =============================================================

#v(0.5em)
#align(center)[
  #text(size: 18pt, weight: "bold")[VTVL Hopper Engineering Notebook]
]

#pagebreak()

#outline()

#pagebreak()

= Design Requirements

== Mission Objective

Design a throttleable, simple liquid bipropellant engine (and every subsystem required for it to work) for a minimal VTVL hopper. The engine exists to support a possible vehicle in the future inculding subsystems such as avionics, landing gear, and test instrumentation. The theoretical flight objective for the full vehicle to be designed later is controlled liftoff, hover or near-hover control authority, and safe landing.

== Requirement Classification

The requirements below are limited to items that must be true before the design is considered acceptable. Quantities that depend on vehicle mass convergence, tank selection, injector pressure drop, cooling margin, or throttle hardware are carried as sizing variables, not fixed requirements.

#figure(
  compact-table(
    table(
      columns: (1.2fr, 1.25fr, 3.4fr),
      fill: tfill,
      align: (left, center, left),
      inset: 5pt,
      [*Item*], [*Classification*], [*Requirement / design rule*],
      [Budget], [Hard], [Prototype propulsion hardware target: ≤ \$5,000 excluding propellant],
      [Architecture], [Hard], [No turbopumps.],
      [Cryogenics], [Hard], [No cryogenic propellant storage.],
      [Hazard class and Legality], [Hard], [Nothing specifically potentially hazardous, corrosive, toxic, or illegal.],
      [Material access], [Hard], [Primary wetted structural materials shall be readily obtainable aluminum alloy or stainless steel unless a later section gives a specific compatibility basis.],
      [Fluid connectors], [Hard], [Use pressure-rated commercial connector families only: AN/MS, CGA, Swagelok-compatible compression fittings, or equivalent documented hardware.],
      [Pressure safety], [Hard], [Pressure-wetted custom parts shall use burst factor of safety $gt.eq 4$ against MEOP. Purchased cylinders, valves, regulators, and fittings shall be used only within documented manufacturer ratings.],
      [Remote operation], [Hard], [All oxidizer and hot-fire operations shall be controllable from a safe remote location with positive propellant isolation before personnel approach.],
      [Throttle demonstration], [Test requirement], [The engine shall demonstrate repeatable operation at full thrust and at lower commanded setpoints before flight. The final throttle ratio is set after vehicle mass is known.],
      [Combustion stability], [Test requirement], [No sustained hard-start, chugging, buzz, or high-frequency instability is acceptable in qualification hot-fire data. Stability criteria are finalized in the injector and test sections.],
      [TVC interface], [Layout requirement], [Reserve a defined thrust-frame or gimbal interface. Cooling jacket and plumbing geometry shall not block later TVC integration.],
    )
  ),
  caption: [Design requirements for the first prototype phase.],
) <tbl-hard-reqs>

#pagebreak(weak: true)

#figure(
  compact-table(
    table(
      columns: (1.35fr, 1.15fr, 3.15fr),
      fill: tfill,
      align: (left, center, left),
      inset: 5pt,
      [*Quantity*], [*Status*], [*How it is used in this notebook*],
      [Nominal thrust], [Sizing variable], [Preliminary analyses may bracket 200-400 N, but the final value belongs in the engine sizing section after dry mass and propellant mass converge.],
      [Full-thrust liftoff margin], [Derived later], [After $m_0$ is known, require $T_"max" / (m_0 g_0) gt.eq 1.2$ minimum. Higher margin is useful only if it does not force unnecessary system scale-up.],
      [Minimum throttle], [Derived later], [After $m_0$ is known, require $T_"min" < m_0 g_0$ so the vehicle can command descent.],
      [Burn duration], [Design goal], [30 s minimum useful demonstration; 60 s stretch target. Propellant mass is computed after thrust and $I_"sp,SL"$ are selected.],
      [Chamber pressure], [Design variable], [Use 150 psia as the first static-fire analysis point and carry 200 psia as a performance-upgrade case if feed, cooling, and structure close.],
    )
  ),
  caption: [Sizing variables intentionally deferred to later notebook sections.],
) <tbl-sizing-vars>

= Propellant

== Define the Problem

Select a storable oxidizer/fuel pair for a small pressure-fed VTVL hopper. The selected pair must support repeatable throttling, safe ground testing, affordable consumables, realistic tankage, and a credible path to injector and cooling design. The decision is not "maximize $I_"sp"$"; it is "minimize total development risk while preserving enough performance for a minimal controlled hop."

Categories of Analysis
- Cost
- Storage mass and volume
- Stability/Predictability
- Development risk
- Performance
- Complexity

== Brainstorm Solutions

=== Hard Screens

These families fail a fixed constraint and are removed before detailed trade scoring.

#block[
#set text(size: 8.5pt)
#table(
  columns: (1.35fr, 2.7fr),
  fill: tfill,
  inset: 4pt,
  [*Candidate*], [*Reason for removal*],
  [LOX-based combinations], [They violate the no-cryogenic first-article constraint. A LOX engine is a valid later project, not the fastest safe path to this hopper.],
  [Hydrazine, MMH, UDMH, NTO], [The toxicity and legal burden are incompatible with the intended small-team, low-budget test program.],
  [RFNA/alcohol], [Corrosive oxidizer handling and compatibility burden are not acceptable for the preferred aluminum/stainless build.],
  [90%+ H₂O₂ / alcohol], [High-test peroxide is a specialized oxidizer with severe decomposition and contamination hazards; sourcing and handling dominate the project.],
)
]

=== Feasible Solutions

#block[
#set text(size: 8.3pt)
#table(
  columns: (1.45fr, 1.8fr, 2.3fr),
  fill: tfill,
  inset: 4pt,
  [*Candidate family*], [*Why it is worth considering*], [*Initial concerns to test*],
  [N₂O/alcohols], [Self-pressurizing oxidizer, compact liquid storage, non-cryogenic, active small-VTVL precedent.], [Two-phase injector flow, tank-temperature sensitivity, oxidizer pressure decay during burn.],
  [GOX/alcohols], [Single-phase oxidizer metering, stable regulator-fed pressure, easier analytical injector sizing.], [Large high-pressure gas volume, regulator cost, oxygen cleaning, tank mass.],
  [H₂O₂/alcohols], [Dense storable oxidizer; 85% peroxide performance is close to N₂O/alcohol in the sea-level ambient comparison.], [High-concentration peroxide sourcing, catalyst/ignition hardware, decomposition compatibility, hazardous transport.],
  [N₂O or GOX with methanol], [Methanol is cheap and historically common in rocket fuels.], [Toxicity and no computed performance advantage over IPA/ethanol.],
  [N₂O with gaseous fuels], [Some spacecraft and hybrid literature exists; gaseous fuels can simplify atomization.], [Poor fuel storage density and pressure-vessel mass for a 60 s ground hopper.],
  [N₂O/RP-1 or kerosene], [Dense fuel; common hydrocarbon fuel.], [Coking/soot and regenerative cooling complexity are poor matches for a small reusable engine.],
)
]

== Screen the Candidate Set

The table below is generated from the companion RocketCEA project at $P_c = 150 "psia"$, $P_"amb" = 14.7 "psia"$, and a sea-level-matched nozzle. Values are shifting-equilibrium RocketCEA/NASA CEA outputs @cea_hopper_runs_2026.

#block[
#set text(size: 8.0pt)
#table(
  columns: (1.25fr, 0.7fr, 0.65fr, 0.65fr, 0.72fr, 0.78fr, 1.75fr),
  fill: tfill,
  inset: 3.6pt,
  [*Candidate*], [*$I_"sp,SL"$*], [*O/F*], [*$epsilon$*], [*$T_c$ K*], [*$c^*$ m/s*], [*Screen result*],
  [GOX / IPA], [230.1 s], [1.65], [2.43], [3237], [1762], [Keep as GOX finalist. Best computed sea-level impulse, but GOX storage/hardware dominates.],
  [GOX / Ethanol], [225.6 s], [1.55], [2.45], [3187], [1727], [Keep as GOX finalist. Slightly lower computed $I_"sp"$ than GOX/IPA but stronger ignition/cooling evidence.],
  [GOX / Methanol], [221.3 s], [1.20], [2.46], [3074], [1693], [Remove. No advantage over GOX/ethanol or GOX/IPA, with worse toxicity.],
  [N₂O / IPA], [207.0 s], [5.10], [2.37], [3120], [1590], [Keep. Best N₂O/alcohol computed result and strongest VTVL heritage.],
  [N₂O / Ethanol], [204.8 s], [4.65], [2.38], [3064], [1573], [Keep. Strong static-fire literature and better coolant conductivity.],
  [85% H₂O₂ / IPA], [203.2 s], [5.65], [2.37], [2553], [1562], [Near miss only. Dense oxidizer but sourcing/catalyst/decomposition burden is high.],
  [N₂O / Methanol], [203.0 s], [3.50], [2.38], [2972], [1559], [Remove. No performance advantage and worse toxicity.],
  [85% H₂O₂ / Ethanol], [201.1 s], [5.00], [2.36], [2507], [1547], [Near miss only; same peroxide concerns.],
  [70% H₂O₂ / IPA], [186.9 s], [7.20], [2.31], [2184], [1441], [Remove. Low performance without solving peroxide access/catalyst risk.],
  [70% H₂O₂ / Ethanol], [185.0 s], [6.30], [2.30], [2139], [1426], [Remove. Low performance without solving peroxide access/catalyst risk.],
)
]

#figure(
  image("rocket_outputs/figures/batch_optimized_sea_level_isp.png", width: 92%),
  caption: [Generated RocketCEA comparison for optimized sea-level impulse at $P_c = 150 "psia"$, $P_"amb" = 14.7 "psia"$, shifting-equilibrium chemistry, and $P_e approx P_"amb"$ nozzle sizing @cea_hopper_runs_2026.],
) <fig-cea-batch-isp>

== Quantitative Sourcing and System Sizing

Pricing below is a planning model, not a purchase instruction. Industrial gas prices vary by region, account status, deposit/rental policy, and cylinder exchange rules. The useful engineering comparison is the order of magnitude: GOX consumables can be cheap, but the storage/regulator system is expensive and heavy; N₂O consumables are more expensive per kilogram, but the liquid storage is much smaller and the tank is also the pressure source.


#block[
#set text(size: 8.2pt)
#table(
  columns: (1.0fr, 1.65fr, 1.2fr, 2.1fr),
  fill: tfill,
  inset: 3.8pt,
  [*Material*], [*Practical acquisition route*], [*Planning price*], [*Design note*],
  [N₂O], [Local welding/specialty gas, motorsport, food-service gas supplier], [\$10--\$20/kg], [Cylinder exchange/refill pricing is local and quote-dependent. Use kg-scale cylinders, not small chargers.],
  [GOX], [Welding oxygen cylinder exchange or industrial gas supplier], [\$5--\$12/kg gas], [Gas is cheap; regulator, cylinder, CGA-540 hardware, and oxygen-clean plumbing dominate.],
  [99% IPA], [Hardware, janitorial, lab, or chemical supplier], [\$6--\$13/kg], [Widely available as a single high-purity product grade. 70% rubbing alcohol is not acceptable.],
  [Anhydrous ethanol], [Industrial/lab chemical supplier; denatured 200-proof acceptable if compatible], [\$20--\$45/kg], [More expensive and procurement-sensitive than IPA. 190-proof contains water and is not the baseline fuel.],
  [70--85% H₂O₂], [Specialty chemical supplier; high-concentration grades usually quote/hazmat], [\$20--\$60+/kg], [35% and higher peroxide is a regulated/special-handling chemical family in the United States; 70% is not ordinary pool-supply grade @federalregister_cfats2007.],
)
]


#block[
#set text(size: 8.0pt)
#table(
  columns: (1.15fr, 0.62fr, 0.72fr, 0.72fr, 0.72fr, 0.85fr, 0.95fr),
  fill: tfill,
  inset: 3.4pt,
  [*Case*], [*Thrust*], [*Total prop.*], [*Oxidizer*], [*Fuel*], [*Ox storage*], [*Propellant cost*],
  [N₂O / IPA], [200 N], [5.91 kg], [4.94 kg], [0.97 kg], [7.9 L], [\$55--\$111],
  [N₂O / IPA], [400 N], [11.82 kg], [9.88 kg], [1.94 kg], [15.8 L], [\$110--\$223],
  [N₂O / Ethanol], [200 N], [5.97 kg], [4.92 kg], [1.06 kg], [7.9 L], [\$70--\$146],
  [N₂O / Ethanol], [400 N], [11.95 kg], [9.83 kg], [2.11 kg], [15.7 L], [\$141--\$292],
  [GOX / IPA], [200 N], [5.32 kg], [3.31 kg], [2.01 kg], [17.5 L], [\$29--\$66],
  [GOX / IPA], [400 N], [10.64 kg], [6.62 kg], [4.01 kg], [34.9 L], [\$57--\$132],
  [GOX / Ethanol], [200 N], [5.42 kg], [3.30 kg], [2.13 kg], [17.4 L], [\$59--\$135],
  [GOX / Ethanol], [400 N], [10.85 kg], [6.59 kg], [4.25 kg], [34.8 L], [\$118--\$271],
)
]

The GOX volume in the table assumes storage near 2200 psia and 293 K using the ideal-gas law; the N₂O volume assumes saturated-liquid storage near room temperature with a 20% ullage/design margin. These are comparison numbers, not final pressure-vessel dimensions. Candidate pressure vessels still need manufacturer ratings, valve details, fill rules, and compatibility checks @cost_model_2026.

== Peroxide and Methanol Near-Misses

85% H₂O₂/alcohol is not dismissed because of sea-level performance alone. In the baseline comparison it is close to N₂O/alcohol: 85% H₂O₂/IPA gives 203.2 s, only 3.8 s below N₂O/IPA @cea_hopper_runs_2026. It is removed because the supporting architecture is worse for this project: high-concentration peroxide sourcing is specialized, material compatibility is narrow, decomposition contamination can be violent, and practical engines often need a catalyst or dedicated ignition/decomposition hardware @cervone2006 @federalregister_cfats2007.

70% H₂O₂ is not ordinary pool-supply grade in the sense needed here. Even if a 70% source is found, sea-level ambient-corrected performance is about 185--187 s at the baseline condition, while retaining the peroxide compatibility and handling burden @cea_hopper_runs_2026.

Methanol combinations are also removed. Methanol does not outperform the matching IPA/ethanol cases in the baseline comparison, and the CDC/NIOSH pocket guide lists skin absorption as an exposure route, OSHA PEL of 200 ppm, and symptoms including visual disturbance and optic nerve damage @cdc_methanol. That is a poor trade for no performance advantage.

== Analyze Survivors

=== N₂O / IPA

#figure(
  image("rocket_outputs/figures/N2O_IPA_of_isp_and_oxidizer_mass.png", width: 100%),
  caption: [Individual O/F curve. The dashed curve in each panel is oxidizer mass required for a 200 N, 60 s burn.],
) <fig-of-OF-curve-nitrous-oxide-ipa>


N₂O/IPA survives because it best matches the actual hopper mission. The sea-level ambient-corrected computed performance is $I_"sp,SL" = 207.0 "s"$ at O/F = 5.10 and $epsilon = 2.37$ @cea_hopper_runs_2026. That is not high compared with vacuum-optimized numbers, but it is enough for a minimal hopper and avoids the hardware burden of high-pressure GOX storage.

The most important external evidence is direct VTVL heritage. Gruyère Space Program's Colibri vehicle uses an N₂O/IPA bipropellant engine and is documented as a 2.45 m VTVL demonstrator with up to 1.25 kN thrust @kistler2024. European Spaceflight reported the October 18, 2024 free flight to 105 m altitude, 30 m lateral translation, and 60 s duration @europeanspaceflight2024. That is the closest public analog to this project.

#finalist-box[*Selected baseline.* The main risk is not performance; it is injector/feed calibration for flashing N₂O. The advantage is compact oxidizer storage, no oxidizer regulator, cheap fuel, and direct small-VTVL precedent.]

=== N₂O / Ethanol

#figure(
  image("rocket_outputs/figures/N2O_Ethanol_of_isp_and_oxidizer_mass.png", width: 100%),
  caption: [Individual O/F curve. The dashed curve in each panel is oxidizer mass required for a 200 N, 60 s burn.],
) <fig-of-OF-curve-nitrous-oxide-etgabik>

N₂O/ethanol is the strongest backup because it has broader academic static-fire literature and better coolant thermal conductivity. The sea-level ambient-corrected computed performance is $I_"sp,SL" = 204.8 "s"$ at O/F = 4.65 and $epsilon = 2.38$ @cea_hopper_runs_2026. The difference from N₂O/IPA is only 2.2 s in the baseline comparison, so it should not drive the decision.

Ethanol has slightly lower specific heat but higher thermal conductivity than IPA at room temperature; the coolant trade is therefore not one-sided. IPA has slightly better bulk heat capacity, while ethanol has better film-side conduction margin @crc2023.

#finalist-box[*Backup finalist.* Use ethanol if the design is intentionally aligned with N₂O/ethanol literature or if regen-cooling margin dominates fuel procurement convenience.]

== N₂O Architecture Risk: Feed, Injector, and Environment

N₂O is stored as a saturated liquid at its own vapor pressure. Resonac lists high-purity N₂O vapor pressure as 5.24 MPa at 20°C and gives a critical temperature of 36.41°C with critical pressure 7.24 MPa @resonac_n2o. This enables self-pressurization, but it also means feed pressure changes strongly with tank temperature.

#warn-box("Las Vegas design-basis implication")[
A N₂O tank in direct summer sun can approach or exceed the 36.4°C critical temperature. The baseline control map should be built around measured tank temperature and pressure, and the pressure-vessel MEOP check should use the highest credible tank temperature, not just nominal room temperature. Testing in shade or morning conditions is not a convenience; it is part of keeping the feed model inside the calibrated regime.
]

When saturated liquid N₂O accelerates through valves and injector passages, pressure reduction can initiate flashing before the chamber. The standard single-phase incompressible equation is therefore only a bounding model:

$ dot(m) = C_d A sqrt(2 rho Delta P) $

N₂O injector design should bracket the flow with SPI and HEM and then use a non-equilibrium model such as Dyer/NHNE for the design estimate. Published work on self-pressurizing propellant flow and N₂O injectors supports this SPI/HEM/NHNE framing @dyer2007 @deisenroth2019 @solomon2011 @zimmermann2022.

#block[
#set text(size: 8.2pt)
#table(
  columns: (0.9fr, 1.7fr, 1.4fr, 1.5fr),
  fill: tfill,
  inset: 3.6pt,
  [*Model*], [*Assumption*], [*Expected bias*], [*Use in this project*],
  [SPI], [Single-phase incompressible liquid.], [Often overpredicts flashing N₂O flow.], [Upper-bound geometry check only.],
  [HEM], [Two-phase thermodynamic equilibrium.], [Often lower-bound for short injector residence times.], [Lower-bound flow check.],
  [Dyer / NHNE], [Non-homogeneous, non-equilibrium interpolation between SPI and HEM using residence/bubble-growth times.], [Best practical pre-test estimate for short rocket-injector passages.], [Design-reference model, then calibrate by hot fire.],
  [Empirical map], [Valve command, tank state, and chamber response fitted from tests.], [Most reliable inside tested range.], [Required for throttle control.],
)
]

The AEL N₂O/IPA throttle-control work is especially relevant because it reports closed-loop throttling on a small N₂O/IPA VTVL thruster, where flashing behavior made oxidizer pressure-drop behavior more thermodynamic than a simple hydraulic orifice prediction @waugh2018. For this project, the practical implication is simple: N₂O injector and throttle design cannot be fully closed analytically. The engine needs calibration firings at multiple tank temperatures and throttle settings before flight.

=== GOX / Ethanol
#figure(
  image("rocket_outputs/figures/GOX_Ethanol_of_isp_and_oxidizer_mass.png", width: 100%),
  caption: [Individual O/F curve. The dashed curve in each panel is oxidizer mass required for a 200 N, 60 s burn.],
) <fig-of-OF-curve-GOX-ethanol>

GOX/ethanol survives as the best alternative if the N₂O two-phase injector problem becomes unacceptable. The sea-level ambient-corrected computed performance is $I_"sp,SL" = 225.6 "s"$ at O/F = 1.55 and $epsilon = 2.45$ @cea_hopper_runs_2026. It gives simpler single-phase oxidizer metering and stable regulator-fed pressure, but the system-level cost is high.

A NASA ignition characterization program tested GOX/ethanol at 150 psia and O/F = 1.8, making this the best-documented GOX/alcohol reference point near the baseline chamber pressure @nasa1984. Oxygen-side hardware must be oxygen-cleaned and kept free of hydrocarbon contamination; the oxygen-cleaning and material-control burden is real, not paperwork @cga_g41.

#finalist-box[*Engineering-risk alternate.* Choose GOX/ethanol only if avoiding N₂O two-phase modeling is worth the larger gas storage, regulator cost, and oxygen-clean hardware process.]

=== GOX / IPA
#figure(
  image("rocket_outputs/figures/GOX_IPA_of_isp_and_oxidizer_mass.png", width: 100%),
  caption: [Individual O/F curve. The dashed curve in each panel is oxidizer mass required for a 200 N, 60 s burn.],
) <fig-of-OF-curve-GOX-ipa>

GOX/IPA has the best sea-level ambient-corrected computed performance in this set: $I_"sp,SL" = 230.1 "s"$ at O/F = 1.65 and $epsilon = 2.43$ @cea_hopper_runs_2026. The fuel is cheaper than anhydrous ethanol, but the fuel cost does not drive the GOX architecture. The expensive pieces are the oxidizer cylinder or custom gas vessel, high-flow oxygen regulator, CGA-540 adapters, oxygen-compatible valves, cleaning, and high-pressure fittings.

#finalist-box[*Valid but not baseline.* GOX/IPA is a credible GOX alternate. It is not selected over GOX/ethanol because the main GOX advantage is single-phase oxygen metering, and GOX/ethanol has stronger nearby ignition-validation evidence.]

#figure(
  image("rocket_outputs/figures/pressure_sensitivity.png", width: 100%),
  caption: [Pressure sensitivity for the four surviving alcohol finalists @cea_hopper_runs_2026.],
) <fig-pressure-sensitivity>

== Select Best Solution

The high GOX performance and simple injector are real, but the gas storage and oxygen hardware penalty are large. The high peroxide density is real, but sourcing and decomposition risk dominate.

#finalist-box[*Baseline propellant selection: N₂O / IPA.* N₂O/IPA has the strongest match to the mission because it combines compact self-pressurizing oxidizer storage, cheap and accessible fuel, and the most relevant small-VTVL flight precedent. The design must explicitly budget time for N₂O two-phase injector modeling and hot-fire calibration.]

*N₂O/ethanol* remains the backup fuel choice if the project chooses to align with N₂O/ethanol static-fire literature or needs ethanol's higher thermal conductivity for cooling margin. *GOX/ethanol* remains the alternate oxidizer architecture if two-phase N₂O flow becomes the dominant unacceptable risk. *GOX/IPA* is credible but not the reference GOX fuel because the fuel choice does not solve the GOX storage/regulator problem.

= Engine Sizing

= Nozzle Design

= Injector Design

= Feed System Design

= Cooling Analysis

= Structural Analysis

= CAD Design

= Simulation

#bibliography(
  "references.bib",
  style: "ieee",
)
