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
  breakable: false,
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

Design a throttleable, simple liquid bipropellant engine (and every subsystem required for it to work) for a minimal VTVL hopper. The engine exists to support a possible vehicle in the future including subsystems such as avionics, landing gear, and test instrumentation. The theoretical flight objective for the full vehicle to be designed later is controlled liftoff, hover or near-hover control authority, and safe landing.

== Requirement Classification

The requirements below are limited to items that must be true before the design is considered acceptable. Quantities that set the analysis envelope (thrust class, burn time, chamber-pressure band, liftoff margin) are carried as sizing variables in @tbl-sizing-vars and justified in @sec-sizing-basis *before* propellant selection. They are deliberately independent of which oxidizer or fuel wins later.

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
      [Nominal thrust], [Sizing variable], [Analysis bracket 200--400 N for mass, cost, and static-fire planning. Final thrust is set in the engine-sizing section after dry mass and propellant mass converge.],
      [Full-thrust liftoff margin], [Design rule], [Require $T_"max" / (m_0 g_0) gt.eq 1.2$ once $m_0$ is known. The numeric floor is justified from vertical control authority in @sec-sizing-basis, independent of propellant choice.],
      [Burn duration], [Design goal], [30 s minimum useful demonstration; 60 s stretch target. Propellant mass follows from thrust, burn time, and $I_"sp,SL"$ after a propellant pair is selected.],
      [Chamber pressure], [Design variable], [150 psia for first static-fire analysis; 200 psia carried as a performance-upgrade case if feed, cooling, and structure close. Architecture-specific feed ceilings are evaluated after the oxidizer is chosen.],
    )
  ),
  caption: [Sizing variables set before propellant selection. Brackets are mission- and architecture-class anchors only; they do not assume a winning propellant pair. Justification is in @sec-sizing-basis.],
) <tbl-sizing-vars>

== Basis for the Sizing Brackets <sec-sizing-basis>

The brackets in @tbl-sizing-vars have to be fixed early enough that mass, cost, and CEA comparisons are comparable, but they must not smuggle in a propellant decision. This section sets them from mission class, pressure-fed feed physics that is common to every candidate, and published hopper scale — not from later screening results. Propellant-specific feed ceilings (self-pressurized saturation pressure, GOX regulator blowdown floor, peroxide tank ratings) are deferred until the corresponding oxidizer is under analysis.

#info-box("What this section is not")[
These numbers are not a claim that a 17--34 kg vehicle already closes, that 150 psia is optimal for every oxidizer, or that any propellant family is preferred. They are the analysis envelope I will use for every candidate equally. If a later architecture cannot close mass or feed at these brackets, that is evidence against that architecture — not a reason to rewrite the brackets to favor it.
]

Two small VTVL programs publish enough numbers to use as *scale* anchors. Both happen to fly N₂O/IPA; I record that fact for honesty and use only their thrust class, chamber-pressure regime, and liftoff loading here. Propellant selection is a separate decision later. Larger LOX/alcohol hoppers (Masten, Armadillo) are one to two orders of magnitude heavier and are recorded only when cryogenics are reconsidered @sec-lox.

#block[
#set text(size: 8.2pt)
#table(
  columns: (1.1fr, 0.95fr, 2.4fr, 1.7fr),
  fill: tfill,
  inset: 4pt,
  [*Vehicle*], [*Scale*], [*Published numbers*], [*What it anchors here*],
  [Gruyère Colibri], [100 kg wet, 2.45 m], [Up to 1.25 kN thrust; 105 m, 60 s free flight; wet mass 100 kg @gsp_colibri @kistler2024 @europeanspaceflight2024.], [Maximum liftoff $T\/W approx 1.27$; thrust loading ≈12.5 N per kg of wet mass. Scale check only — this vehicle is heavier than the class I am targeting.],
  [AEL Snark on Gyroc 5], [300 N thrust class], [Throttle range 20--117% of nominal; closed-loop throttle steps at 11.0 bar(a) (≈160 psia) chamber pressure; measured $c^*$ 1487 m/s and 215 s sea-level $I_"sp"$ at O/F 5:1 @waugh2018.], [Demonstrated pressure-fed chamber-pressure regime and throttle window at this thrust class; evidence that small thrusters realize ~90--95% of ideal $c^*$.],
)
]

*Full-thrust liftoff margin, $gt.eq 1.2$.* Hover is exactly $T\/W = 1$, so every point above 1 is vertical control authority. At 1.2 the peak upward acceleration is about $0.2 g_0 approx 2$ m/s², which arrests a 2 m/s sink rate in about one second and one metre of altitude; at 1.05 the same arrest takes about four seconds and four metres — not useful control authority on a short-hop vehicle. The margin also has to absorb the difference between ideal and delivered thrust: published small bipropellant thrusters often realize on the order of 90--95% of ideal $c^*$ (Snark measured 1487 m/s against an ideal near 1590 m/s at its operating point, ≈94%) @waugh2018, and any pressure-fed feed system can sag thrust at fixed valve command as tank conditions change. The upper side is bounded by throttle depth on descent: once $m_0$ is known, descent requires $T_"min" < m_f g_0$, so a higher liftoff margin forces a deeper minimum throttle. With a flight propellant fraction near 25%, a 1.2 margin already implies throttling to roughly 60% of full thrust; a 2.0 margin would demand roughly 40%. That trade is propellant-agnostic at this level; how hard deep throttle is depends on the feed architecture and is evaluated later. Colibri flies near a maximum $T\/W$ of about 1.27 @gsp_colibri @kistler2024, so 1.2 is a floor with a flying precedent just above it. I see no reason to buy much beyond ≈1.5 for a first article.

