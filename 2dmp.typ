// ============================================================
// A STEP-BY-STEP GUIDE TO 2D MOTION PROFILING USING BÉZIER CURVES
// Differential drive
// ============================================================
#set page(
  paper: "us-letter",
  margin: 1in,
  numbering: "1",
  header: context {
    // Title page carries no running head, matching the LaTeX `plain` style.
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(120))
      [2D Motion Profiling] + h(1fr) + [Differential Drive]
      v(-0.6em)
      line(length: 100%, stroke: 0.4pt + luma(160))
    }
  },
)

#set text(size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")

// Code listing box, mirroring the framed grey lstlisting style.
#let listing(body) = block(
  width: 100%,
  fill: luma(242),
  stroke: 0.5pt + luma(150),
  inset: 10pt,
  radius: 2pt,
  breakable: true,
)[
  #set text(size: 8.6pt)
  #body
]

#let deeper(title, body) = block(
  width: 100%,
  fill: rgb("#f4f7fa"),
  stroke: (left: 2pt + rgb("#5b8db8")),
  inset: (x: 10pt, y: 9pt),
  radius: (right: 2pt),
  breakable: true,
)[
  #text(size: 9.5pt, weight: "bold", fill: rgb("#2f5d80"))[
    Going deeper: #title
  ]
  #v(0.35em)
  #set text(size: 10pt)
  #body
]

// =============================================================
// TITLE BLOCK
// =============================================================

#v(1em)
#align(center)[
  #text(size: 17pt, weight: "bold")[
    An Extended Guide and Derivation to 2D Motion Profiling for Differential Drivetrains Using Bézier Curves
  ]
  #v(0.8em)
]

#v(1.5em)

#outline()

#pagebreak()

= What is Motion Profiling and What is the Point of This?

As the name suggest motion profiling profiles a motion, specifically deriving characteristcs about a movement. Specifically it derives in most cases velocities and/or derivatives of it.

The main goal for this paper is to derive the 2d motion profile a differential drivetrain moving along a curve restricted by dynamics of the drivetrain and other keyframes we may input for desired states along that curve.

Specifically we want to follow a curved path while:

- Respecting maximum speed and acceleration
- Slowing down for turns (based on curvature)
- Hitting specified speeds at key positions (keyframes)

To do that, we describe the path mathematically and then compute how the robot
should move along it.

In the end we will need to compute the following

+ Compute $v_"max"$: the robot's absolute maximum speed (a constant limit).

+ Compute $v_"accel"$: the speed limit imposed by the maximum acceleration.

+ Compute $v_"brake"$: the speed limit that guarantees the robot can still
  decelerate to the exit velocity $v_"end"$ by the end of the path.

+ Compute $v_"curve"$: the speed limit due to curvature at the robot's current
  position.

+ Compute $v_"interp"$: the speed dictated by keyframe interpolation (the speed profile we desire).

And take the minimum of them and apply that velocity to the robot linearly and compute the necessary angular velocity for that linear velocity and set the robots velocity to that.

= Curve Representation Options

There are multiple ways to describe a smooth curve (and probably many many more):

- *Quadratic Bézier Curve:* Uses 3 control points (a start point, end point, and
  one middle control point) to form a smooth curve. It is simple but less
  flexible in shaping the path.
- *Cubic Bézier Curve:* Uses 4 control points (start, end, and two control
  points). This gives more control over the curve's shape. We use cubic Béziers
  here for a good balance of simplicity and flexibility.
- *Cubic Hermite Splines:* Defined by endpoints and specified tangents (slopes)
  at those endpoints. This means you explicitly set the direction of travel at
  each end, resulting in a smooth curve that honors those directions.
- *Catmull--Rom Splines:* A type of spline that passes through a series of given
  waypoints. The curve is calculated to smoothly interpolate through all the
  points, making it easy to create paths through specific locations.

Here I chose the cubic Bézier for its balance of simplicity and control @farin. The
following are the functions that describe the x and y coordinates of the cubic
Bézier curve.

$
  x(t) & = (1 - t)^3 x_0 + 3(1 - t)^2 t thin x_1 + 3(1 - t) thin t^2 x_2 + t^3 x_3 \
  y(t) & = (1 - t)^3 y_0 + 3(1 - t)^2 t thin y_1 + 3(1 - t) thin t^2 y_2 + t^3 y_3
