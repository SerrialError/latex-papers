// ============================================================
// VTVL HOPPER ENGINE - REQUIREMENTS AND PROPELLANT SELECTION
// Preliminary non-cryogenic pressure-fed liquid engine study
// ============================================================
#set page(
  paper: "us-letter",
  margin: (top: 1.0in, bottom: 0.95in, left: 1.0in, right: 0.9in),
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

#set text(size: 10.2pt)
#set par(justify: true, leading: 0.63em)
#set heading(numbering: "1.1")
#set list(indent: 1.15em, body-indent: 0.55em)
#set enum(indent: 1.15em, body-indent: 0.55em)

// Allow long table figures to break instead of colliding with later text.
#show figure: set block(breakable: true)
#show figure.where(kind: table): set figure.caption(position: top)

// ---- Callout box macros ----
#let warn-box(title, body) = block(
  width: 100%,
  fill: rgb("#fffbeb"),
  stroke: (left: 4pt + rgb("#d97706")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 10pt),
  radius: (right: 2pt),
  below: 1.0em,
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
  below: 1.0em,
)[
  #text(weight: "bold", fill: rgb("#b91c1c"))[Verdict: Eliminated]
  #h(6pt) #body
]

#let finalist-box(body) = block(
  width: 100%,
  fill: rgb("#f0fdf4"),
  stroke: (left: 4pt + rgb("#16a34a")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 10pt),
  radius: (right: 2pt),
  below: 1.0em,
)[
  #text(weight: "bold", fill: rgb("#15803d"))[Verdict: Finalist]
  #h(6pt) #body
]

#let info-box(title, body) = block(
  width: 100%,
  fill: rgb("#eff6ff"),
  stroke: (left: 4pt + rgb("#2563eb")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 10pt),
  radius: (right: 2pt),
  below: 1.0em,
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
#align(center)[#text(size: 18pt, weight: "bold")[VTVL Hopper Engineering Notebook]]
#align(center)[#text(size: 11pt)[Requirements and Propellant Selection]]

#v(0.5em)
#line(length: 100%, stroke: 1.3pt)
#v(0.8em)

= Design Requirements <requirements>

== Mission Objective

Design a throttleable, pressure-fed liquid bipropellant engine for a minimal VTVL hopper. The vehicle exists to support the engine, tanks, avionics, plumbing, landing gear, and test instrumentation. There is no payload requirement and no altitude requirement at this stage. The first flight objective is controlled liftoff, hover or near-hover control authority, and safe landing.

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
      [Budget], [Hard], [Prototype propulsion hardware target: ≤ \$5,000 excluding propellant, shop tooling, and instrumentation already owned.],
      [Architecture], [Hard], [Pressure-fed liquid bipropellant. No turbopumps.],
      [Cryogenics], [Hard], [No cryogenic propellant storage for the first prototype.],
      [Hazard class], [Hard], [No hydrazine-family fuels, NTO, RFNA, or similarly high-toxicity/high-corrosion propellants for this build.],
      [Material access], [Hard], [Primary wetted structural materials shall be readily obtainable aluminum alloy or stainless steel unless a later section gives a specific compatibility basis.],
      [Fluid connectors], [Hard], [Use pressure-rated commercial connector families only: AN/MS, CGA, Swagelok-compatible compression fittings, or equivalent documented hardware. No custom fluid connector geometry.],
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
      [Specific impulse], [Analysis output], [Report $I_"sp,SL"$, $I_"sp,vac"$, $P_c$, $P_"amb"$, $P_e$, $epsilon$, O/F, and chemistry mode for every CEA/RocketCEA value. No hard $I_"sp"$ floor is set in the requirements section.],
      [Nominal thrust], [Sizing variable], [Preliminary analyses may bracket 200-400 N, but the final value belongs in the engine sizing section after dry mass and propellant mass converge.],
      [Full-thrust liftoff margin], [Derived later], [After $m_0$ is known, require $T_"max" / (m_0 g_0) gt.eq 1.2$ minimum. Higher margin is useful only if it does not force unnecessary system scale-up.],
      [Minimum throttle], [Derived later], [After $m_0$ is known, require $T_"min" < m_0 g_0$ so the vehicle can command descent.],
      [Burn duration], [Design goal], [30 s minimum useful demonstration; 60 s stretch target. Propellant mass is computed after thrust and $I_"sp,SL"$ are selected.],
      [Chamber pressure], [Design variable], [Use 150 psia as the first static-fire analysis point and carry 200 psia as a performance-upgrade case if feed, cooling, and structure close.],
      [Engine dry mass], [Design goal], [Engine assembly target $lt.eq 2.5 "kg"$ for chamber, nozzle, injector, and cooling jacket.],
    )
  ),
  caption: [Sizing variables intentionally deferred to later notebook sections.],
) <tbl-sizing-vars>

