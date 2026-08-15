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

// Optional-depth callout. Anything in one of these can be skipped on a first
// read without breaking the main thread of the guide.
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

// =============================================================
// PART 0 — INTRODUCTION
// =============================================================

= Introduction

== What is Motion Profiling?

As the name suggests, motion profiling profiles a motion --- it derives
characteristics about a movement, in most cases velocities and their
derivatives.

Motion profiling answers the question: how should a robot move from point A to
point B?

- How fast should it go?
- When should it turn?
- When should it start slowing down?

In this case the result is a path plus a time-parameterized velocity and angular
velocity profile that respects the robot's physical limits.

== Our Goal: Move Along a Curve <sec-goal>

We want to follow a curved path while:

- Respecting maximum speed and acceleration
- Slowing down for turns (based on curvature)
- Hitting specified speeds at key positions (keyframes)

To do that, we describe the path mathematically and then compute how the robot
should move along it.

*How to read this guide.* The material is split into three parts. @sec-path
builds the geometry: how to describe a path and how to answer questions about it.
@sec-speed builds the speed planner on top of that geometry. @sec-real deals with
turning the plan into motor commands. Passages in shaded boxes like the one below
are optional depth --- they justify a result the main text has already stated, and
skipping them costs you nothing on a first read.

#deeper("what these boxes are for")[
  If you have taken (or are taking) a first calculus course, the main thread of
  this guide should be readable. These boxes are where the second-year material
  lives: convergence of numerical integration, derivations that need the chain
  rule in two variables, and the failure modes that only show up in degenerate
  cases. Come back to them when you want to know *why* rather than *what*.
]

== The Planning Loop <sec-loop>

Before any of the math, here is the entire algorithm. Everything in this guide
exists to fill in one of these lines.

#listing[
  ```text
  s ← 0                       // distance traveled so far
  t ← 0                       // curve parameter, 0 at the start, 1 at the end

  while not finished:
      v_max    ← constant                   // the drivetrain's top speed
      v_accel  ← limit from max acceleration
      v_brake  ← limit from needing to stop at the end
      v_curve  ← limit from how sharp the path is here
      v_interp ← limit from the user's keyframes

      v  ← min(v_max, v_accel, v_brake, v_curve, v_interp)
      Δs ← v · dt                           // distance to cover this timestep
      t  ← findNextT(s, Δs)                 // advance along the curve by Δs
      s  ← s + Δs

      emit( position(t), v, curvature(t) · v )
  ```
]

Two observations, both worth holding onto:

+ *Every speed limit is an upper bound, so we take the minimum.* There is no
  clever arbitration between the five candidates. Each one says "you may not go
  faster than this"; obeying all of them at once means obeying the smallest.

+ *The hard part is `findNextT`.* We want to move a *distance* $Delta s$, but the
  curve is described by a *parameter* $t$, and those are not the same thing. Most
  of @sec-path is about bridging that gap.

// =============================================================
// PART I — DESCRIBING THE PATH
// =============================================================

= Describing the Path <sec-path>

== Representing the Path: Cubic Bézier Curves

There are multiple ways to describe a smooth curve. Cubic Bézier curves use four
control points (start, end, and two shaping points), which gives a good balance
of simplicity and flexibility, and they are what this guide uses throughout
@farin. Their $x$ and $y$ coordinates are

$
  x(t) & = (1 - t)^3 x_0 + 3(1 - t)^2 t thin x_1 + 3(1 - t) thin t^2 x_2 + t^3 x_3 \
  y(t) & = (1 - t)^3 x_0 + 3(1 - t)^2 t thin y_1 + 3(1 - t) thin t^2 y_2 + t^3 y_3
$

// FIGURE 1: cubic Bézier with the four control points labeled and the control
// polygon drawn in as a dashed line.

Other common choices --- quadratic Béziers, cubic Hermite splines, and
Catmull--Rom splines --- are compared in @app-curves. Nothing later in this guide
depends on the choice: everything downstream needs only $bold(r)(t)$,
$bold(r)'(t)$, and $bold(r)''(t)$, which every one of those representations
provides.

== Why $t$ Is Not Distance <sec-whynot-t>

The obvious way to drive the curve is to step $t$ forward by a fixed amount each
timestep --- $t = 0.00, 0.01, 0.02, dots$ --- and command a constant speed. This
does not work, and understanding why motivates the next two sections.