$

== Finding $v_"max"$

The robot's absolute top speed, $v_max$. A constant, measured empirically or
taken from the motor's free speed and gear ratio. Nothing to derive.

== Finding $v_"accel"$

The robot's speed can only change by $a_max thin Delta t$ in one timestep, so

$ v_"accel" = v(t) + a_max thin Delta t, $

where $v(t)$ is the current commanded speed. This is what keeps the profile from
demanding an instantaneous jump in velocity that the drivetrain cannot deliver.

== Finding $v_"brake"$

This limit guarantees the robot can still decelerate to its exit velocity
$v_"end"$ by the time the path runs out. From @sec-kinematics, the distance
needed to slow from $v_max$ to $v_"end"$ at maximum deceleration is

$ d_"decel" = (v_max^2 - v_"end"^2)/(2 dot a_max). $

While the remaining distance $d_"remaining"$ exceeds $d_"decel"$, braking imposes
no limit at all. Once $d_"remaining" <= d_"decel"$, we want the largest speed $v$
from which the robot can still reach $v_"end"$ within $d_"remaining"$. Applying
the same kinematic equation over the remaining distance:

$
  v_"end"^2 = v^2 - 2 dot a_max dot d_"remaining"
  quad ==> quad
  v_"brake" = sqrt(v_"end"^2 + 2 dot a_max dot d_"remaining").
$

This is the deceleration ramp of a trapezoidal profile, expressed as a function
of distance-to-go: at $d_"remaining" = d_"decel"$ it equals $v_max$, and at
$d_"remaining" = 0$ it equals $v_"end"$.

== Finding $v_"curve"$ <sec-vcurve>

The wheels of a differential drive robot have a maximum speed. In a turn, the
outer wheel travels faster than the robot's center, so the center must slow down
to keep the outer wheel within its limit @lavalle @wpilib:

$ v_"curve"(t) = v_max dot R(t)/(R(t) + w/2), $

where $w$ is the track width (the distance between the left and right wheels) and
$R(t)$ is the radius of curvature. On a straight path
$R -> infinity$ and the limit relaxes to $v_max$; in a hairpin $R -> 0$ and it
drives the speed toward zero.

#deeper("deriving the curvature speed limit")[
  Start from the differential drive kinematic equations @lavalle:

  $ V_l = v - r dot omega quad "and" quad V_r = v + r dot omega, $

  where $v$ is linear velocity, $omega$ is angular velocity, and $r = w\/2$ is the
  distance from the center of the robot to either wheel. Since $omega = v dot
  kappa$ by definition of angular velocity, substituting and factoring gives

  $ V_l = v dot (1 - r dot kappa), quad V_r = v dot (1 + r dot kappa). $

  Each wheel must stay within its maximum velocity:

  $
    abs(v dot (1 - r dot kappa)) <= v_max, quad
    abs(v dot (1 + r dot kappa)) <= v_max.
  $

  Since $v >= 0$ we can pull $v$ out of the absolute value and divide:

  $ max(abs(1 - r dot kappa), thin abs(1 + r dot kappa)) <= v_max/v. $

  That maximum is always $1 + abs(r dot kappa)$, so

  $
    1 + abs(r dot kappa) <= v_max/v
    quad => quad
    v <= v_max/(1 + abs(r dot kappa)).
  $

  Finally, substituting $abs(kappa) = 1\/R(t)$ gives the geometric form:

  $ v <= v_max/(1 + r\/R(t)) = v_max dot R(t)/(R(t) + r). $
]

= Arc Length via Gaussian Quadrature

For a parametric curve $bold(r)(t) = (x(t), y(t))$, the arc length from the start
up to parameter $t$ is