== Chamber Pressure Design Basis

The baseline chamber-pressure range is $P_c = 150-200 "psia"$. A lower chamber pressure reduces chamber stress, heat flux, valve pressure rating, injector pressure drop, and early test-stand load. A higher chamber pressure improves nozzle pressure ratio and sea-level impulse. For this hopper, the first static-fire baseline is $P_c = 150 "psia"$; $P_c = 200 "psia"$ is retained as a later upgrade point, not assumed from the start.

The generated RocketCEA pressure sweep in #link("rocket_outputs/data/pressure_sweep_summary.csv")[rocket_outputs/data/pressure_sweep_summary.csv] gives the following sea-level-optimized performance trend @cea_hopper_runs_2026. Each row re-optimizes O/F and $epsilon$ so that $P_e approx P_"amb"$ at $P_"amb" = 14.7 "psia"$.

#figure(
  compact-table(
    table(
      columns: (1.45fr, 1fr, 1fr, 1fr),
      fill: tfill,
      align: (left, center, center, center),
      inset: 5pt,
      [*Propellant*], [*$I_"sp,SL"$ at 150 psia*], [*$I_"sp,SL"$ at 200 psia*], [*Gain*],
      [N₂O / Ethanol], [$204.8 "s"$], [$215.5 "s"$], [$+10.6 "s"$],
      [N₂O / IPA], [$207.0 "s"$], [$217.7 "s"$], [$+10.7 "s"$],
      [GOX / Ethanol], [$225.6 "s"$], [$237.8 "s"$], [$+12.2 "s"$],
      [GOX / IPA], [$230.1 "s"$], [$242.4 "s"$], [$+12.4 "s"$],
    )
  ),
  caption: [Sea-level pressure sensitivity for finalist propellants. Values are generated by the included RocketCEA script and should be regenerated if the propellant model, ambient pressure, or chemistry mode changes.],
) <tbl-pc-sensitivity>

= Propellant <propellant>

== Problem

Select a practical non-cryogenic oxidizer/fuel pair for a low-altitude throttleable hopper. The selected pair should minimize development risk and stored-energy complexity while still keeping propellant mass, tank size, injector design, cooling, ignition, and operating procedures tractable.

== Thermochemical Method and Evidence Standard

All thermochemical values in this section use the included script #link("optimize_cea.py")[optimize_cea.py] and the generated output package @cea_hopper_runs_2026. The script wraps RocketCEA, which is a Python interface to NASA CEA. NASA CEA computes chemical-equilibrium rocket performance and supports equilibrium and frozen expansion modes @mcbride1996cea. RocketCEA documents `get_Isp` as vacuum impulse and `estimate_Ambient_Isp` as the function that applies a specified ambient pressure and reports the operating mode @rocketcea_functions @rocketcea_ambient.

The design-basis comparison uses:

- $P_c = 150 "psia"$.
- $P_"amb" = 14.7 "psia"$.
- Shifting-equilibrium chemistry.
- O/F swept over a broad candidate-specific range.
- At each O/F, $epsilon$ chosen so that $P_e approx P_"amb"$.
- Sea-level impulse computed with `estimate_Ambient_Isp`, not vacuum `get_Isp`.

#warn-box("Performance-value rule")[
  A CEA/RocketCEA performance number is incomplete unless it states $P_c$, $P_"amb"$, $epsilon$, $P_e$, O/F, chemistry mode, and whether the reported impulse is $I_"sp,SL"$ or $I_"sp,vac"$. In this notebook, propellant selection uses sea-level ambient-corrected $I_"sp,SL"$.
]

#figure(
  image("rocket_outputs/figures/batch_optimized_sea_level_isp.png", width: 92%),
  caption: [Generated RocketCEA comparison for optimized sea-level impulse at $P_c = 150 "psia"$, $P_"amb" = 14.7 "psia"$, shifting-equilibrium chemistry, and $P_e approx P_"amb"$ nozzle sizing @cea_hopper_runs_2026.],
) <fig-cea-batch-isp>

== Candidate Survey

=== Hard-Eliminated Candidates

These combinations are removed before finalist comparison because a safety, legality, sourcing, or architecture constraint is sufficient by itself.

- *LOX-based propellants* (LOX/ethanol, LOX/RP-1, LOX/LCH₄, LOX/LH₂): eliminated because the first prototype forbids cryogenic storage.
- *Hydrazine-family fuels, MMH, UDMH, and NTO*: eliminated for toxicity, regulatory burden, and handling risk.
- *RFNA / ethanol*: eliminated for toxicity, corrosion, and incompatibility with the low-cost aluminum/stainless construction path.
- *High-test peroxide at 90%+*: eliminated for the first prototype because the project does not yet have the sourcing, cleaning, catalyst-bed, compatibility, and decomposition-risk controls required for this oxidizer class @cervone2006.
- *N₂O / RP-1 or kerosene*: eliminated for this regen-cooled first prototype because fuel coking and residue management are unnecessary risks when alcohol fuels are available.

=== Performance-Eliminated or Deprioritized Candidates

#figure(
  compact-table(
    table(
      columns: (1.45fr, 0.8fr, 0.75fr, 0.8fr, 2.5fr),
      fill: tfill,
      align: (left, center, center, center, left),
      inset: 4.5pt,
      [*Candidate*], [*O/F*], [*$epsilon$*], [*$I_"sp,SL"$*], [*Disposition*],
      [70% H₂O₂ / Ethanol], [6.30], [2.30], [$185.0 "s"$], [Eliminated: low sea-level performance plus peroxide handling complexity.],
      [70% H₂O₂ / IPA], [7.20], [2.31], [$186.9 "s"$], [Eliminated: low sea-level performance plus peroxide handling complexity.],
      [85% H₂O₂ / Ethanol], [5.00], [2.36], [$201.1 "s"$], [Deprioritized: similar to N₂O/alcohol impulse but with peroxide-specific catalyst and decomposition hazards.],
      [85% H₂O₂ / IPA], [5.65], [2.37], [$203.2 "s"$], [Deprioritized: no clear advantage over N₂O/alcohol for a first hopper.],
      [N₂O / Methanol], [3.50], [2.38], [$203.0 "s"$], [Deprioritized: below N₂O/IPA and adds methanol toxicity.],
      [GOX / Methanol], [1.20], [2.46], [$221.3 "s"$], [Deprioritized: below GOX/IPA and GOX/ethanol with no practical offsetting advantage.],
    )
  ),
  caption: [Sea-level performance screening for non-finalist liquid candidates. Conditions: $P_c = 150 "psia"$, $P_"amb" = 14.7 "psia"$, shifting-equilibrium chemistry, $P_e approx P_"amb"$ @cea_hopper_runs_2026.],
) <tbl-screening>

