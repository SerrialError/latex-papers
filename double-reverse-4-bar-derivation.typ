=== Given (for all derivations below)

$phi = theta$

$L = L_1 = L_2$

$omega := dot(theta)$ and $alpha := dot(omega) = dot.double(theta)$

$v := dot(y)$

$theta in (-pi/2, pi/2)$

#align(center)[
  #figure(
  image("dr4b_kinematics_diagram.svg", width: 80%),
)
]

== Goal 1

=== Find a function $v$, linear velocity, for the top of the lift

1. $y(theta) = y_1 + B B' + B' E + y_2$ by the segment addition postulate

2. $sin theta = (y_1 (theta)) / L_1$ and $sin phi = (y_2 (phi)) / L_2$ by the definition of $sin$ in right angle trigonometry

3. $y_1 (theta) = L_1 sin theta$ and $y_2 (phi) = L_2 sin phi$ by multiplication

4. $y(theta) = L_1 sin theta + B B' + B' E + L_2 sin phi$ by substitution

5. $y(theta) = L sin theta + B B' + B' E + L sin theta$ by substitution

6. $y(theta) = 2 L sin theta + B B' + B' E$ by substitution

7. $v(theta, omega) = 2 L omega cos theta$ by differentiation

Note: It can be shown trivially that the horizontal component of velocity would be $0$ as $theta = phi$ and $L_1 = L_2$

== Goal 2

=== Given

The origin is at A, with $+x$ to the right and $+y$ up.

$m_1 :=$ total mass of the two lower bars

$m_2 :=$ total mass of the two upper bars

$m_t :=$ mass of the middle tower