$ s(t) = integral_0^t norm(bold(r)'(tau)) thin d tau, $

the integral of speed $norm(bold(r)'(tau))$ along the curve. We approximate this
integral with Gaussian quadrature, following the approach used for arc-length
parameterization of spline curves @wang:

$
  integral_a^b f(x) thin d x approx (b - a)/2 sum_(i=1)^n w_i thin f((b - a)/2 x_i + (a + b)/2).
$

*Numerical integration rationale.*
For most curves, there isn't a simple formula for $s(t)$ (and this is true for Cubic Bézier Curves), so we need to integrate numerically. Gaussian quadrature is one effective method for numerical integration. It chooses special sample points (nodes $x_i$) and weights $w_i$ to maximize accuracy. An $n$-point Gauss--Legendre rule is exact for all polynomials up to degree $2n - 1$, meaning it integrates any such polynomial perfectly on
$[-1, 1]$ with only $n$ evaluations of $f$.

To illustrate, the 2-point Gaussian rule on $[-1, 1]$ picks

$ x_1 = -1/sqrt(3), quad x_2 = 1/sqrt(3), quad quad w_1 = w_2 = 1, $

so that

$ integral_(-1)^1 f(x) thin d x approx f(-1/sqrt(3)) + f(1/sqrt(3)), $

which integrates any cubic polynomial exactly.

*Table of Nodes and Weights.*
The following table lists the Gauss--Legendre nodes $x_i$ and weights $w_i$ on
the standard interval $[-1, 1]$ for $n = 2, 3, 4, 5$, as tabulated in standard
references @gauss. These are the constants you plug into the formula above; the
$n = 5$ row is the one my implementation actually uses.

#align(center)[
  #table(
    columns: 3,
    align: (center, left, left),
    stroke: none,
    inset: (x: 10pt, y: 5pt),

    table.hline(stroke: 1pt),
    table.header([*$n$*], [*$x_i$* (nodes)], [*$w_i$* (weights)]),
    table.hline(stroke: 0.5pt),

    table.cell(rowspan: 2)[2], $-1/sqrt(3) approx -0.577350$, $1$,
    $+1/sqrt(3) approx 0.577350$, $1$,
    table.hline(stroke: 0.5pt),

    table.cell(rowspan: 3)[3],
    $-sqrt(3/5) approx -0.774597$,
    $5/9 approx 0.555556$,
    $0$, $8/9 approx 0.888889$,
    $+sqrt(3/5) approx 0.774597$, $5/9 approx 0.555556$,
    table.hline(stroke: 0.5pt),

    table.cell(rowspan: 4)[4], $-0.861136$, $0.347855$,
    $-0.339981$, $0.652145$,
    $+0.339981$, $0.652145$,
    $+0.861136$, $0.347855$,
    table.hline(stroke: 0.5pt),

    table.cell(rowspan: 5)[5], $-0.906180$, $0.236927$,
    $-0.538469$, $0.478629$,
    $0$, $128\/225 approx 0.568889$,
    $+0.538469$, $0.478629$,
    $+0.906180$, $0.236927$,
    table.hline(stroke: 1pt),
  )
]

*Application to Arc Length.*
In our arc-length integral, set