*H₂O₂ at 80-85% / ethanol or IPA.* This concentration is more accessible than 90%+ peroxide, but it still requires peroxide-compatible storage, cleaning, decomposition controls, and usually catalyst hardware. The 265 s value sometimes quoted from peroxide monopropellant development literature is a high-expansion-ratio vacuum monopropellant number and does not apply to this low-expansion sea-level bipropellant comparison @cervone2006. At the design-basis condition, 85% peroxide/alcohol does not materially outperform N₂O/alcohol and is not the lowest-risk path.

*Methanol combinations.* Methanol has legitimate historical rocket use, including as part of German C-Stoff mixtures, but it does not outperform ethanol or IPA in the design-basis RocketCEA comparison. It also has a worse handling profile; OSHA lists a 200 ppm permissible exposure limit for methyl alcohol @osha_methanol. Methanol remains technically possible, but it does not merit a finalist slot.

*N₂O with gaseous hydrocarbon fuels.* Ethylene, ethane, and propane can be made to work in propulsion systems, but they are a poor match to this ground hopper. Ethylene has a critical temperature of about $282.5 "K"$ ($9.3 degree "C"$), so it cannot be stored as a normal room-temperature liquid; NIST lists ethylene critical data near $T_c = 282.5 "K"$ and $P_c = 50.6 "bar"$ @nist_ethylene. Propane is easier to store, but its room-temperature vapor pressure is not enough to feed a $P_c = 150 "psia"$ engine without additional pressurization @nist_propane. Liquid alcohol fuels win on density, sourcing, cooling usefulness, and injector simplicity.

== The Four Viable Finalists

The four viable first-prototype finalists are N₂O/IPA, N₂O/ethanol, GOX/IPA, and GOX/ethanol. They are not equivalent: GOX/alcohol has better design-basis sea-level performance and easier single-phase injector modeling, while N₂O/alcohol has compact self-pressurizing oxidizer storage and direct small-hopper precedent.

#figure(
  compact-table(
    table(
      columns: (1.25fr, 0.7fr, 0.7fr, 0.85fr, 0.85fr, 0.85fr, 0.85fr),
      fill: tfill,
      align: (left, center, center, center, center, center, center),
      inset: 4.5pt,
      [*Propellant*], [*O/F*], [*$epsilon$*], [*$I_"sp,SL"$*], [*$I_"sp,vac"$*], [*$T_c$*], [*$c^*$*],
      [GOX / IPA], [1.65], [2.43], [$230.1 "s"$], [$272.9 "s"$], [$3237 "K"$], [$1762 "m/s"$],
      [GOX / Ethanol], [1.55], [2.45], [$225.6 "s"$], [$268.0 "s"$], [$3187 "K"$], [$1727 "m/s"$],
      [N₂O / IPA], [5.10], [2.37], [$207.0 "s"$], [$244.6 "s"$], [$3120 "K"$], [$1590 "m/s"$],
      [N₂O / Ethanol], [4.65], [2.38], [$204.8 "s"$], [$242.2 "s"$], [$3064 "K"$], [$1573 "m/s"$],
    )
  ),
  caption: [Design-basis RocketCEA performance for finalist propellants. Conditions: $P_c = 150 "psia"$, $P_"amb" = 14.7 "psia"$, shifting-equilibrium chemistry, $P_e approx P_"amb"$ @cea_hopper_runs_2026.],
) <tbl-finalist-performance>

#info-box("Key observation")[
  At $P_c = 150 "psia"$ and sea-level ambient pressure, the GOX/alcohol options are about 19-25 s ahead of the N₂O/alcohol options in ideal ambient-corrected impulse. That advantage is real, but it must be traded against compressed-oxygen storage mass, regulator cost, oxygen cleaning, and fire safety. For a barely-flying hopper, feed-system risk can dominate ideal $I_"sp"$.
]