*Nominal thrust, 200--400 N.* With the margin rule fixed, thrust follows from the vehicle class I am willing to build. The mission is a *minimal* controlled hop under a ≤\$5,000 prototype-hardware budget with no turbopumps and a small-team build/test loop. That points to a wet mass in the tens of kilograms, not Colibri's 100 kg class and not a multi-kN booster. Inverting $T_"max" / (m_0 g_0) = 1.2$ maps 200--400 N onto a wet-mass allowance of about 17--34 kg. Colibri's published loading of ≈12.5 N/kg maps the same thrust bracket onto ≈16--32 kg, and Snark sits mid-bracket at 300 N for the same mission type @gsp_colibri @waugh2018. I am *not* using a particular oxidizer bottle or cylinder map to justify the bracket: storage mass depends on the propellant decision and will be checked after that decision. The 200 N end is the static-fire and cost floor; the 400 N end is the stretch corner for mass and cost scaling. The final flight thrust still converges in the engine-sizing section once dry mass and propellant load are known.

*Chamber pressure, 150 psia baseline / 200 psia upgrade case.* For a pressure-fed system, tank pressure must exceed chamber pressure plus injector drop, valve drop, and line losses. Huzel and Huang's injector-stiffness guidance of roughly 15--20% of $P_c$ is a common preliminary allowance @huzel1992, so feed pressure is already ≈1.2 $P_c$ before valves and lines. Published design guidance for pressure-fed engines therefore keeps chamber pressure modest so the tanks stay light: materials and systems literature commonly places pressure-fed combustion pressures in a roughly 100--200 psia band for that reason @halchak2018. Raising $P_c$ improves theoretical $I_"sp"$ and shrinks the thruster for a given thrust, but it raises MEOP on every pressure-wetted part and tightens feed margin for *every* oxidizer architecture. I therefore pick 150 psia as a mid-band first analysis point inside that textbook range, and carry 200 psia as the upgrade case if feed, cooling, and structure close. Snark's demonstrated ≈160 psia closed-loop operation is corroborating evidence that this regime is workable at the 300 N class @waugh2018 — not a propellant lock-in. Architecture-specific ceilings (for example cold-tank saturation pressure on a self-pressurized oxidizer, or regulator delivery floor on a gaseous oxidizer) are evaluated only after that oxidizer is selected; they may force a lower $P_c$ or a supercharge/pump decision, but they do not redefine the comparison baseline.

*Burn duration, 30 s floor / 60 s stretch.* This is a stated project goal, not a derived quantity: long enough to demonstrate throttle and hover-like control, short enough that propellant mass and heat soak remain first-article problems. Propellant mass is $m_p = T t / (I_"sp,SL" g_0)$ after thrust and $I_"sp"$ are known.

I am deliberately *not* listing a numeric minimum-throttle ratio here. Descent capability is the inequality $T_"min" < m_f g_0$ once masses are known; the ratio $T_"min"/T_"max"$ is a consequence of the liftoff margin and the propellant fraction, not an independent sizing input. The hard requirement remains the throttle demonstration test listed in @tbl-hard-reqs.

= Propellant

== Define the Problem

Select a storable oxidizer/fuel pair for a small pressure-fed VTVL hopper. The selected pair must support repeatable throttling, safe ground testing, affordable consumables, realistic tankage, and a credible path to injector and cooling design. The decision is not "maximize $I_"sp"$"; it is "minimize total development risk while preserving enough performance for a minimal controlled hop."

The analysis envelope is already fixed in @sec-sizing-basis (200--400 N, $T\/W gt.eq 1.2$, 30--60 s burns, 150 psia baseline $P_c$ with a 200 psia upgrade case). Every candidate below is scored against that same envelope. I am not allowed to retune thrust or chamber pressure mid-trade to rescue a propellant family that fails storage, cost, or feed physics at those brackets.

Categories of analysis:
- Cost
- Storage mass and volume
- Stability / predictability
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
  [LOX-based combinations], [They violate the no-cryogenic first-article constraint. A LOX engine is a valid later project, not the fastest safe path to this hopper. Reconsidered quantitatively in @sec-lox; the screen stands.],
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

The table below is generated from the companion RocketCEA project at the @sec-sizing-basis baseline of $P_c = 150 "psia"$, $P_"amb" = 14.7 "psia"$, and a sea-level-matched nozzle. Values are shifting-equilibrium RocketCEA/NASA CEA outputs @cea_hopper_runs_2026. Pressure sensitivity for survivors is checked later; it is not used to pre-select a pair.

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

== Quantitative Sourcing and System Sizing <sec-sourcing>