Sample a cubic Bézier at evenly spaced values of $t$ and plot the points. They
are *not* evenly spaced along the curve. Where the control points pull the curve
into a tight turn, the samples bunch together; on the long straight stretches
they spread far apart. The parameter $t$ measures progress through the *formula*,
not progress through *space*.

// FIGURE 2: the same Bézier sampled at 20 uniform values of t, dots visibly
// clustered near the tight section and sparse on the straight run.

Stepping $t$ uniformly therefore means the robot slows down and speeds up
arbitrarily, driven by the algebra rather than by anything physical. We need the
opposite: given a distance we want to travel, find the $t$ that gets us there.
That requires two tools --- a way to compute distance from $t$ (@sec-arclength),
and a way to invert it (@sec-newton).

== Arc Length: From $t$ to Distance <sec-arclength>

For a parametric curve $bold(r)(t) = (x(t), y(t))$, the arc length from the start
up to parameter $t$ is

$ s(t) = integral_0^t norm(bold(r)'(tau)) thin d tau, $

the integral of speed $norm(bold(r)'(tau))$ along the curve. For a cubic Bézier
there is no closed-form answer to that integral, so we compute it numerically.

=== The straightforward version

Chop the curve into $N$ small pieces and add up the straight-line distances
between consecutive points:

#listing[
  ```text
  s ← 0
  for i in 1..N:
      s ← s + | r(i/N) - r((i-1)/N) |
  return s
  ```
]

This is five lines of code, needs no theory beyond the distance formula, and it
works. Its only problem is cost: getting good accuracy needs $N$ in the hundreds,
and we call this function several times per control cycle.

=== The efficient version: Gaussian quadrature

Gaussian quadrature is a smarter way to spend a fixed budget of samples. Instead
of spacing them evenly, it places them at special locations (nodes $x_i$) and
weights them by $w_i$ chosen so that the approximation is as accurate as
possible:

$
  integral_a^b f(x) thin d x approx (b - a)/2 sum_(i=1)^n w_i thin f((b - a)/2 x_i + (a + b)/2).
$

An $n$-point Gauss--Legendre rule is exact for all polynomials up to degree
$2n - 1$ --- $n$ samples buying the accuracy of a far denser uniform grid. The
$n = 2$ rule on $[-1, 1]$, for instance, uses

$ x_1 = -1/sqrt(3), quad x_2 = 1/sqrt(3), quad quad w_1 = w_2 = 1, $

so that

$ integral_(-1)^1 f(x) thin d x approx f(-1/sqrt(3)) + f(1/sqrt(3)), $

which integrates any cubic polynomial exactly. Nodes and weights for
$n = 2, dots, 5$ are tabulated in @app-quadrature; the implementation here uses
$n = 5$.

To apply this to arc length, set

$ f(tau) = norm(bold(r)'(tau)), quad a = 0, quad b = t, $

so the sample points are $tau_i = t/2 thin x_i + t/2$ and

$ s(t) approx t/2 sum_(i=1)^n w_i thin norm(bold(r)'(tau_i)). $

In practice we do not apply this to the whole interval at once. We split
$[0, t]$ into $m = 8$ equal panels and run the 5-point rule on each, which costs
40 evaluations of $norm(bold(r)')$ per call --- cheap enough for every control
cycle, and accurate enough that the residual error sits well below the robot's
odometry noise:

$
  s(t) approx sum_(j=0)^(m-1) h/2 sum_(i=1)^n w_i thin
  norm(bold(r)'(h j + h/2 (x_i + 1))),
  quad quad h = t/m.
$

#deeper("why one panel is not enough")[
  For a cubic Bézier the integrand $norm(bold(r)'(tau))$ is the *square root* of
  a polynomial, not a polynomial itself, so the "exact for degree $2n - 1$"
  guarantee does not apply at all --- no choice of $n$ makes a single application
  of the rule exact here.

  What the rule still gives is fast convergence for smooth integrands, and that
  convergence is much faster on short intervals than on long ones. On a long or
  wiggly curve, a single $n = 5$ panel spanning all of $[0, t]$ leaves error
  large enough to misplace the robot. Splitting into $m$ panels and applying the
  rule on each --- *composite* quadrature --- is the standard fix @wang. Accuracy
  still degrades near degenerate curves; see @app-degenerate.
]

== From Distance Back to $t$: Newton--Raphson <sec-newton>

@sec-arclength gives us distance from a parameter. The planning loop needs the
reverse: given that we want to travel a further $Delta s$, find the new parameter
$t_"next"$ with

$ s(t_"next") = s_"current" + Delta s. $

Equivalently, find the root of

$ F(t) = s(t) - (s_"current" + Delta s). $

Newton--Raphson does this by repeatedly following the tangent line to the axis.
Its derivative is free here: $F'(t) = s'(t) = norm(bold(r)'(t))$, the
*parametric* speed of the curve (how fast the point moves as $t$ changes), not
the robot's commanded velocity. The iteration is

$
  t_(k+1) = t_k - F(t_k)/(F'(t_k))
  = t_k - (s(t_k) - (s_"current" + Delta s))/norm(bold(r)'(t_k)),
$

and in practice each iterate is clamped to $t in [0, 1]$. We stop when

$
  abs(t_(k+1) - t_k) < epsilon
  quad "or" quad
  abs(s(t_k) - (s_"current" + Delta s)) < epsilon
  quad "or" quad
  k >= k_max,
$

with a tolerance such as $epsilon = 10^(-6)$ and a cap such as $k_max = 10$ to
avoid infinite loops. If Newton fails to converge within $k_max$ iterations,
falling back to bisection --- essentially a binary search for the zero --- is a
robust remedy @wang.

#deeper("a lower-tech alternative")[
  If the quadrature-plus-Newton combination is more machinery than you want,
  there is a well-trodden alternative: precompute a table of $(t, s)$ pairs at,
  say, 200 uniform values of $t$ once when the path is created, then answer every
  later query by binary-searching the table and linearly interpolating between
  neighbors. It costs a few kilobytes and a one-time setup pass, and several
  production path-following libraries do exactly this. The tradeoff is a fixed
  accuracy floor set by the table resolution.
]

== Curvature: How Sharp Is the Path Here? <sec-curvature>

For a 2D path $bold(r)(t) = (x(t), y(t))$, the *signed* curvature is

$
  kappa(t)
  = (x'(t) y''(t) - y'(t) x''(t))/((x'(t)^2 + y'(t)^2)^(3\/2)),
  quad quad
  R(t) = 1/abs(kappa(t)),
$

where $R(t)$ is the radius of curvature: the radius of the circle that best hugs
the path at that point. A straight line has $kappa = 0$ and $R = infinity$; a
hairpin has large $abs(kappa)$ and small $R$.

The sign matters. It encodes the turn direction --- positive for a left turn,
negative for a right, with the usual counterclockwise convention. The speed limit
in @sec-vcurve depends only on $abs(kappa)$, but the commanded angular velocity
is $omega = v kappa$, so discarding the sign would leave the robot able to turn
only one way.

The denominator vanishes wherever the parametric speed does, and the formula is
undefined there. That case, and what to do about it, is covered in
@app-degenerate.

// =============================================================
// PART II — PLANNING THE SPEED
// =============================================================

= Planning the Speed <sec-speed>

With the geometry in hand, we can fill in the five limits from @sec-loop. Each
subsection below computes one of them.

== A Kinematics Toolbox <sec-kinematics>

Three of the five limits are built from one equation, so it is worth stating
first. From basic kinematics with constant acceleration $a$:

$
  v^2 = v_0^2 + 2 a thin Delta s
  quad ==> quad
  Delta s = (v^2 - v_0^2)/(2 a).
$

- If $a > 0$: $Delta s$ is the distance needed to *accelerate* from $v_0$ up to
  $v$.
- If $a < 0$: $Delta s$ is the distance needed to *decelerate* from $v_0$ down to
  $v$.

Note the form of this equation: it relates speed to *distance*, with no time in
it. That is exactly what a path planner wants, since everything is indexed by
arc length.

#deeper("where the equation comes from")[
  Integrate acceleration over distance rather than over time:

  $
    a = (d v)/(d t)
    quad => quad
    v thin d v = a thin d s
    quad => quad
    integral_(v_0)^v v thin d v = integral_0^(Delta s) a thin d s
    quad => quad
    (v^2 - v_0^2)/2 = a thin Delta s,
  $

  and rearrange. The middle step uses $d s = v thin d t$, which is just the
  definition of speed.
]

== Limit 1: Maximum Speed

The robot's absolute top speed, $v_max$. A constant, measured empirically or
taken from the motor's free speed and gear ratio. Nothing to derive.

== Limit 2: Acceleration

The robot's speed can only change by $a_max thin Delta t$ in one timestep, so

$ v_"accel" = v(t) + a_max thin Delta t, $

where $v(t)$ is the current commanded speed. This is what keeps the profile from
demanding an instantaneous jump in velocity that the drivetrain cannot deliver.

== Limit 3: Braking for the End of the Path

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

== Limit 4: Curvature <sec-vcurve>

The wheels of a differential drive robot have a maximum speed. In a turn, the
outer wheel travels faster than the robot's center, so the center must slow down
to keep the outer wheel within its limit @lavalle @wpilib:

$ v_"curve"(t) = v_max dot R(t)/(R(t) + w/2), $

where $w$ is the track width (the distance between the left and right wheels) and
$R(t)$ is the radius of curvature from @sec-curvature. On a straight path
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

== Limit 5: Keyframes <sec-keyframes>

Keyframes are points along the path where the user fixes the robot's speed --- for
example, start at 0 m/s, reach 1 m/s halfway, end at 0 m/s. Path editing tools
such as _PATH.JERRYIO_ @jerryio expose these through a speed graph, where each
keyframe is a distance along the path (the $x$-axis) paired with a desired speed
(the $y$-axis).

Turning that into a speed limit takes two steps: locating each keyframe on the
curve, and interpolating between them.

=== Locating a keyframe on the path

The editor hands us keyframes as $(x, y, v)$: a point the user clicked on the
field and the speed they want there. Everything downstream is indexed by $t$, so
the first job is to turn the point $bold(p) = (x, y)$ into a parameter.

The tempting shortcut is to solve $x(t) = x_"kf"$ for $t$ and ignore $y$. That is
wrong on any path that revisits an $x$ coordinate --- an S-curve, a loop, or
anything that doubles back --- because the equation then has several roots and
nothing distinguishes the intended one from a branch of the path meters away. It
also fails outright when the keyframe sits slightly off the curve, since
$x(t) = x_"kf"$ may have no solution in $[0, 1]$ at all.

The correct question is a projection: which point of the curve is closest to
$bold(p)$?

$
  t^* = op("arg min", limits: #true)_(t in [0, 1]) norm(bold(r)(t) - bold(p))^2.
$

Given $t^*$ for each keyframe, the arc-length position follows from the
quadrature of @sec-arclength: $s_i = s(t_i^*)$.

#deeper("solving the projection")[
  Differentiating the objective gives the stationary condition

  $
    d/(d t) norm(bold(r)(t) - bold(p))^2 = 2 (bold(r)(t) - bold(p)) dot bold(r)'(t) = 0,
  $

  which says the error vector is orthogonal to the tangent --- geometrically
  obvious once you see it. Writing $g(t) = (bold(r)(t) - bold(p)) dot
  bold(r)'(t)$, Newton's method applies again with

  $
    g'(t) = norm(bold(r)'(t))^2 + (bold(r)(t) - bold(p)) dot bold(r)''(t),
    quad quad
    t_(k+1) = t_k - g(t_k)/(g'(t_k)).
  $

  For a cubic Bézier, $g$ is a quintic in $t$ and can have up to five roots, so
  the squared distance is *not* convex and Newton alone will happily converge to
  the wrong local minimum. The implementation therefore scans a coarse grid
  (64 samples) for the best basin, refines from there, and discards the
  refinement if it ends up farther from $bold(p)$ than the sampled seed.
]

=== Interpolating between keyframes

Now we have pairs $(s_i, v_i)$: desired speeds at arc lengths. For an intermediate
position $s$ with $s_i <= s <= s_(i+1)$, define the fraction of the way through
the interval

$ lambda = (s - s_i)/(s_(i+1) - s_i) in [0, 1]. $

The obvious move is to interpolate $v$ itself linearly in $s$. Do not. Along the
path $a = v thin (d v)/(d s)$, so a profile linear in $s$ implies

$
  a(s) = v(s) dot (v_(i+1) - v_i)/(s_(i+1) - s_i),
$

which is proportional to the current speed: the segment demands the *most*
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

a *constant*. So interpolating in $v^2$ makes each keyframe interval a
constant-acceleration segment --- the same shape as every other limit in the
planner.

== Putting It Together: Take the Minimum

All five quantities are upper bounds on the speed at the current position, so the
commanded speed is simply their minimum:

$
  v_"desired" = min{v_max, thin v_"accel", thin v_"brake", thin v_"curve", thin v_"interp"}.
$

The commanded angular velocity follows from the curvature at that point:
$omega = v_"desired" dot kappa$.

// FIGURE 3: all five limits plotted against arc length for one example path,
// with the pointwise minimum drawn as a heavy envelope curve on top. This
// figure IS the algorithm.

== Limitations of a Greedy Planner <sec-greedy>

The planner above is *greedy*: it looks only at the constraints at the robot's
current position, plus the braking constraint toward the path's end. If a sharp
turn or a slow keyframe lies ahead mid-path, nothing forces the robot to start
braking for it early. By the time $v_"curve"$ or $v_"interp"$ drops, the robot
may be physically unable to slow down fast enough, since real deceleration is
also bounded by $a_max$.

There is a second, milder approximation lurking in the same place. The
constant-$a$ distance formulas of @sec-kinematics assume a clean trapezoidal
profile: speed up, cruise at $v_max$, slow down. On a curvy path the curvature
limit often prevents the robot from ever reaching $v_max$, so the profile gets
cut off or dips in the middle, and the computed accelerate/brake distances
slightly overestimate what is actually needed.

The standard fix addresses both. Precompute the profile over a discretized path
with a *forward pass* that propagates acceleration limits forward and a
*backward pass* that propagates deceleration limits back from every slow point,
then take the pointwise minimum. This two-pass idea goes back to the time-optimal
path parameterization literature @bobrow @shinmckay @toppra and is exactly what
tools like WPILib's trajectory generator do @wpilib; see @sec-related.

// =============================================================
// PART III — MAKING IT REAL
// =============================================================

= Making It Real <sec-real>

== Driving the Drivetrain <sec-drivetrain>

The planner emits a linear velocity $v_"desired"$ and an angular velocity
$omega$. Converting those to wheel commands for a differential drive is the
inverse of the kinematics used in @sec-vcurve:

$
  v_"left" = v_"desired" - (omega thin w)/2, quad quad
  v_"right" = v_"desired" + (omega thin w)/2,
$

where $w$ is the track width. Send these to your wheel velocity controllers.

Note that this is *open loop*: it assumes the robot ends up where the plan says
it does. Wheel slip, unmodeled dynamics, and odometry drift all violate that
assumption. To close the loop on pose feedback, wrap the output in a tracking
controller such as pure pursuit @coulter or RAMSETE.

== Handling Multiple Path Segments

Many paths consist of several curve segments joined end-to-end. We apply the
profiling approach to each segment in sequence, while ensuring smooth transitions
between them. At the end of one segment the next begins with the robot continuing
at whatever speed it reached; if the path was planned correctly, the two segments
share a common point and velocity.

- If the remaining distance in the current segment is greater than $Delta s$, the
  robot simply continues within the same segment.
- If $Delta s$ would carry the robot past the end of the current segment, move it
  to the end of that segment using the portion of $Delta s$ needed, then use the
  leftover distance to continue into the next segment (starting the next
  segment's arc length from 0).

The parameter $t$ resets to 0 at the start of the new segment and the same
calculations proceed there. If you are using keyframes, placing one at the
segment boundary lets you enforce a specific speed at that point.

== Code Walkthrough

The following is a simplified extraction from
#link("https://github.com/SerrialError/vmplib")[VMPLib]. Every line corresponds
to something derived above.

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

== Ideas for Future Improvement

- *Motor model.* Acceleration decreases with speed, since motors produce less
  torque at high RPM. A first-order model is

  $ a(v) = a_max (1 - v/v_"free"), $

  where $v_"free"$ is the motor's free (no-load) speed.
- *Full dynamics.* Model mass and rotational inertia for more realistic
  acceleration behavior, possibly including friction and drag.
- *Backward propagation.* Implement the backward pass described in @sec-greedy,
  propagating deceleration limits back from every slow point and taking the
  pointwise minimum. This is the single highest-value addition to the planner as
  it stands.

// =============================================================
// BACK MATTER
// =============================================================

= Related Work and Further Reading

== Related Work and Similar Systems <sec-related>

The approach in this guide was developed independently for
#link("https://github.com/SerrialError/vmplib")[VMPLib], but each
ingredient --- and the overall pipeline --- has well-established relatives worth
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
backward _controllable-set_ pass followed by a forward pass --- the rigorous
version of the fix discussed in @sec-greedy.

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
accessible derivation of the RAMSETE controller mentioned in @sec-drivetrain.

== Further Learning Resources

- *YouTube --- "The Continuity of Splines":* a deep dive into spline curves by
  Freya Holmér (highly recommended) @holmer
- *Khan Academy:* derivatives and integrals (introductory calculus lessons)
- *Feynman Lectures on Physics*, Vol. 1: an insightful treatment of motion in
  Chapter 8
- *MIT OCW 18.01:* Single Variable Calculus (free online course materials)
- *MIT OCW 18.02:* Multivariable Calculus, for the material behind the curvature
  formula and the projection derivation

#pagebreak()

// =============================================================
// APPENDICES
// =============================================================

#counter(heading).update(0)
#set heading(numbering: "A.1")

= Other Curve Representations <app-curves>

Cubic Béziers are used throughout this guide, but they are not the only option:

- *Quadratic Bézier curve.* Three control points (start, end, and one middle
  control point). Simpler, but less flexible in shaping the path.
- *Cubic Bézier curve.* Four control points (start, end, and two shaping points).
  More control over the shape; the choice made here.
- *Cubic Hermite spline.* Defined by endpoints and specified tangents at those
  endpoints, so you explicitly set the direction of travel at each end.
- *Catmull--Rom spline.* Passes through a series of given waypoints, smoothly
  interpolating all of them --- convenient when the path must hit specific
  locations exactly.

Swapping representations requires changing only $bold(r)(t)$, $bold(r)'(t)$, and
$bold(r)''(t)$. Every other formula in this guide is written in terms of those
three functions and is unaffected.

= Gauss--Legendre Nodes and Weights <app-quadrature>

Nodes $x_i$ and weights $w_i$ on the standard interval $[-1, 1]$ for
$n = 2, 3, 4, 5$, as tabulated in standard references @gauss. These are the
constants plugged into the quadrature formula of @sec-arclength; the $n = 5$ row
is the one the implementation uses.

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

= Degenerate Cases and Cusps <app-degenerate>

Everything in this guide assumes the parametric speed $norm(bold(r)'(t))$ stays
comfortably away from zero. Certain control-point placements violate that,
producing a *cusp*: a point where the curve momentarily stops and reverses
direction. Three separate pieces of machinery break there, all for the same
reason.

*Curvature is undefined.* The denominator $norm(bold(r)'(t))^3$ in the curvature
formula collapses to zero. It is tempting to return $kappa = 0$ to avoid the
division, but that is exactly backwards: a cusp is the *sharpest* point on the
path, geometrically a turn of zero radius, so $abs(kappa) -> infinity$. Returning
zero would remove the curvature speed limit precisely where it is needed most and
send the robot through the cusp at full speed.

The safe convention is to saturate $abs(kappa)$ at a large finite value, keeping
the sign of the cross product wherever it is still recoverable so the turn
direction survives. The limit $v_"curve" = v_max dot R\/(R + w\/2)$ then drives
$v -> 0$ as $R -> 0$, and since $omega = v kappa$ the angular velocity tends to
$omega -> 2 v_max \/ w$ --- the robot turning in place at the drivetrain's maximum
rate, which is the physically correct behavior at a cusp.

*Newton's iteration for arc length breaks.* Its derivative is
$F'(t) = norm(bold(r)'(t))$, so the update step divides by something approaching
zero and the iterate explodes. This is where the bisection fallback of
@sec-newton earns its place.

*Quadrature accuracy degrades.* The integrand loses smoothness near the cusp, so
convergence slows and further subdivision is the remedy @wang.

*Practical advice.* The cheapest defense is not to generate such paths in the
first place --- most path editors will show you the loop or the reversal
visually --- and to include a step-count cap in the termination test, so that a
profile that stalls at a cusp terminates rather than hanging.

#pagebreak()

#bibliography(
  "references.bib",
  style: "ieee",
)