=== Common N₂O Architecture

N₂O is stored as a saturated liquid at its own vapor pressure. Resonac lists nitrous oxide vapor pressure at $20 degree "C"$ as $5.24 "MPa"$ and gives a critical temperature of $36.41 degree "C"$ with critical pressure $7.24 "MPa"$ @resonac_n2o. This allows compact self-pressurizing oxidizer storage without a separate high-pressure inert pressurant.

The disadvantage is that feed pressure is temperature-dependent. The oxidizer tank, injector pressure drop, oxidizer mass flow, and thrust map change with tank temperature and with evaporative cooling during discharge. Any N₂O engine must therefore treat tank temperature and pressure as control inputs, not background conditions.

==== Injector: Two-Phase Flow

N₂O can flash through restrictions because it is often near saturation before the injector. The standard incompressible single-phase orifice equation,

$ dot(m) = C_d A sqrt(2 rho Delta P) $

is useful only as an upper-bound starting point for the oxidizer injector. Dyer-style non-homogeneous non-equilibrium modeling, homogeneous equilibrium modeling, and cold-flow/hot-fire calibration are needed for credible final sizing @dyer2007 @solomon2011 @deisenroth2019 @zimmermann2022.

#figure(
  compact-table(
    table(
      columns: (1.2fr, 1.8fr, 1.45fr, 1.8fr),
      fill: tfill,
      align: (left, left, left, left),
      inset: 4.5pt,
      [*Model*], [*Assumption*], [*Expected bias*], [*Use in this project*],
      [SPI], [Single-phase incompressible liquid.], [Often overpredicts N₂O oxidizer flow after flashing starts.], [Upper-bound geometry estimate only.],
      [HEM], [Two-phase thermodynamic equilibrium through the restriction.], [Can underpredict short-orifice flow where equilibrium is not reached.], [Lower-bound check and long-channel reference.],
      [Dyer / NHNE], [Non-equilibrium transition between SPI and HEM.], [Most practical published engineering model for self-pressurizing oxidizer injectors.], [Primary N₂O injector sizing model before test calibration.],
    )
  ),
  caption: [N₂O injector mass-flow model hierarchy.],
) <tbl-n2o-injector-models>

The practical N₂O injector workflow is:

+ Size an initial oxidizer orifice using SPI.
+ Compute HEM for the same geometry to establish a lower-bound flow estimate.
+ Apply Dyer/NHNE or a comparable two-phase model using the selected orifice $L/D$.
+ Cold-flow the injector over the expected tank-temperature range.
+ Update the throttle map using hot-fire data.

==== Throttling Behavior

The AEL N₂O/IPA throttle work is directly relevant because it studied a small closed-loop throttleable VTVL thruster at approximately the right architecture. The reported behavior was dominated by N₂O phase change through the control valve and injector rather than by simple hydraulic pressure-drop scaling @waugh2018. This makes empirical throttle-map calibration mandatory for a flight hopper.

==== Material Compatibility and Operations

N₂O hardware must be kept oxygen-clean enough to avoid fuel contamination on the oxidizer side. Aluminum and stainless hardware can be used when the system is designed around compatible seals, cleaned assembly practice, relief devices, and conservative temperature control. The Las Vegas temperature case is handled separately in @las-vegas-warning.

=== N₂O / IPA

#finalist-box[
N₂O/IPA is the leading first-hopper selection. It is not the highest-$I_"sp"$ option, but it combines compact non-cryogenic oxidizer storage, easy fuel sourcing, direct VTVL precedent, and acceptable sea-level performance.
]

Design-basis RocketCEA result: $I_"sp,SL" = 207.0 "s"$, $I_"sp,vac" = 244.6 "s"$, O/F $= 5.10$, $epsilon = 2.37$, $T_c = 3120 "K"$, and $c^* = 1590 "m/s"$.