Pricing below is a planning model, not a purchase instruction. Industrial gas prices vary by region, account status, deposit/rental policy, hazmat shipping, and cylinder exchange rules. The useful engineering comparison is the order of magnitude: GOX consumables can be cheap, but the storage/regulator system is expensive and heavy; N₂O consumables are more expensive per kilogram, but the liquid storage is much smaller and the tank is also the pressure source. I should replace these bands with local quotes before procurement, but the bands below are anchored to published prices — including the Friends of Amateur Rocketry propellant list, which is the closest thing to a posted market price for amateur-scale rocket oxidizers and includes tax and delivery to a real test site @far_propellants.


#block[
#set text(size: 8.2pt)
#table(
  columns: (1.0fr, 1.65fr, 1.2fr, 2.1fr),
  fill: tfill,
  inset: 3.8pt,
  [*Material*], [*Practical acquisition route*], [*Planning price*], [*Design note*],
  [N₂O], [Racing-gas cylinder from an amateur test site or gas supplier; motorsport refill], [\$12--\$22/kg], [FAR sells a 56 lb racing-grade cylinder with dip tube for \$292, about \$11.5/kg @far_propellants; motorsport refills run \$8.49--\$9.79/lb (\$18.7--\$21.6/kg) @skspeed_n2o_refill. Higher one-off retail fills are reported.],
  [GOX], [Welding oxygen cylinder exchange or industrial gas supplier], [\$4--\$16/kg], [Welding-trade guides put small-cylinder refills/exchanges around \$4--\$12/kg @weldguru_gas_cost; FAR sells a filled 125 cf cylinder for \$71.84 including tax and delivery, about \$15/kg @far_propellants.],
  [LOX], [Industrial gas supplier dewar; also sold at amateur test sites], [\$2--\$4/kg], [Screened out for the first article but priced for honesty: FAR sells 230 L (roughly 262 kg) for \$540 @far_propellants, and a trade source reports a \$200 quote for a 180 L dewar @hvo_oxygen_cost. Dewar deposit/rental and boiloff excluded. See @sec-lox.],
  [99% IPA], [Hardware, janitorial, lab, or chemical supplier], [\$8--\$12/kg], [Representative 99% IPA is \$23.50/gal before shipping/hazmat; 70% rubbing alcohol is not acceptable @hisco_ipa_99.],
  [Anhydrous ethanol], [Industrial/lab chemical supplier; denatured 200-proof acceptable if compatible], [\$13--\$30/kg], [Denatured 200-proof ethanol can be near \$40--\$57/gal, while tax-paid absolute ethanol can be much higher @laballey_ethanol_200 @volusol_ethanol_200_taxpaid.],
  [70--85% H₂O₂], [Specialty chemical supplier; high-concentration grades usually quote/hazmat], [\$20--\$60+/kg placeholder], [Public lower-concentration lab peroxide pricing is visible, but 70% is specialty/quote and not ordinary pool-supply grade @laballey_h2o2_bulk @interstate_h2o2_70 @federalregister_cfats2007.],
)
]


#block[
#set text(size: 8.0pt)
#table(
  columns: (1.15fr, 0.62fr, 0.72fr, 0.72fr, 0.72fr, 0.85fr, 0.95fr),
  fill: tfill,
  inset: 3.4pt,
  [*Case*], [*Thrust*], [*Total prop.*], [*Oxidizer*], [*Fuel*], [*Ox storage*], [*Propellant cost*],
  [N₂O / IPA], [200 N], [5.91 kg], [4.94 kg], [0.97 kg], [7.9 L], [\$67--\$120],
  [N₂O / IPA], [400 N], [11.82 kg], [9.88 kg], [1.94 kg], [15.8 L], [\$134--\$241],
  [N₂O / Ethanol], [200 N], [5.97 kg], [4.92 kg], [1.06 kg], [7.9 L], [\$73--\$140],
  [N₂O / Ethanol], [400 N], [11.95 kg], [9.83 kg], [2.11 kg], [15.7 L], [\$145--\$280],
  [GOX / IPA], [200 N], [5.32 kg], [3.31 kg], [2.01 kg], [17.5 L], [\$29--\$77],
  [GOX / IPA], [400 N], [10.64 kg], [6.62 kg], [4.01 kg], [34.9 L], [\$59--\$154],
  [GOX / Ethanol], [200 N], [5.42 kg], [3.30 kg], [2.13 kg], [17.4 L], [\$41--\$117],
  [GOX / Ethanol], [400 N], [10.85 kg], [6.59 kg], [4.25 kg], [34.8 L], [\$82--\$233],
)
]

The GOX volume in the table assumes storage near 2200 psia and 293 K using the ideal-gas law; the N₂O volume assumes saturated-liquid storage near room temperature with a 20% ullage/design margin. The 750 kg/m³ N₂O density is deliberately a warm-tank planning value: saturated-liquid density is roughly 745--790 kg/m³ over 20--25°C and falls steeply toward the critical point, so a hot Las Vegas tank holds less than a cool one @nist_n2o. These are comparison numbers, not final pressure-vessel dimensions; candidate pressure vessels still need manufacturer ratings, valve details, fill rules, and compatibility checks @cost_model_2026.

