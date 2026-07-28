// ============================================================
// A STEP-BY-STEP GUIDE TO 2D MOTION PROFILING USING BÉZIER CURVES
// Differential drive · real-time velocity planning
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

// =============================================================
// TITLE BLOCK
// =============================================================

#v(1em)
#align(center)[
  #text(size: 17pt, weight: "bold")[
    2D Motion Profiling Using Bézier Curves
  ]
  #v(0.8em)
]

#v(1.5em)

#outline()

#pagebreak()

= What is Motion Profiling?

As the name suggest motion profiling profiles a motion, specifically deriving characteristcs about a movement. Specifically it derives in most cases velocities and/or derivatives of it.

Motion profiling answers the question: how should a robot move from point A to
point B?

- How fast should it go?
- When should it turn?
- When should it start slowing down?

In this case the result is a path plus a time-parameterized velocity and angular velocity
profile that respects the robot's physical limits.

= Our Goal: Move Along a Curve <sec-goal>

We want to follow a curved path while:

- Respecting maximum speed and acceleration
- Slowing down for turns (based on curvature)
- Hitting specified speeds at key positions (keyframes)

To do that, we describe the path mathematically and then compute how the robot
should move along it in real time.

= Curve Representation Options

There are multiple ways to describe a smooth curve:

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

= What are Keyframes?

Keyframes are specific points along the path where we fix the robot's speed. For
example:

- Start at 0 m/s
- Reach 1 m/s halfway
- End at 0 m/s

The planner converts those into arc-length positions and then blends between
them. In practice, path planning software (such as _PATH.JERRYIO_ @jerryio)
provides a visual interface to define keyframes. For example, PATH.JERRYIO
includes a "speed graph" where you can add *speed keyframes* at various positions
along the path. Each keyframe corresponds to a specific distance along the path
(the x-axis on the graph) and a desired speed (the y-axis). The planner then
constructs the speed profile by connecting these points smoothly, ensuring the
robot slows down or speeds up at the designated locations.

= Arc Length via Gaussian Quadrature

For a parametric curve $bold(r)(t) = (x(t), y(t))$, the arc length from the start
up to parameter $t$ is