$m_"car" :=$ mass of the carriage (top tower from C to C', intake, and payload)

$b := B B' + B' E$, the fixed vertical distance from B to E

$h_t :=$ fixed height of the middle tower's center of mass above B

$h_"car" :=$ fixed height of the carriage's center of mass above C

$g :=$ gravitational acceleration

For any point P, $arrow(r)_P :=$ the position vector of P relative to A

For any point P, $arrow(v)_P := dot(arrow(r))_P$

$arrow(r)_1$, $arrow(r)_t$, $arrow(r)_2$, and $arrow(r)_"car"$ : positions of the centers of mass of the lower bars, middle tower, upper bars, and carriage.

=== Find a function $tau(theta, omega, a)$, the torque required at A for the top of the lift to have vertical acceleration $a$, given angle $theta$ and angular velocity $omega$.

1. $arrow(r)_B = (L cos theta, L sin theta)$ by the definitions of $sin$ and $cos$ in right angle trigonometry

2. $arrow(r)_E = arrow(r)_B + (0, b)$ by vector addition

3. $arrow(r)_E = (L cos theta, L sin theta + b)$ by substitution

4. $arrow(E C) = (-L cos phi, L sin phi)$ by the definitions of $sin$ and $cos$ in right angle trigonometry

5. $arrow(E C) = (-L cos theta, L sin theta)$ by substitution

6. $arrow(r)_C = arrow(r)_E + arrow(E C)$ by vector addition

7. $arrow(r)_C = (0, 2 L sin theta + b)$ by substitution of (3) and (5) into (6)

8. $arrow(r)_1 = 1/2 arrow(r)_B = (L/2 cos theta, L/2 sin theta)$ by the fact that the center of mass of a uniform bar is its midpoint

  Note: bar $A' B'$ is bar $A B$ translated by the constant vector $arrow(A A')$ (parallelogram), so its center is $arrow(r)_1$ plus a constant. Both lower bars $therefore$ have the same velocity and angular velocity and are treated as one body of mass $m_1$. The same argument applies to the upper bars.

9. $arrow(r)_t = arrow(r)_B + (0, h_t) = (L cos theta, L sin theta + h_t)$ by vector addition and the definition of $h_t$

10. $arrow(r)_2 = arrow(r)_E + 1/2 arrow(E C)$ by the fact that the center of mass of a uniform bar is its midpoint

11. $arrow(r)_2 = (L/2 cos theta, (3 L)/2 sin theta + b)$ by substitution of (3) and (5)

12. $arrow(r)_"car" = arrow(r)_C + (0, h_"car") = (0, 2 L sin theta + b + h_"car")$ by vector addition, the definition of $h_"car"$, and (7)

13. $arrow(v)_1 = (-L/2 omega sin theta, L/2 omega cos theta)$ by differentiation of (8)

14. $abs(arrow(v)_1)^2 = (L^2 omega^2)/4 (sin^2 theta + cos^2 theta)$ by the definition of magnitude

15. $abs(arrow(v)_1)^2 = (L^2 omega^2)/4$ by substitution

16. $arrow(v)_t = (-L omega sin theta, L omega cos theta)$ by differentiation of (9)

17. $abs(arrow(v)_t)^2 = L^2 omega^2 (sin^2 theta + cos^2 theta)$ by the definition of magnitude

18. $abs(arrow(v)_t)^2 = L^2 omega^2$ by substitution

19. $arrow(v)_2 = (-L/2 omega sin theta, (3 L)/2 omega cos theta)$ by differentiation of (11)

20. $abs(arrow(v)_2)^2 = (L^2 omega^2)/4 (sin^2 theta + 9 cos^2 theta)$ by the definition of magnitude

21. $abs(arrow(v)_2)^2 = (L^2 omega^2)/4 (1 + 8 cos^2 theta)$ by substitution

22. $arrow(v)_"car" = (0, 2 L omega cos theta)$ by differentiation of (12)

23. $abs(arrow(v)_"car")^2 = 4 L^2 omega^2 cos^2 theta$ by the definition of magnitude

For a rigid body moving in a plane, its kinetic energy is $T := 1/2 m abs(arrow(v)_"cm")^2 + 1/2 I_"cm" omega^2$, where $I_"cm"$ is its moment of inertia about its center of mass. For a uniform bar of mass $m$ and length $L$, $I_"cm" = 1/12 m L^2$. The two bars in each pair have the same velocity and angular velocity, so their kinetic energies add to the formula with their total mass.

Note: All four bars have angular velocity $plus.minus omega$, so the same $omega^2$. The middle tower and carriage translate without rotating, so they have no rotational kinetic energy.

24. $I_1 = 1/12 m_1 L^2$ by the moment of inertia of a uniform bar

25. $I_2 = 1/12 m_2 L^2$ by the moment of inertia of a uniform bar

26. $T_t = 1/2 m_t abs(arrow(v)_t)^2$ and $T_"car" = 1/2 m_"car" abs(arrow(v)_"car")^2$ since the tower and carriage do not rotate

27. $T_1 = 1/2 m_1 (L^2 omega^2)/4 + 1/2 (1/12 m_1 L^2) omega^2$ by substitution of (15) and (24)

28. $T_1 = 1/2 (m_1/3) L^2 omega^2$ by substitution

29. $T_t = 1/2 m_t L^2 omega^2$ by substitution of (18) into (26)

30. $T_2 = 1/2 m_2 (L^2 omega^2)/4 (1 + 8 cos^2 theta) + 1/2 (1/12 m_2 L^2) omega^2$ by substitution of (21) and (25)

31. $T_2 = 1/2 m_2 (1/3 + 2 cos^2 theta) L^2 omega^2$ by substitution

32. $T_"car" = 1/2 m_"car" (4 cos^2 theta) L^2 omega^2$ by substitution of (23) into (26)

33. $T = T_1 + T_t + T_2 + T_"car"$ by the definition of total kinetic energy

34. $T = 1/2 L^2 [(m_1 + m_2)/3 + m_t + 2 (m_2 + 2 m_"car") cos^2 theta] omega^2$ by substitution of (28), (29), (31), (32)

35. $M := (m_1 + m_2)/3 + m_t$

36. $I_"eff" (theta) := L^2 [M + 2 (m_2 + 2 m_"car") cos^2 theta]$

37. $T = 1/2 I_"eff" (theta) omega^2$ by substitution of (35) and (36) into (34)

38. $I'_"eff" (theta) = -4 (m_2 + 2 m_"car") L^2 sin theta cos theta$ by differentiation of (36), since $dif/(dif theta) cos^2 theta = -2 sin theta cos theta$

Let $V = g (m_1 [arrow(r)_1]_y + m_t [arrow(r)_t]_y + m_2 [arrow(r)_2]_y + m_"car" [arrow(r)_"car"]_y)$ be the gravitational potential energy, where $[arrow(r)_P]_y$ is the $y$-component of $arrow(r)_P$. (The second bar in each pair only adds a constant, which does not affect $V'(theta)$.)

39. $V = g [m_1 L/2 sin theta + m_t (L sin theta + h_t) + m_2 ((3 L)/2 sin theta + b) + m_"car" (2 L sin theta + b + h_"car")]$ by substitution of (8), (9), (11), (12)

40. $V = g [m_1 L/2 sin theta + m_t L sin theta + m_t h_t + (3 m_2 L)/2 sin theta + m_2 b + 2 m_"car" L sin theta + m_"car" b + m_"car" h_"car"]$ by substitution

41. $V = g [(m_1 L/2 sin theta + m_t L sin theta + (3 m_2 L)/2 sin theta + 2 m_"car" L sin theta) + (m_t h_t + m_2 b + m_"car" b + m_"car" h_"car")]$ by substitution

42. $V = g [L sin theta (m_1/2 + m_t + (3 m_2)/2 + 2 m_"car") + (m_t h_t + m_2 b + m_"car" (b + h_"car"))]$ by substitution

43. $V = g L sin theta (m_1/2 + m_t + (3 m_2)/2 + 2 m_"car") + g (m_t h_t + m_2 b + m_"car" (b + h_"car"))$ by substitution

44. $V_0 := g (m_t h_t + m_2 b + m_"car" (b + h_"car"))$

45. $V = g L sin theta (m_1/2 + m_t + (3 m_2)/2 + 2 m_"car") + V_0$ by substitution of (44) into (43)

46. $K := m_1/2 + m_t + (3 m_2)/2 + 2 m_"car"$

47. $V'(theta) = g K L cos theta$ by differentiation of (45), using (46)

48. $tau omega = dot(T) + dot(V)$ by the rate form of the work-energy principle with potential energy

49. $dot(T) = 1/2 I'_"eff" (theta) omega^3 + I_"eff" (theta) omega alpha$ by differentiation of (37) using the product and chain rules

50. $dot(T) = omega (I_"eff" alpha + 1/2 I'_"eff" omega^2)$ by substitution

51. $dot(V) = V'(theta) omega$ by the chain rule

52. $tau omega = omega (I_"eff" alpha + 1/2 I'_"eff" omega^2 + V'(theta))$ by substitution of (50) and (51) into (48)

53. $tau = I_"eff" alpha + 1/2 I'_"eff" omega^2 + V'(theta)$ by division by $omega$

  Note: this requires $omega != 0$. Both sides are continuous in time, so (53) also holds at isolated instants where $omega = 0$, such as starting from rest.

54. $v = 2 L omega cos theta$ by Goal 1, step 7

55. $a = 2 L (alpha cos theta - omega^2 sin theta)$ by differentiation of (54)

56. $alpha = (a + 2 L omega^2 sin theta)/(2 L cos theta)$ by solving (55) for $alpha$, which is valid since $cos theta != 0$ and $L != 0$

57. $tau = L^2 [M + 2 (m_2 + 2 m_"car") cos^2 theta] (a + 2 L omega^2 sin theta)/(2 L cos theta) - 2 (m_2 + 2 m_"car") L^2 omega^2 sin theta cos theta + g K L cos theta$ by substitution of (36), (38), (47), (56) into (53)

58. $L^2 [M + 2 (m_2 + 2 m_"car") cos^2 theta] (a + 2 L omega^2 sin theta)/(2 L cos theta) = L [M + 2 (m_2 + 2 m_"car") cos^2 theta] (a + 2 L omega^2 sin theta)/(2 cos theta)$ by substitution

59. $L [M + 2 (m_2 + 2 m_"car") cos^2 theta] (a + 2 L omega^2 sin theta)/(2 cos theta) = L (M/(2 cos theta) + (m_2 + 2 m_"car") cos theta) (a + 2 L omega^2 sin theta)$ by substitution

60. $L (M/(2 cos theta) + (m_2 + 2 m_"car") cos theta) (a + 2 L omega^2 sin theta) = L (M/(2 cos theta) + (m_2 + 2 m_"car") cos theta) a + 2 L^2 omega^2 sin theta (M/(2 cos theta) + (m_2 + 2 m_"car") cos theta)$ by substitution

61. $2 L^2 omega^2 sin theta (M/(2 cos theta) + (m_2 + 2 m_"car") cos theta) = L^2 omega^2 (M tan theta + 2 (m_2 + 2 m_"car") sin theta cos theta)$ by substitution

62. $tau = L (M/(2 cos theta) + (m_2 + 2 m_"car") cos theta) a + M L^2 omega^2 tan theta + 2 (m_2 + 2 m_"car") L^2 omega^2 sin theta cos theta - 2 (m_2 + 2 m_"car") L^2 omega^2 sin theta cos theta + g K L cos theta$ by substitution of (58)–(61) into (57)

63. $tau = L (M/(2 cos theta) + (m_2 + 2 m_"car") cos theta) a + M L^2 omega^2 tan theta + g K L cos theta$ by substitution

64. #box(stroke: 0.6pt, inset: 8pt, $tau(theta, omega, a) = L [(M/(2 cos theta) + (m_2 + 2 m_"car") cos theta) a + M L omega^2 tan theta + g K cos theta]$) by substitution

== Goal 3

=== Find $alpha (theta, omega)$, the angular acceleration of the lower stage given angle $theta$ and angular velocity $omega$

== Goal 4

=== Find the time to raise the lift from an angle $theta_0$ to $theta_f$