*Flight heritage.* GSP's Colibri vehicle used a bipropellant engine with N₂O and IPA. Kistler reports that Colibri is a $2.45 "m"$ reusable VTVL demonstrator with up to $1.25 "kN"$ thrust; by October 2024 it had completed 53 flights with safe landings @kistler2024. European Spaceflight reports a 105 m free flight on 18 October 2024, a 30 m lateral translation, and a 60 s flight time @europeanspaceflight2024. This is the closest documented analog to the intended project.

*Fuel sourcing.* 99% IPA is widely available through hardware, janitorial, and chemical suppliers. 70% disinfectant is not suitable because the water content changes performance and ignition behavior.

*Cooling.* IPA has slightly higher room-temperature specific heat than ethanol, while ethanol has higher thermal conductivity. CRC values used here are $c_p approx 2.68 "kJ/kg/K"$ and $k approx 0.135 "W/m/K"$ for IPA at room temperature @crc2023. Both alcohols remain plausible regenerative coolants at this scale; final margin belongs in the cooling section.

=== N₂O / Ethanol

#finalist-box[
N₂O/ethanol is the strongest N₂O backup path because it has a larger academic static-test literature base and slightly better thermal conductivity as a coolant.
]

Design-basis RocketCEA result: $I_"sp,SL" = 204.8 "s"$, $I_"sp,vac" = 242.2 "s"$, O/F $= 4.65$, $epsilon = 2.38$, $T_c = 3064 "K"$, and $c^* = 1573 "m/s"$.

*Experimental literature.* NMIMT/Sandia conducted N₂O/ethanol engine development and test work, and ISAS/JAXA studied a 2 kN-class N₂O/ethanol propulsion system @phillip2016 @youngblood2016 @tokudome2021. These sources support the credibility of N₂O/ethanol combustion development, but their reported impulse values must not be transferred blindly unless $P_c$, $P_"amb"$, nozzle expansion, and data-reduction basis match this design.

*Cooling.* Ethanol's room-temperature thermal conductivity is about $0.171 "W/m/K"$ versus about $0.135 "W/m/K"$ for IPA, while its specific heat is slightly lower, about $2.57 "kJ/kg/K"$ versus $2.68 "kJ/kg/K"$ @crc2023. This makes ethanol attractive if the cooling jacket is heat-flux limited rather than bulk-temperature-rise limited.

*Sourcing.* Anhydrous ethanol requires more procurement control than IPA. 190-proof ethanol contains enough water to change performance and optimum O/F, so 200-proof or otherwise documented water content is required for repeatable CEA-to-test comparison.

=== Common GOX Architecture

GOX provides the cleanest injector physics: the oxidizer can be treated as a regulated single-phase gas upstream of the injector, so the first-pass orifice model is much more predictable than N₂O flashing flow. The trade is tankage and operations. A useful GOX system requires a high-pressure oxygen cylinder or lightweight vessel, a high-flow oxygen-compatible regulator, oxygen-clean assembly practice, and strict separation between oxygen-side and fuel-side tooling.

For equal impulse, GOX generally needs substantially more oxidizer storage volume than liquid N₂O. The ideal-gas oxygen volume estimate is:

$ V_"GOX" = (m_"O2" R_"O2" T) / P. $

At 2200 psia and 300 K, the gas volume for a few kilograms of oxygen is already tens of liters. The equivalent N₂O mass stores as a dense saturated liquid, typically giving a much smaller tank volume. This storage-volume penalty is the main reason GOX is not automatically selected despite its better sea-level impulse.

=== GOX / IPA

#finalist-box[
GOX/IPA is the design-basis performance leader among the non-cryogenic candidates analyzed here, but it carries the compressed-oxygen storage and regulator burden.
]

Design-basis RocketCEA result: $I_"sp,SL" = 230.1 "s"$, $I_"sp,vac" = 272.9 "s"$, O/F $= 1.65$, $epsilon = 2.43$, $T_c = 3237 "K"$, and $c^* = 1762 "m/s"$.