The 400 N, 60 s case is the stretch corner of the requirement, not the requirement, so it must not size the architecture by itself; the honest way is to map every corner of the thrust/burn-time envelope onto real, priced vessels. Stored GOX assumes blowdown from 2265 psia service pressure to a 500 psia regulator floor, leaving about 78% of the fill usable; the N₂O planning load is 1.25× the burned mass to cover retained vapor, pressure sag near depletion, and fill tolerance @cost_model_2026.

#block[
#set text(size: 7.7pt)
#table(
  columns: (0.95fr, 1.05fr, 1.55fr, 1.05fr, 1.55fr),
  fill: tfill,
  inset: 3.5pt,
  [*Case*], [*GOX burned / stored*], [*GOX vessel (price, tare)*], [*N₂O burned / loaded*], [*N₂O bottle (price, tare)*],
  [200 N, 30 s], [1.65 / 2.12 kg], [80 cf steel (\$143.50)], [2.47 / 3.09 kg], [10 lb bottle (\$314.99, 6.3 kg)],
  [200 N, 60 s], [3.30 / 4.23 kg], [125 cf steel (\$194.50, 26.3 kg)], [4.94 / 6.18 kg], [15 lb bottle (\$374.99, 8.1 kg)],
  [400 N, 30 s], [3.30 / 4.23 kg], [125 cf steel (\$194.50, 26.3 kg)], [4.94 / 6.18 kg], [15 lb bottle (\$374.99, 8.1 kg)],
  [400 N, 60 s], [6.59 / 8.46 kg], [250 cf steel (\$274.80, 49.0 kg)], [9.88 / 12.36 kg], [2 × 15 lb bottles (\$749.98, 16.1 kg)],
)
]

Cylinder and bottle picks, prices, and tares are current public listings @gascylindersource_o2_125 @gascylindersource_oxygen250 @airgas_oxygen250 @nitrousoutlet_bottles. Read this table two ways. As ground-support hardware, GOX storage is cheap at every requirement point: the 30 s floor case is one \$143.50 welding cylinder, and only the full stretch case forces the 250-class cylinder. As onboard hardware, the same column is disqualifying: the mapped steel cylinders carry roughly 26--49 kg of steel to deliver 3.3--6.6 kg of usable oxygen, about 7 kg of vessel per kilogram of oxidizer against about 1.5 kg/kg for the nitrous bottles. Aluminum and composite oxygen cylinders improve the ratio but remain far from the bottle numbers and cost more, and breathing-air composite cylinders (SCBA, paintball) are not rated for oxygen service and are not a shortcut.

The vessel is not where the architectures diverge on cost, so the next table itemizes the full oxidizer-side feed system at the 200 N, 60 s reference. Allowance rows are marked as such; everything else is a current public listing.

#block[
#set text(size: 7.7pt)
#table(
  columns: (0.85fr, 2.05fr, 1.85fr),
  fill: tfill,
  inset: 3.5pt,
  [*Item*], [*GOX / alcohol*], [*N₂O / alcohol*],
  [Storage vessel], [125 cf steel CGA-540 cylinder: \$194.50, 26.3 kg tare @gascylindersource_o2_125.], [15 lb aluminum bottle with high-flow valve: \$374.99, 8.1 kg tare @nitrousoutlet_bottles.],
  [Pressure regulation], [High-flow high-delivery oxygen regulator. Harris 3000-2500 lists \$699 @weldingsupply_harris_o2_reg; Victor SR4J-540 lists \$1,077, rated 16,600 scfh against roughly 5,300 scfh needed at 200 N and 10,500 scfh at 400 N @zoro_victor_sr4j.], [None. Tank vapor pressure is the feed source.],
  [Run valve and plumbing], [Oxygen-clean actuated run valve, check valve, relief, CGA-540 pigtail: \$250--\$450 allowance (quote items).], [Motorsport N₂O solenoid or actuated ball valve plus -AN plumbing: \$250--\$550 allowance (quote items).],
  [Fill and ground handling], [Cylinder exchange at the supplier; no owned fill hardware.], [Fill adapter and scale: \$100--\$250 allowance, or per-fill service at a speed shop @skspeed_n2o_refill.],
  [Cleanliness], [Every wetted part oxygen-cleaned per CGA G-4.1: \$50--\$150 consumables and verification @cga_g41.], [No separate line item, but the same discipline applies: hydrocarbon contamination catalyzes N₂O decomposition @karabeyoglu2008.],
  [*Subtotal*], [*\$1,190--\$1,870*], [*\$725--\$1,175*],
)
]

Shared subsystems are excluded from both columns because both architectures need them: fuel tank, fuel-side pressurant, commodity pressure transducers (\$30--\$80 class), harness, and test stand. One common claim needs correcting here: N₂O does not eliminate the pressurant bottle, only the oxidizer-side one. The AEL Snark vehicle fed IPA from a nitrogen-pre-pressurized tank, and this project will need the same small N₂ system either way @waugh2018.

#figure(
  image("rocket_outputs/figures/architecture_campaign_cost.png", width: 100%),
  caption: [Oxidizer-architecture hardware plus consumables against number of 200 N, 60 s hot fires; mid-band lines with low/high shading @cost_model_2026.],
) <fig-architecture-campaign-cost>

