= Design Requirements

Goal:

- Design a throttleable liquid bipropellant engine capable of lifting, hovering, and controlling a minimal VTVL hopper vehicle — a structure that exists solely to support the engine's required subsystems. No payload, no altitude target.

What does success look like?

- Simulate stable combustion for the full burn duration (60 sec target) at 100%, 66%, and 33% thrust. No instabilities at any throttle point. Structural margins positive at all operating conditions. Confirm $T/W gt 1.0$ at hover throttle setting for the expected vehicle mass.

Requirements:

- Design if built be under \$5000 (not including fuel)
- Pressure-fed
- No cryogenics
- Design the system to be stable such that any possible instability is found and avoided within a minimum margin of 20%
- Materials must be machinable and readily accessible such as aluminum or stainless steel
- Standard AN/MS hardware and Swagelok-compatible tube fittings only. No custom fluid connectors
- All pressure-wetted components (chamber, tanks, lines) shall be designed to a burst factor of safety $gt.eq 4 times$ MEOP (Maximum Expected Operating Pressure)
- Throttle range $30->100%$ of full thrust. Minimum throttle must be below hover $T/W = 1.0$ for the expected vehicle mass, so the engine can command descent. O/F ratio shall remain within ±15% of optimum across the full throttle range.
- Specific impulse Isp ≥ 230 s sea level (hard minimum). Target $~250->260 s$ depending on propellant selection. To be computed via CEA at optimum $O/F$ and $"Pc" = 150$ psi baseline.
- Engine dry mass target $lt.eq 2.5$ kg (chamber + nozzle + injector + cooling jacket). Target $1.0->1.5$ kg.
- TVC interface: Engine assembly shall include a defined gimbal hard point or flange interface for future TVC integration. Geometry TBD, but the interface must not be retroactively blocked by cooling jacket or plumbing routing.

Derived Requirements:
- 400 N (90 lbf) nominal. Acceptable range: $300->500 N$. Final value to be confirmed after vehicle mass estimation converges. Must satisfy $T/W$ ≥ 1.5 at GLOW at full throttle.
Rationale: Sized to hover a 10–20 kg vehicle with throttle margin. At 400 N on a 15 kg vehicle, $T/W = 2.7$ at full thrust; hover throttle is ~37% ($148 N approx 15 "kg" g$). This is the correct hopper operating envelope — low $T/W$ means throttle range actually spans from climbing to descending.

- Burn time Minimum 30 seconds. Design target 60 seconds. At $(400 N) / (260 s)$ Isp: $30 "sec" = 4.7 "kg propellant"$; 60 sec = 9.4 kg propellant.
Rationale: 30 sec is enough to demonstrate a meaningful flight profile. 60 sec gives room for an ascent, hover, translation, and descent sequence — a proper hopper demonstration. Both are feasible at this thrust level without large tanks.

- Chamber pressure (Pc) $100->200$ psi. Baseline: 150 psi. Lower than previous revision because smaller engine diameter means thinner walls at the same stress, and lower Pc reduces pressurant requirements, simplifying the feed system.
Rationale: The performance penalty of lower Pc is small: dropping from 200 to 150 psi costs roughly $3–>5$ s of Isp. For a hopper where propellant mass is $5–>10$ kg anyway, this has negligible impact on mission duration. Simpler feed system and cheaper valves are worth more than those $3–>5$ seconds.

= Propelant Choice

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