GOX/IPA deserves a full design pass if the project can source oxygen-compatible regulators, vessels, valves, fittings, and cleaning procedures inside the budget. Its weakness is not performance; it is system mass, system cost, and oxygen safety practice.

=== GOX / Ethanol

#finalist-box[
GOX/ethanol is nearly as strong as GOX/IPA analytically and has useful ignition literature at comparable chamber pressure.
]

Design-basis RocketCEA result: $I_"sp,SL" = 225.6 "s"$, $I_"sp,vac" = 268.0 "s"$, O/F $= 1.55$, $epsilon = 2.45$, $T_c = 3187 "K"$, and $c^* = 1727 "m/s"$.

A 1984 NASA ignition characterization study tested GOX/ethanol near $P_c = 150 "psia"$ and O/F near 1.8 @nasa1984. That makes GOX/ethanol valuable as a lower-injector-risk fallback if N₂O two-phase design becomes the bottleneck.

== Decision Analysis

=== Oxidizer-Level Trade: N₂O vs. GOX

#figure(
  compact-table(
    table(
      columns: (1.4fr, 2.15fr, 2.15fr),
      fill: tfill,
      align: (left, left, left),
      inset: 4.5pt,
      [*Criterion*], [*N₂O path*], [*GOX path*],
      [Sea-level performance], [Lower: about $205-207 "s"$ at 150 psia.], [Higher: about $226-230 "s"$ at 150 psia.],
      [Oxidizer storage], [Compact saturated liquid; self-pressurizing.], [Bulky compressed gas unless a custom lightweight vessel is used.],
      [Feed stability], [Tank pressure changes with temperature and discharge history.], [Regulated feed pressure can be stable and repeatable.],
      [Injector physics], [Two-phase flashing; requires Dyer/HEM/SPI bracketing and testing.], [Mostly single-phase gas; simpler first-pass analysis.],
      [Hardware cost], [No oxygen regulator; pressure vessel still safety-critical.], [High-flow oxygen regulator and oxygen-rated fittings are major cost items.],
      [Operating risk], [Thermal management near N₂O critical temperature is central.], [Oxygen cleaning and combustion-contamination control are central.],
      [Best reason to choose], [Compact, self-contained, directly relevant hopper precedent.], [Higher $I_"sp"$ and easier injector sizing.],
    )
  ),
  caption: [Oxidizer-level architecture comparison.],
) <tbl-oxidizer-trade>

GOX/IPA and GOX/ethanol are analytically attractive. They should win if the oxygen storage, regulator, cleaning, and mass model close. For the first low-complexity hopper path, N₂O remains more attractive because it avoids cryogenics and a regulated high-flow oxygen gas system while keeping the oxidizer tank compact.

=== Fuel-Level Trade Inside the N₂O Path

#figure(
  compact-table(
    table(
      columns: (1.65fr, 1.6fr, 1.6fr),
      fill: tfill,
      align: (left, left, left),
      inset: 4.5pt,
      [*Criterion*], [*N₂O / IPA*], [*N₂O / Ethanol*],
      [Design-basis $I_"sp,SL"$], [$207.0 "s"$], [$204.8 "s"$],
      [Optimum O/F], [5.10], [4.65],
      [Flame temperature], [$3120 "K"$], [$3064 "K"$],
      [Fuel access], [Excellent: 99% IPA is widely available.], [Moderate: anhydrous ethanol sourcing must be controlled.],
      [Coolant $c_p$], [Slightly higher: $2.68 "kJ/kg/K"$ @crc2023.], [Slightly lower: $2.57 "kJ/kg/K"$ @crc2023.],
      [Coolant thermal conductivity], [Lower: $0.135 "W/m/K"$ @crc2023.], [Higher: $0.171 "W/m/K"$ @crc2023.],
      [VTVL precedent], [Direct: GSP Colibri and AEL work @kistler2024 @waugh2018.], [Strong static-test literature @phillip2016 @tokudome2021.],
      [Primary advantage], [Sourcing and flight-relevant precedent.], [Academic literature and thermal conductivity.],
    )
  ),
  caption: [N₂O/IPA versus N₂O/ethanol.],
) <tbl-n2o-fuel-trade>