The hardware premium and the consumables premium pull in opposite directions, so the honest comparison is the whole campaign. The GOX architecture costs roughly \$470--\$700 more up front, almost all of it regulator and oxygen-clean components rather than the cylinder. The N₂O architecture pays roughly \$38--\$43 more per test than GOX/IPA and \$4--\$26 more than GOX/ethanol, whose expensive fuel erodes most of the cheap-gas advantage. On mid-band assumptions the GOX premium pays back after about 15 hot fires against GOX/IPA and only after about 40 against GOX/ethanol. For a pure static-fire program, GOX/IPA is the cheapest campaign. What that framing misses is the flight article: the compact bottle in the mapping table above is the only storage option in this set that a hopper can plausibly lift, and it doubles as the pressurization system.

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

The O/F curve also shows why "run fuel-rich to save oxidizer" is not a large win for this pair. At the 200 N, 60 s reference burn, moving from O/F = 5.10 to O/F = 4.50 cuts N₂O from 4.94 kg to 4.86 kg, but loses 0.8 s of computed sea-level $I_"sp"$ and adds about 0.11 kg of IPA. At O/F = 4.00, the oxidizer savings are only about 0.14 kg while the penalty grows to about 3.0 s. I would not move far below the optimum only for oxidizer mass; I would shift O/F only if injector stability, cooling, or hot-fire data asks for it @cea_hopper_runs_2026.

N₂O/IPA survives screening as a strong contender for the hopper mission. The sea-level ambient-corrected computed performance is $I_"sp,SL" = 207.0 "s"$ at O/F = 5.10 and $epsilon = 2.37$ @cea_hopper_runs_2026. That is not high compared with vacuum-optimized numbers, but it is enough for a minimal hop and avoids the hardware burden of high-pressure GOX storage.

The strongest external evidence for this pair is direct VTVL heritage. Gruyère Space Program's Colibri vehicle uses an N₂O/IPA bipropellant engine and is documented as a 2.45 m VTVL demonstrator with up to 1.25 kN thrust @kistler2024. European Spaceflight reported the October 18, 2024 free flight to 105 m altitude, 30 m lateral translation, and 60 s duration @europeanspaceflight2024. That is the closest public analog to this project. Formal selection waits until the architecture, risk, and cost comparisons below are complete.

#finalist-box[*Standing after analysis.* Compact self-pressurizing oxidizer storage, no oxidizer regulator, cheap fuel, and direct small-VTVL precedent. The open risk is injector/feed calibration for flashing N₂O (@sec-n2o-risk), not sea-level $I_"sp"$.]

=== N₂O / Ethanol

#figure(
  image("rocket_outputs/figures/N2O_Ethanol_of_isp_and_oxidizer_mass.png", width: 100%),
  caption: [Individual O/F curve. The dashed curve in each panel is oxidizer mass required for a 200 N, 60 s burn.],
) <fig-of-OF-curve-nitrous-oxide-ethanol>

For N₂O/ethanol the curve is broad near the optimum. O/F = 4.20 reduces N₂O from 4.92 kg to 4.84 kg and costs only 0.6 s, so a small fuel-rich bias is acceptable if it helps cooling or calibration. Going to O/F = 4.00 saves only about 0.11 kg oxidizer and already loses 1.3 s; O/F = 3.50 saves about 0.17 kg but loses 4.3 s. The mass benefit is too small to justify a large performance departure by itself @cea_hopper_runs_2026.

N₂O/ethanol is a close peer to N₂O/IPA: broader academic static-fire literature and better coolant thermal conductivity, at nearly the same computed impulse. The sea-level ambient-corrected computed performance is $I_"sp,SL" = 204.8 "s"$ at O/F = 4.65 and $epsilon = 2.38$ @cea_hopper_runs_2026. The difference from N₂O/IPA is only 2.2 s at the sizing-basis baseline, so performance alone should not decide between these two fuels.

Ethanol has slightly lower specific heat but higher thermal conductivity than IPA at room temperature; the coolant trade is therefore not one-sided. IPA has slightly better bulk heat capacity, while ethanol has better film-side conduction margin @crc2023.

#finalist-box[*Standing after analysis.* Natural fuel alternate on the same N₂O architecture. Prefer ethanol if the design is intentionally aligned with N₂O/ethanol literature or if regen-cooling margin dominates fuel procurement convenience.]

=== N₂O Architecture Risk: Feed, Injector, and Environment <sec-n2o-risk>

This is the most important risk record in the propellant decision, because it describes the one problem the N₂O finalists cannot close on paper. N₂O is stored as a saturated liquid at its own vapor pressure. Resonac lists high-purity N₂O vapor pressure as 5.24 MPa at 20°C (≈760 psia) and gives a critical temperature of 36.41°C with critical pressure 7.24 MPa @resonac_n2o. This enables self-pressurization, but it also means feed pressure changes strongly with tank temperature: saturation pressure is already about 590 psia at 10°C and 457 psia at 0°C @resonac_n2o. It also changes during the burn: as liquid leaves, the remaining propellant evaporates to refill the ullage, the tank self-cools, and feed pressure sags, so thrust decays at a fixed valve position @zimmerman2013_tank. A 60 s hover is exactly the burn where that matters.