$ f(tau) = norm(bold(r)'(tau)), quad a = 0, quad b = t, $

and use the above $x_i, w_i$ with

$ tau_i = (b - a)/2 thin x_i + (a + b)/2 = t/2 thin x_i + t/2, $

to compute

$ s(t) approx t/2 sum_(i=1)^n w_i thin norm(bold(r)'(tau_i)). $

*Why one panel is not enough.* For a cubic Bézier the integrand
$norm(bold(r)'(tau))$ is the _square root_ of a polynomial, not a polynomial
itself, so the "exact for degree $2n - 1$" guarantee does not apply at all --- no
choice of $n$ makes a single application of the rule exact here. What the rule
still gives is fast convergence for smooth integrands, and that convergence is
much faster on short intervals than on long ones. On a long or wiggly curve a
single $n = 5$ panel spanning all of $[0, t]$ leaves error large enough to
misplace the robot; the fix is _composite_ quadrature, splitting the interval
into $m$ equal panels and applying the rule on each @wang:

$
  s(t) approx sum_(j=0)^(m-1) h/2 sum_(i=1)^n w_i thin
  norm(bold(r)'(h j + h/2 (x_i + 1))),
  quad quad h = t/m.
$

I use $n = 5$ nodes with $m = 8$ panels, so each call costs 40 evaluations of
$norm(bold(r)')$. Accuracy still degrades near degenerate curves (control-point placements where
$norm(bold(r)')$ approaches zero, creating a cusp), where further subdivision is
the remedy @wang.

= Finding the Next Parameter: Newton--Raphson

To move a small distance $Delta s$ along the path, we need to find the new
parameter $t_"next"$ such that

$ s(t_"next") = s_"current" + Delta s. $

We use Newton--Raphson (a root-finding method) to solve this equation, the same
combination of Gaussian quadrature and Newton iteration used in @wang:

$
  t_(k+1) = t_k - (s(t_k) - (s_"current" + Delta s))/norm(bold(r)'(t_k)).
$

*Why Newton's method?* We want to solve

$ F(t) = s(t) - (s_"current" + Delta s) = 0 $

for $t$. Newton--Raphson is an efficient iterative technique that uses the
derivative $F'(t) = s'(t) = norm(bold(r)'(t))$. Note that this is the
_parametric_ speed of the curve (how fast the point moves as $t$ changes), not
the robot's commanded velocity. Starting from an initial guess $t_k$, we linearize and obtain

$
  t_(k+1) = t_k - F(t_k)/(F'(t_k))
  = t_k - (s(t_k) - (s_"current" + Delta s))/norm(bold(r)'(t_k)).
$

In practice each iterate should also be clamped to the valid parameter range
$t in [0, 1]$; if Newton's method fails to converge within $k_max$ iterations
(possible when $norm(bold(r)')$ is very small), falling back to bisection (essentially like a binary search algorithm for finding a zero) is a robust remedy @wang.

*Stopping criterion.* We iterate $k = 0, 1, 2, dots$ until one of the following
is met:

$
  abs(t_(k+1) - t_k) < epsilon
  quad "or" quad
  abs(s(t_k) - (s_"current" + Delta s)) < epsilon
  quad "or" quad
  k >= k_max,
$

where $epsilon > 0$ is a chosen tolerance (e.g. $10^(-6)$) and $k_max$ (e.g.
$10$) caps the number of iterations to avoid infinite loops. This ensures we stop
once the update or the residual is sufficiently small, or when we've reached a
safe iteration limit.

= Acceleration and Deceleration Distances <sec-kinematics>

From basic kinematics:

$
  v^2 = v_0^2 + 2 a thin Delta s
  quad ==> quad
  Delta s = (v^2 - v_0^2)/(2 a),
$

which tells us the distance needed to change speed under constant acceleration
$a$.

- If $a > 0$: $Delta s$ is the distance needed to *accelerate* from $v_0$ up to
  $v$.
- If $a < 0$: $Delta s$ is the distance needed to *decelerate* (brake) from $v_0$
  down to $v$.

*Why it works.* This formula is derived by integrating acceleration over
distance:

$
  a = (d v)/(d t)
  quad => quad
  v thin d v = a thin d s
  quad => quad
  integral_(v_0)^v v thin d v = integral_0^(Delta s) a thin d s
  quad => quad
  (v^2 - v_0^2)/2 = a thin Delta s,
$

so rearranging gives $Delta s = (v^2 - v_0^2) / (2 a)$.

= Curvature and Turning Speed

For a 2D path $bold(r)(t) = (x(t), y(t))$, the _signed_ curvature is defined as:

$
  kappa(t)
  = (x'(t) y''(t) - y'(t) x''(t))/((x'(t)^2 + y'(t)^2)^(3\/2)),
  quad quad
  R(t) = 1/abs(kappa(t)),
$

where $R(t)$ is the radius of curvature at that point on the path. The sign of
$kappa$ tells us the turn direction (positive for a left turn, negative for a
right turn, with the usual counterclockwise convention). The speed limit below
only depends on $abs(kappa)$, but the sign matters later: the commanded angular
velocity is $omega = v kappa$, so if we dropped the sign the robot could only
ever turn one way.

*What to do at a cusp.* The denominator $norm(bold(r)'(t))^3$ collapses to zero
where the parametric speed vanishes, and the formula is undefined there. It is
tempting to return $kappa = 0$ to avoid the division, but that is exactly
backwards: a cusp is the _sharpest_ point on the path, geometrically a turn of
zero radius, so $abs(kappa) -> infinity$. Returning zero would remove the
curvature speed limit precisely where it is needed most and send the robot
through the cusp at full speed. The safe convention is to saturate $abs(kappa)$
at a large finite value (keeping the sign of the cross product where it is still
recoverable, so the turn direction survives). The limit
$v_"curve" = v_max dot R\/(R + w\/2)$ then drives $v -> 0$ as $R -> 0$, and since
$omega = v kappa$ the angular velocity tends to
$omega -> 2 v_max \/ w$ --- the robot turning in place at the drivetrain's maximum
rate, which is the physically correct behaviour at a cusp. The same degeneracy
breaks the Newton iteration of the previous section, because $norm(bold(r)')$ is
its derivative; that's where the bisection algorithm would fit.

The wheels of a differential drive robot have a maximum speed. In a turn, the
outer wheel travels faster than the robot's center, so the center must slow down
to keep the outer wheel within its limit @lavalle @wpilib. We therefore restrict
speed using:

$ v_"curve"(t) = v_max dot R(t)/(R(t) + w/2), $

where $w$ is the track width (distance between the left and right wheels).

*Why it works.*
We start with the differential drive kinematic equations @lavalle:

$ V_l = v - r dot omega quad "and" quad V_r = v + r dot omega, $

where $v$ is the linear velocity, $omega$ is the angular velocity, and $r$ is
half the track width (the distance from the center of the robot to either wheel).

We also know that $omega = v dot kappa$, by the definition of angular velocity,
where $kappa$ is the curvature of the path. Substituting into the equations and
factoring gives:

$ V_l = v dot (1 - r dot kappa), quad V_r = v dot (1 + r dot kappa). $

Each wheel must stay within its maximum velocity, so we create two inequalities:

$
  abs(v dot (1 - r dot kappa)) <= v_max, quad
  abs(v dot (1 + r dot kappa)) <= v_max.
$

Since $v >= 0$, we can take $v$ out of the absolute value and divide both sides:

$ max(abs(1 - r dot kappa), thin abs(1 + r dot kappa)) <= v_max/v. $

Noting that the maximum of $abs(1 - r dot kappa)$ and $abs(1 + r dot kappa)$ is
always $1 + abs(r dot kappa)$, we simplify to:

$
  1 + abs(r dot kappa) <= v_max/v
  quad => quad
  v <= v_max/(1 + abs(r dot kappa)).
$

This tells us how fast the center of the robot can move without exceeding the
speed limit of either wheel during a turn.

Now, since $abs(kappa) = 1/R(t)$, where $R(t)$ is the radius of curvature of the
path, we can substitute $abs(r dot kappa) = r/R(t)$. Plugging this into the
inequality gives:

$ v <= v_max/(1 + r/R(t)) = v_max dot R(t)/(R(t) + r). $

This gives the final form:

$ v_"curve"(t) = v_max dot R(t)/(R(t) + r), $

which is a more geometric way of expressing the speed limit based on curvature
and robot geometry.

= Keyframes: Localisation and Velocity Interpolation

== Locating a Keyframe on the Path

A path editor hands me keyframes as $(x, y, v)$: a point the user clicked on the
field and the speed they want there. Everything downstream is indexed by the
curve parameter $t$, so the first job is to turn that point $bold(p) = (x, y)$
into a parameter.

The tempting shortcut is to solve $x(t) = x_"kf"$ for $t$ and ignore $y$. That is
wrong on any path that revisits an $x$ coordinate --- an S-curve, a loop, or
anything that doubles back --- because the equation then has several roots and
nothing in it distinguishes the intended one from a branch of the path metres
away. It also fails outright when the keyframe sits slightly off the curve, since
$x(t) = x_"kf"$ may have no solution in $[0, 1]$ at all.

The correct question is a projection: which point of the curve is closest to
$bold(p)$?

$
  t^* = limits(min)_(t in [0, 1]) norm(bold(r)(t) - bold(p))^2.
$

Differentiating the objective gives the stationary condition

$
  d/(d t) norm(bold(r)(t) - bold(p))^2 = 2 (bold(r)(t) - bold(p)) dot bold(r)'(t) = 0,
$

which says the error vector is orthogonal to the tangent. Writing
$g(t) = (bold(r)(t) - bold(p)) dot bold(r)'(t)$, Newton's method applies again
with

$
  g'(t) = norm(bold(r)'(t))^2 + (bold(r)(t) - bold(p)) dot bold(r)''(t),
  quad quad
  t_(k+1) = t_k - g(t_k)/(g'(t_k)).
$

For a cubic Bézier, $g$ is a quintic in $t$ and can have up to five roots, so the
squared distance is _not_ convex and Newton alone will happily converge to the
wrong local minimum. I therefore scan a coarse grid (64 samples) for the best
basin, refine from there, and discard the refinement if it ends up farther from
$bold(p)$ than the sampled seed.

Given $t^*$ for each keyframe, the arc-length position follows from the
quadrature of the previous section: $s_i = s(t_i^*)$.

== Interpolating Between Keyframes

Now we have pairs $(s_i, v_i)$: desired speeds $v_i$ at arc lengths $s_i$. For an
intermediate position $s$ with $s_i <= s <= s_(i+1)$, define the fraction of the
way through the interval

$ lambda = (s - s_i)/(s_(i+1) - s_i) in [0, 1]. $

The obvious move is to interpolate $v$ itself linearly in $s$. Along the path
$a = v thin (d v)/(d s)$, so a profile linear in $s$ implies

$
  a(s) = v(s) dot (v_(i+1) - v_i)/(s_(i+1) - s_i),
$

which is proportional to the current speed: the segment demands the _most_
acceleration exactly where the robot is already moving fastest, and the demand
changes continuously across an interval the planner treats as one piece.

Interpolating in $v^2$ instead fixes this:

$
  v_"interp"(s)^2 = v_i^2 + lambda thin (v_(i+1)^2 - v_i^2),
  quad quad
  v_"interp"(s) = sqrt(v_i^2 + lambda thin (v_(i+1)^2 - v_i^2)).
$

Compare this with the kinematic relation $v^2 = v_0^2 + 2 a thin (s - s_0)$ from
@sec-kinematics. They match term for term with

$ a = (v_(i+1)^2 - v_i^2)/(2 (s_(i+1) - s_i)), $

a _constant_. So interpolating in $v^2$ makes each keyframe interval a
constant-acceleration segment, which is the same shape as every other limit in
the planner.

= Velocity Planning Algorithm

Ok, now we put it all together. At every time step we compute several candidate speed limits and command
the smallest one:

+ Compute $v_max$: the robot's absolute maximum speed (a constant limit).

+ Compute $v_"accel"$: the speed limit imposed by the maximum acceleration. Since
  the robot's speed can only change by $a_max thin Delta t$ in one time step, we
  have $v_"accel" = v(t) + a_max thin Delta t$.

+ Compute $v_"brake"$: the speed limit that guarantees the robot can still
  decelerate to the exit velocity $v_"end"$ by the end of the path. First, the
  braking distance needed to slow from $v_max$ to $v_"end"$ at maximum
  deceleration follows from the kinematic equation in @sec-kinematics (with
  $a_max > 0$):

  $ d_"decel" = (v_max^2 - v_"end"^2)/(2 dot a_max). $

  While the remaining distance $d_"remaining"$ exceeds $d_"decel"$, braking
  imposes no limit. Once $d_"remaining" <= d_"decel"$, we need the largest speed
  $v$ from which the robot can still reach $v_"end"$ within $d_"remaining"$
  (assuming a trapezoidal profile). Applying the same kinematic equation over the
  remaining distance:

  $
    v_"end"^2 = v^2 - 2 dot a_max dot d_"remaining"
    quad ==> quad
    v_"brake" = sqrt(v_"end"^2 + 2 dot a_max dot d_"remaining").
  $

  This is exactly the deceleration ramp of a trapezoidal profile, expressed as a
  function of distance-to-go: at $d_"remaining" = d_"decel"$ it equals $v_max$,
  and at $d_"remaining" = 0$ it equals $v_"end"$.

+ Compute $v_"curve"$: the speed limit due to curvature at the robot's current
  position (using the turning formula).

+ Compute $v_"interp"$: the speed dictated by keyframe interpolation at the
  current position.

All of these are upper bounds, so the commanded speed is simply their minimum:

$
  v_"desired" = min{v_max, thin v_"accel", thin v_"brake", thin v_"curve", thin v_"interp"}.
$

*A limitation to be aware of.* This planner is _greedy_: it only looks at the
constraints at the robot's current position (plus the braking constraint toward
the path's end). If a sharp turn or a slow keyframe lies ahead mid-path, nothing
forces the robot to start braking for it early---by the time $v_"curve"$ or
$v_"interp"$ drops, the robot may be physically unable to slow down fast enough,
since real deceleration is also bounded by $a_max$. The standard fix is to
precompute the profile over a discretized path with a _forward pass_ (propagating
acceleration limits) and a _backward pass_ (propagating deceleration limits back from every slow point), taking the pointwise minimum. This two-pass idea goes back to the time-optimal path parameterization literature @bobrow @shinmckay @toppra and is exactly what tools like WPILib's trajectory generator do @wpilib; see @sec-related.

= Handling Multiple Path Segments

Many paths consist of several curve segments (splines) joined end-to-end. We can
apply the motion profiling approach to each segment in sequence, while ensuring
smooth transitions between segments.

At the end of one segment, the next segment begins with the robot continuing at
whatever speed it reached. In practice, the end of one spline and the start of
the next share a common point and velocity (if planned correctly). To handle the
transition smoothly:

- If the remaining distance in the current segment is greater than the distance
  $Delta s$ the robot will travel in the next time step, then the robot simply
  continues within the same segment (it hasn't reached the end yet).
- If $Delta s$ would carry the robot past the end of the current segment, we
  first move it to the end of that segment (using the portion of $Delta s$ needed
  to cover the last bit of that spline). Then, we use the leftover distance to
  continue into the next segment (starting the next segment's arc length from 0
  at its beginning).

This way, the robot seamlessly continues from one spline to the next. The
parameter $t$ resets to 0 at the start of the new segment, and we proceed with
the same calculations on the new segment. (If using keyframes, you can also set a
keyframe at the segment boundary to enforce a specific speed at that point.)

= Simplified C++ Example from #link("https://github.com/SerrialError/vmplib")[VMPLib]

#listing[
  ```cpp
  void TrapezoidalProfile::step() {
      ++step_count_;
      time_accum_ += dt_;
      s_current_ = sFunction(control_, prev_t_);

      float keyframe_lim  = computeKeyframeLimit();
      float curvature_lim = computeCurvatureVelocityLimit(prev_t_);
      float accel_lim     = computeAccelerationLimit();
      float brake_lim     = computeBrakingLimit(s_current_);

      // All limits are upper bounds; command the smallest.
      float desired_linear = std::min({ curvature_lim,
                                        accel_lim,
                                        brake_lim,
                                        keyframe_lim,
                                        max_lin_vel_ });
      float deltaS = desired_linear * dt_;
      float next_t = findNextT(s_current_, deltaS);

      float kappa = signedCurvature(control_, next_t);
      float turning_component = kappa * desired_linear;

      poses_.push_back(findXandY(control_, next_t));
      velocities_.push_back({ desired_linear, turning_component, time_accum_ });

      prev_t_    = next_t;
      cur_speed_ = desired_linear;
  }
  ```
]

Each call advances the profile by one timestep and appends to the pose and
velocity vectors rather than returning a sample; the caller loops on
`isFinished()` and reads the accumulated trajectory afterwards. That termination
test checks a step counter as well as $t >= 1$, so a path that stalls near a cusp
ends instead of spinning forever.

*How to use these outputs.* Send $v_"desired"$ and $omega$ to your drivetrain's
velocity controller. A typical differential-drive conversion is:

$
  v_"left" = v_"desired" - (omega thin w)/2, quad quad
  v_"right" = v_"desired" + (omega thin w)/2,
$

where $w$ is the track width. That is open loop: it assumes the robot ends up
where the plan says it does. To close the loop on pose feedback, wrap it in a
tracking controller such as pure pursuit @coulter or RAMSETE.

= Why Acceleration/Deceleration Distance is an Approximation

The constant-$a$ distance formulas we derived assume the robot accelerates and
then decelerates in a perfect "trapezoidal" velocity profile (speeding up,
cruising at $v_max$, then slowing down). This assumes the robot has a long enough
straight run to reach and maintain that top speed.

However, along a curvy path, we impose extra speed limits based on curvature.
This often prevents the robot from ever reaching the planned $v_max$ on that
segment of the path. In other words, the velocity profile gets "cut off" or dips
in the middle due to a turn. The robot might have to start slowing down for the
turn before it ever fully accelerates to $v_max$. The figure below illustrates
this: in the curved case, the robot cannot maintain a flat-top speed profile
because it must slow down for the turn.

// (If an illustrative graph is available, it could be inserted here, showing an
// ideal trapezoidal profile vs. an actual curved-path profile.)

Because of this effect, the simple distance formulas for accelerating and braking
become approximations. In practice, the robot might start decelerating earlier
(or not accelerate as much) when a turn is coming up, meaning our calculated
distances might slightly overestimate how far it needs to speed up or slow down.

To improve accuracy, we can account for curvature in our motion profile
calculations. For example:

- Instead of relying solely on the constant-$a$ formula, we could integrate the
  actual velocity curve (which already factors in curvature limits) to find the
  distance covered during acceleration and deceleration.
- We can dynamically adjust target speeds. If a sharp turn is imminent, the
  algorithm can cap the speed below $v_max$ ahead of time, so that the robot
  never accelerates beyond what it can comfortably slow down from when it reaches
  the curve. Done systematically over a discretized path, this is the
  forward/backward-pass approach mentioned at the end of the velocity planning
  section @bobrow @toppra.

= Ideas for Future Improvement

- *Motor Model*: Acceleration decreases with speed (motors produce less torque at
  high RPM). For example:

  $ a(v) = a_max (1 - v/v_"free"), $

  where $v_"free"$ is the motor's free (no-load) speed.
- *Full Dynamics*: Model the robot's full dynamics (mass, rotational inertia) for
  more realistic acceleration behavior possibly including friction and maybe even drag.
- *Implement back propogation*: Propagate deceleration limits back from every slow point, taking the pointwise minimum at each.

= Related Work and Similar Systems <sec-related>

The approach in this guide was developed independently for
#link("https://github.com/SerrialError/vmplib")[VMPLib], but each
ingredient---and the overall pipeline---has well-established relatives worth
knowing about.

*Arc-length parameterization.* Wang, Kearney, and Atkinson @wang describe
essentially the same numerical machinery used here (Gauss--Legendre quadrature
for $s(t)$, Newton--Raphson to invert it) for driving simulators, where vehicles
must move along spline roads at prescribed speeds. Their paper is a good
reference for accuracy and robustness details we glossed over.

*Time-optimal path parameterization (TOPP).* The academic formulation of "given a
path and actuator limits, find the fastest feasible speed profile" dates to
Bobrow et al. @bobrow and Shin and McKay @shinmckay, who proved the optimal
profile alternates between maximum acceleration and maximum deceleration
segments. Modern solvers such as TOPP-RA @toppra compute the profile with a
backward _controllable-set_ pass followed by a forward pass---the rigorous
version of the forward/backward-pass fix discussed in the velocity planning
section.

*Spline trajectories for differential drives.* Sprunk's thesis @sprunk is the
closest academic sibling of this guide: it plans Bézier-spline paths for a
differential drive robot and computes velocity profiles respecting
translational, rotational, and centripetal limits, with curvature-continuous
joins between segments. See also the companion paper by Lau, Sprunk, and Burgard
@lau.

*Competition robotics implementations.* The FIRST Robotics Competition community
has converged on the same architecture. Team 254's influential presentation
_Motion Planning and Control in FRC_ @team254 popularized spline paths with
trapezoidal profiles; WPILib's trajectory generator @wpilib performs a
forward/backward pass subject to constraints, including a differential-drive
wheel-speed constraint identical in spirit to our curvature limit; and GUI tools
such as PathPlanner @pathplanner and PATH.JERRYIO @jerryio provide the
keyframe-editing workflow described earlier. Veness's free book @veness gives an
accessible derivation of the RAMSETE controller stated above.

= Further Learning Resources

- *YouTube - "The Continuity of Splines":* Deep dive into spline curves by Freya
  Holmér (Highly Reccomend!!!!) @holmer
- *Khan Academy:* Derivatives and Integrals (introductory calculus lessons)
- *Feynman Lectures on Physics*, Vol. 1 (insightful treatment of motion in
  Chapter 8)
- *MIT OCW:* 18.01 Single Variable Calculus (free online course materials)
- *MIT OCW:* 18.02 Multi Variable Calculus for an in-depth look at some of the Calculus going on including possibly derivations of curvature and such (free online course materials as well)

#pagebreak()

#bibliography(
  "references.bib",
  style: "ieee",
)