==== Pros and Cons

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    ===== N₂O / IPA

    *Advantages*
    - Direct VTVL flight precedent at the closest public analog scale.
    - IPA is inexpensive and easy to source at high purity.
    - Slightly higher room-temperature $c_p$ than ethanol.
    - AEL throttle work is on N₂O/IPA.

    *Disadvantages*
    - Lower thermal conductivity than ethanol.
    - Less academic combustion literature than N₂O/ethanol.
    - All N₂O two-phase injector and temperature risks still apply.
  ],
  [
    ===== N₂O / Ethanol

    *Advantages*
    - Stronger academic static-test literature base.
    - Higher thermal conductivity as a regenerative coolant.
    - Historically common alcohol rocket fuel.
    - Good backup if following NMIMT/JAXA data closely.

    *Disadvantages*
    - Anhydrous ethanol procurement is less convenient.
    - Water content must be controlled.
    - No direct small VTVL flight precedent as strong as GSP Colibri.
  ],
)

=== Recommendation

*N₂O/IPA is the primary first-hopper selection.* The reason is not maximum ideal impulse. The reason is total development risk: easy fuel sourcing, compact self-pressurizing oxidizer storage, and direct VTVL flight precedent outweigh a roughly 20-25 s ideal sea-level impulse advantage from GOX when the vehicle only needs to demonstrate controlled low-altitude flight.

*N₂O/ethanol is the first backup.* Choose it if the cooling section shows ethanol's higher thermal conductivity is important, if anhydrous ethanol is already sourced, or if the design intentionally follows the NMIMT/JAXA N₂O/ethanol literature path.

*GOX/IPA or GOX/ethanol remain performance backups.* Choose GOX if the project prioritizes injector simplicity and can close the compressed-oxygen regulator, vessel, cleaning, and mass budget. If GOX is chosen, IPA has the slightly higher design-basis RocketCEA result while ethanol has the stronger ignition-literature tie through the NASA study.

== Las Vegas Operational Considerations <las-vegas-warning>

#warn-box("N₂O critical temperature and MEOP definition")[
  N₂O has a critical temperature of $36.41 degree "C"$ and critical pressure of $7.24 "MPa"$ @resonac_n2o. A N₂O tank in a hot vehicle, direct sun, or summer test area can approach a very different pressure state than the same tank in a shaded room. Tank temperature is therefore part of the design basis, not just an operating note.
]

Design implications:

+ MEOP must be defined from the maximum credible filled-tank temperature.
+ Fill fraction, ullage, relief devices, and tank material selection must be documented before any hot-weather oxidizer loading.
+ Throttle maps must be temperature-indexed because N₂O vapor pressure changes injector pressure drop and mass flow.
+ Test operations should standardize tank temperature or explicitly correct for it.

== Propellant Section Next Actions

+ Commit #link("rocket_outputs/data/batch_optimum_summary.csv")[batch_optimum_summary.csv] and #link("rocket_outputs/data/pressure_sweep_summary.csv")[pressure_sweep_summary.csv] with the notebook.
+ For the selected N₂O/IPA baseline, run a dedicated CEA sweep after selecting actual fuel purity and expected chamber-pressure range.
+ Build the N₂O injector model using SPI, HEM, and Dyer/NHNE bracketing before selecting orifice count and diameter.
+ Do not size final thrust or total propellant mass in this section; that belongs in the engine sizing and vehicle mass-convergence sections.

= Engine Archetypes

= Thermochemical Analysis

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