That temperature dependence is the N₂O-specific chamber-pressure ceiling that @sec-sizing-basis deferred. Throttle-valve drop, injector drop, and chamber pressure must all fit under the *coldest credible end-of-burn tank pressure*, not under the 760 psia of a 20°C full tank. Holding ≈20% of $P_c$ for injector stiffness @huzel1992, a 150 psia chamber asks for ≈180 psia at the injector inlet and still leaves roughly 270 psi of valve authority on a 0°C morning before self-cooling sag; a 300 psia chamber asks for ≈360 psia and leaves under 100 psi on the same morning. The 150 psia baseline therefore fits self-pressurized N₂O with usable throttle margin; anything much above the 200 psia upgrade case needs a warm-tank-only envelope or oxidizer supercharge.

#warn-box("Las Vegas design-basis implication")[
A N₂O tank in direct summer sun can approach or exceed the 36.4°C critical temperature. The baseline control map should be built around measured tank temperature and pressure, and the pressure-vessel MEOP check should use the highest credible tank temperature, not just nominal room temperature. Testing in shade or morning conditions is not a convenience; it is part of keeping the feed model inside the calibrated regime.
]

When saturated liquid N₂O accelerates through valves and injector passages, pressure reduction can initiate flashing before the chamber. The standard single-phase incompressible equation is therefore only a bounding model:

$ dot(m) = C_d A sqrt(2 rho Delta P) $

N₂O injector design should bracket the flow with SPI and HEM and then use a non-equilibrium model such as Dyer/NHNE for the design estimate. Published work on self-pressurizing propellant flow and N₂O injectors supports this SPI/HEM/NHNE framing @dyer2007 @waxman2013 @solomon2011 @zimmermann2022.

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

The AEL Snark work is the most relevant single data point because it is a 300 N N₂O/IPA thruster built for a VTVL vehicle: this thrust class, this propellant pair, this mission @waugh2018. Two of its measured results show how far the system sits from textbook hydraulics. First, the N₂O injector pressure drop was found to be almost independent of massflow, because flash-boiling in the control valve and flash-boiling in the injector elements balance each other; the familiar square-law relation between orifice pressure drop and massflow simply does not hold. Second, chamber pressure varied almost linearly with the throttle-valve command, and the closed-loop controller was designed around a second-order transfer function identified from test data, not derived from first principles @waugh2018. At O/F near 5 the oxidizer is more than 80% of the total flow, so the side of the engine that resists analysis is also the side that dominates it.

The practical consequence is concrete. I cannot pre-compute a valve schedule, an injector pressure-drop margin, or a throttle map for the N₂O engine and trust them. I can only bracket them with SPI/HEM/NHNE and then buy the real answer with a calibration matrix of hot fires across tank temperatures and throttle setpoints. That campaign is a real budget line — about \$670--\$1,200 of propellant for ten 200 N, 60 s fires at the sourced prices — and it is the main technical reason not to over-score N₂O just because its tanks are compact.

N₂O also carries a hazard GOX does not: it is a monopropellant-capable oxidizer whose ullage can decompose energetically if an ignition source reaches it, and hydrocarbon contamination catalyzes that decomposition @karabeyoglu2008. The mitigation overlaps with GOX practice — oxidizer-clean plumbing, no oil or grease, care with adiabatic compression — so choosing N₂O does not buy exemption from cleanliness discipline. The fair counterpoint from the same work is that N₂O decomposition kinetics are roughly six orders of magnitude slower than H₂O₂ at comparable conditions, which is part of why it remains the standard amateur oxidizer @karabeyoglu2008.

=== GOX / Ethanol
#figure(
  image("rocket_outputs/figures/GOX_Ethanol_of_isp_and_oxidizer_mass.png", width: 100%),
  caption: [Individual O/F curve. The dashed curve in each panel is oxidizer mass required for a 200 N, 60 s burn.],
) <fig-of-OF-curve-GOX-ethanol>

GOX/ethanol has a more useful fuel-rich knob because oxygen storage is the GOX penalty. At the 200 N, 60 s reference burn, O/F = 1.30 saves about 0.19 kg GOX, or 5.8%, with a 2.9 s computed $I_"sp"$ loss; this may be worth checking if tank volume is the limiting item. Pushing to O/F = 1.20 saves 0.25 kg GOX, or 7.6%, but loses 6.4 s and increases ethanol mass. The useful trade window is narrow, around O/F = 1.30--1.55, not simply "as fuel-rich as possible" @cea_hopper_runs_2026.

GOX/ethanol survives as the cleanest single-phase oxidizer alternative if the N₂O two-phase injector problem becomes unacceptable. The sea-level ambient-corrected computed performance is $I_"sp,SL" = 225.6 "s"$ at O/F = 1.55 and $epsilon = 2.45$ @cea_hopper_runs_2026. It gives simpler single-phase oxidizer metering and stable regulator-fed pressure; the system-level cost of that simplicity is quantified in @sec-sourcing.

A NASA ignition characterization program tested GOX/ethanol at 150 psia and O/F = 1.8, making this the best-documented GOX/alcohol reference point near the sizing-basis chamber pressure @nasa1984. Oxygen-side hardware must be oxygen-cleaned and kept free of hydrocarbon contamination; the oxygen-cleaning and material-control burden is real, not paperwork @cga_g41.