$ s(t) = integral_0^t norm(bold(r)'(tau)) thin d tau, $

the integral of speed $norm(bold(r)'(tau))$ along the curve. We approximate this
integral with Gaussian quadrature, following the approach used for arc-length
parameterization of spline curves in real-time simulation @wang:

$
  integral_a^b f(x) thin d x approx (b - a)/2 sum_(i=1)^n w_i thin f((b - a)/2 x_i + (a + b)/2).
$

*Numerical integration rationale.*
For most curves, there isn't a simple formula for $s(t)$ (and this is true for Cubic Bézier Curves), so we need to integrate numerically. Gaussian quadrature is one effective method for numerical
integration. It chooses special sample points (nodes $x_i$) and weights $w_i$ to
maximize accuracy. An $n$-point Gauss--Legendre rule is exact for all polynomials
up to degree $2n - 1$, meaning it integrates any such polynomial perfectly on
$[-1, 1]$ with only $n$ evaluations of $f$.

To illustrate, the 2-point Gaussian rule on $[-1, 1]$ picks

$ x_1 = -1/sqrt(3), quad x_2 = 1/sqrt(3), quad quad w_1 = w_2 = 1, $

so that

$ integral_(-1)^1 f(x) thin d x approx f(-1/sqrt(3)) + f(1/sqrt(3)), $

which integrates any cubic polynomial exactly.

*Table of Nodes and Weights.*
The following table lists the Gauss--Legendre nodes $x_i$ and weights $w_i$ on
the standard interval $[-1, 1]$ for $n = 2, 3, 4$, as tabulated in standard
references @gauss. These are the constants you plug into the formula above.

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

With just $n = 4$ or $5$, this gives a highly accurate approximation of $s(t)$
without needing extremely fine subdivisions.

One honest caveat: for a cubic Bézier, the integrand $norm(bold(r)'(tau))$ is the
_square root_ of a polynomial, not a polynomial itself, so the "exact for degree
$2n - 1$" guarantee does not literally apply. In practice Gaussian quadrature
still converges very quickly for smooth integrands like this one; accuracy only
degrades near degenerate curves (e.g. control-point placements where
$norm(bold(r)')$ approaches zero, creating a cusp), where subdividing the
interval restores accuracy @wang.

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
the robot's commanded velocity---we reserve $v$ for the latter to avoid
confusion. Starting from an initial guess $t_k$, we linearize and obtain

$
  t_(k+1) = t_k - F(t_k)/(F'(t_k))
  = t_k - (s(t_k) - (s_"current" + Delta s))/norm(bold(r)'(t_k)).
$

In practice each iterate should also be clamped to the valid parameter range
$t in [0, 1]$; if Newton's method fails to converge within $k_max$ iterations
(possible when $norm(bold(r)')$ is very small), falling back to bisection is a
robust remedy @wang.

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

= Keyframe Velocity Interpolation

Suppose we have keyframe pairs $(s_i, v_i)$, which define desired velocities
$v_i$ at specific arc lengths (distances) $s_i$ along the path. To determine the
target velocity at any intermediate position $s$ (where $s_i <= s <= s_(i+1)$),
we linearly interpolate between the surrounding keyframes:

$
  lambda = (s - s_i)/(s_(i+1) - s_i),
  quad quad
  v_"interp"(s) = v_i + lambda (v_(i+1) - v_i).
$

*Note:* This is just the equation of a line, $f(x) = m dot x + b$, in disguise:
the input is $x = s - s_i$, the slope is $m = (v_(i+1) - v_i)/(s_(i+1) - s_i)$,
and the intercept is $b = v_i$. The quantity $lambda in [0, 1]$ is simply the
fraction of the way from $s_i$ to $s_(i+1)$.

= Velocity Planning Algorithm

Ok, now we put it all together. We now follow @sec-goal, which describes our
goals. At every time step we compute several candidate speed limits and command
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
  VelocityLayout TrapezoidalProfile::step() {
      if (isFinished()) {
          return { 0.0f, 0.0f, time_accum_ };
      }

      time_accum_ += dt_;
      s_current_ = sFunction(control_, prev_t_);

      float keyframe_lim  = computeKeyframeLimit();
      float curvature_lim = computeCurvatureVelocityLimit(prev_t_);
      float accel_lim     = computeAccelerationLimit(s_current_);
      float brake_lim     = computeDecelerationLimit(s_current_);

      // All limits are upper bounds; command the smallest.
      float desired_linear = std::min({ curvature_lim,
                                        accel_lim,
                                        brake_lim,
                                        keyframe_lim,
                                        max_lin_vel_ });
      float deltaS = desired_linear * dt_;
      float next_t = findNextT(s_current_, deltaS);

      float kappa = curvature(control_, next_t);
      float turning_component = kappa * desired_linear;

      Pose newPose = findXandY(control_, next_t);
      poses_.push_back(newPose);

      VelocityLayout vlay{ desired_linear, turning_component, time_accum_ };
      velocities_.push_back(vlay);

      prev_t_    = next_t;
      cur_speed_ = desired_linear;

      return vlay;
  }
  ```
]

*How to use these outputs.* Send $v_"desired"$ and $omega$ to your drivetrain's
velocity controller (commonly a PID or feedforward velocity controller, which is
beyond the scope of this guide). A typical differential-drive conversion is:

$
  v_"left" = v_"desired" - (omega thin w)/2, quad quad
  v_"right" = v_"desired" + (omega thin w)/2,
$

where $w$ is the track width. For even better tracking, you can wrap this in a
RAMSETE @ramsete @veness or pure-pursuit @coulter controller that uses the
robot's pose feedback to correct errors and ensure convergence to the planned
path.

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
keyframe-editing workflow described earlier. Veness's free book @veness derives
the RAMSETE tracking controller referenced in the previous section.

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