#finalist-box[*Standing after analysis.* Preferable GOX fuel on nearby ignition-validation evidence. System-level storage, regulator mass, and oxygen-clean hardware remain the architecture penalties, independent of the alcohol choice.]

=== GOX / IPA
#figure(
  image("rocket_outputs/figures/GOX_IPA_of_isp_and_oxidizer_mass.png", width: 100%),
  caption: [Individual O/F curve. The dashed curve in each panel is oxidizer mass required for a 200 N, 60 s burn.],
) <fig-of-OF-curve-GOX-ipa>

GOX/IPA is less forgiving on the rich side. Dropping O/F from 1.65 to 1.40 saves about 0.17 kg GOX, or 5.1%, while losing 3.0 s, which could be tolerable if cylinder volume is marginal. Dropping to O/F = 1.20 saves only another 0.10 kg GOX beyond that but loses 10.9 s total, so the storage saving is not enough to justify the performance loss. If GOX/IPA is used, I would stay near O/F = 1.40--1.65 unless hot-fire stability points elsewhere @cea_hopper_runs_2026.

GOX/IPA has the best sea-level ambient-corrected computed performance in this set: $I_"sp,SL" = 230.1 "s"$ at O/F = 1.65 and $epsilon = 2.43$ @cea_hopper_runs_2026. The fuel is cheaper than anhydrous ethanol, and per @sec-sourcing that makes GOX/IPA the cheapest campaign in the whole set on consumables. The expensive pieces are the high-flow oxygen regulator, oxygen-compatible valves, and cleaning, not the cylinder; the itemized architecture cost is in @sec-sourcing. The main GOX advantage is single-phase oxygen metering, which neither alcohol changes; GOX/ethanol has stronger nearby ignition-validation evidence.

#finalist-box[*Standing after analysis.* Highest computed $I_"sp"$ and cheapest pure static-fire consumables path. Does not solve the GOX storage/regulator flight penalty.]

== Pump Option Check

The hard rule is no turbopumps, not no pumps. I am still keeping the first-article survivor comparison pressure-fed because the pump does not remove the dominant oxidizer problems. For N₂O, self-pressurization is the benefit, and published injector work still treats pump/supercharge conditions as ways to set tank state or avoid cavitation, not as a way to eliminate flashing physics @waxman2013. For GOX, a small electric liquid pump is not available because cryogenic LOX is screened out, and a gas compressor/feed pump would add oxygen-clean rotating hardware, battery power, controls, and heat without solving the large gas-storage requirement.

A small electric fuel pump remains allowed. It may become attractive later if the fuel tank or fuel pressurant mass dominates the vehicle, especially because IPA/ethanol are ordinary liquids compared with the oxidizers. I am not adding it to the baseline yet because it adds a controller, battery/current margin, bypass or relief path, transient calibration, and a new single-point failure while leaving the oxidizer architecture unchanged.

The main performance lever a pump or supercharge would buy is chamber pressure beyond the pressure-fed feed-margin band in @sec-sizing-basis. @fig-pressure-sensitivity prices that lever for the four alcohol survivors after screening: about +11--12 s of sea-level $I_"sp"$ from 150 to 200 psia and +24--28 s from 150 to 300 psia, with diminishing returns. That gain is worth carrying as the 200 psia upgrade case; it is not worth new oxidizer-side rotating hardware for the first article.

#figure(
  image("rocket_outputs/figures/pressure_sensitivity.png", width: 100%),
  caption: [Sea-level ambient-corrected $I_"sp"$ vs chamber pressure for the four alcohol survivors after screening (shifting equilibrium, $P_e approx P_"amb"$ nozzle) @cea_hopper_runs_2026.],
) <fig-pressure-sensitivity>

=== Does higher $P_c$ make GOX more reasonable?

A fair objection to the GOX storage penalty is that the thruster comparison was frozen at 150 psia, and GOX has higher ideal $I_"sp"$ — so perhaps raising $P_c$ shrinks the thruster and propellant mass enough to change the architecture trade. I checked that claim against the same pressure sweep rather than arguing it away.

On pure CEA performance, higher $P_c$ does *not* close the GOX-to-N₂O gap. At sea-level-matched expansion, GOX/IPA minus N₂O/IPA is about 23 s at 150 psia, 25 s at 200 psia, and 27 s at 300 psia; GOX/ethanol minus N₂O/IPA is about 19 s, 20 s, and 22 s over the same pressures @cea_hopper_runs_2026. Absolute $I_"sp"$ rises for every pair, but the *ordering is unchanged* and the GOX advantage over N₂O widens slightly rather than shrinks. Peroxide pairs were only computed at 150 psia; they were removed for sourcing and handling, not because a pressure sweep would have saved them.

On feed and storage physics, higher $P_c$ makes regulated GOX *worse*, not better, for a pressure-fed first article. Injector inlet pressure still needs ≈1.2 $P_c$ under the Huzel stiffness allowance @huzel1992, so a 300 psia chamber asks for ≈360 psia at the injector before valve and line losses. That raises the regulator delivery setpoint and therefore the usable blowdown floor on a fixed 2265 psia service cylinder: less of the fill is usable, so stored mass and cylinder class grow for the same burned oxygen. N₂O has its own high-$P_c$ problem (cold-tank saturation pressure and valve authority), documented in @sec-n2o-risk, but that is a reason to keep $P_c$ modest for a self-pressurized oxidizer — not a reason to switch to GOX. The conclusion feeds the selection below rather than assuming it: $P_c$ steers thruster and tank *sizing*, not the propellant architecture decision. Higher chamber pressure does not reverse the GOX storage/regulator penalty, so it should not be used as a reason to pick GOX over a liquid oxidizer at this vehicle class.

== Cryogenic Reconsideration: LOX <sec-lox>

The no-cryogenics rule was written from fear of complexity, so before selecting I am testing it against numbers instead of instinct — especially since both surviving oxidizers carry a structural penalty: GOX pays in tank tare, regulator hardware, and storage volume; N₂O pays in two-phase calibration and thermal sensitivity. LOX removes both at once. It is a dense, single-phase liquid at the injector (about 1,141 kg/m³ at its normal boiling point @nist_oxygen), it stores at low dewar pressure instead of as 2265 psia gas, and it is the cheapest oxidizer I can document: FAR sells 230 L, roughly 262 kg, for \$540 — about \$2/kg — and a trade source reports \$200-class quotes for a 180 L dewar @far_propellants @hvo_oxygen_cost.

It also has the deepest small-VTVL heritage of any candidate in this notebook, which the hard screen ignored. Masten's Xombie flew a regeneratively cooled LOX/IPA engine 227 times, Xodiac flew pressure-fed LOX/IPA, and Armadillo's Pixel and Mod vehicles flew pressure-fed LOX/ethanol through the Lunar Lander Challenge @masten_wikipedia @spaceref_xombie @armadillo_wikipedia. The propellant family with the most small hover-flight history is not N₂O/alcohol; it is LOX/alcohol.

The bill on the other side is operational, and it is real: cryo-rated valves and seals, thermal contraction and icing, a chilldown procedure, boiloff that forbids long holds and forces load-late operations, dewar logistics (deposit, rental, transport), the same CGA G-4.1 oxidizer cleanliness as GOX @cga_g41, and oxygen-enrichment PPE. Decisive at this scale: LOX is not usefully self-pressurizing, so a pressure-fed LOX system reintroduces the high-pressure pressurant bottle and regulator that the N₂O architecture avoids. It buys back GOX-style feed hardware and adds cryogenic operations on top of it.

The screen therefore stands for the first article, but as a recorded decision with a reopen condition rather than a closed door: if the N₂O calibration campaign runs past roughly 15--20 hot fires without converging, or the field thermal envelope cannot be held, LOX/IPA is the rational pivot with the most direct heritage, and the no-cryogenics requirement would be formally waived at that point.

== Select Best Solution

The high GOX performance and simple single-phase metering are real, and the campaign figure in @sec-sourcing shows GOX/IPA is genuinely the cheapest pure static-fire program, paying back its hardware premium in about 15 hot fires. Raising chamber pressure does not reverse that architecture trade: the pressure sweep keeps the same rank order and slightly widens the GOX-to-N₂O $I_"sp"$ gap, while a higher regulated delivery pressure hurts GOX blowdown usable fraction (@fig-pressure-sensitivity). But the requirement is a hopper, and the quantified GOX penalty is really two distinct penalties. The budget penalty is \$1,190--\$1,870 of oxidizer-side hardware, nearly all of it regulator and oxygen-clean components rather than the cylinder. The flight penalty is the decisive one: mapped across the whole thrust/burn envelope, GOX storage carries about 7 kg of steel per kilogram of usable oxygen against about 1.5 kg/kg for a nitrous bottle, and a flight-weight composite oxygen vessel would fix the tare while making the budget worse. The high peroxide density is also real, but sourcing and decomposition risk dominate.

N₂O wins as an architecture, not as a propellant. Per kilogram it is the most expensive oxidizer in the finalist set, and @sec-n2o-risk records that it is the only finalist whose injector and throttle cannot be closed analytically, so the selection explicitly buys a calibration campaign. What it buys back is that the storage bottle is also the pressurization system, the first fire is the cheapest to reach, and the closest public analog to this exact mission flew on it @kistler2024.

#finalist-box[*Baseline propellant selection: N₂O / IPA.* N₂O/IPA is not selected because it is analytically easy; it is selected because it best fits the full hopper constraint set: compact self-pressurizing oxidizer storage, cheap and accessible fuel, and the most relevant small-VTVL flight precedent. The design must explicitly budget the N₂O two-phase modeling and hot-fire calibration matrix as its own line item — about \$670--\$1,200 of propellant for a ten-fire matrix at 200 N, 60 s.]

The best alternatives are conditional. *GOX/ethanol* is the cleanest technical alternate if avoiding two-phase N₂O behavior is worth the tank/regulator mass and cost. *N₂O/ethanol* remains the fuel backup if the project chooses to align with N₂O/ethanol literature or needs ethanol's higher thermal conductivity for cooling margin. *GOX/IPA* is credible and has the best computed $I_"sp"$, but it is not the reference GOX fuel because the fuel choice does not solve the GOX storage/regulator problem and GOX/ethanol has stronger nearby ignition-validation evidence. *LOX/IPA* is the documented growth path: @sec-lox records the reopen condition and the flight heritage that supports it.

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
