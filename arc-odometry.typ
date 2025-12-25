#align(center)[
  #figure(
  image("arc-odometry-construction.png", width: 100%),
)
]

Given the measures of $l_l$, $theta_(r 0)$, and $theta_(r 1)$, the directed distance of $x_r$, $y_r$, $x_(t l)$, $y_(t l)$, $x_(t h)$, and $y_(t h)$, and $arrow(P_(t l 1) C_(t l 1))$ and $arrow(P_(t l 0) C_(t l 0))$ are $perp$ to the tangent lines at the at points $C_(t l 1)$ and $C_(t l 0)$ on $arrow(overparen(C_(t r 0) C_(t r 1)))$; find the directed distance of $Delta x_r$ and $Delta y_r$

The measures of $l_l$, $theta_(r 0)$, and $theta_(r 1)$ and the directed distance of $x_r$, $y_r$, $x_(t l)$, $y_(t l)$, $x_(t h)$, and $y_(t h)$ because they are given

Let $phi_0$ be the angle $overline(B_r C_(t l 0))$ makes with the x-axis

Let $phi_1$ be the angle $overline(B_r C_(t l 1))$ makes with the x-axis

$Delta theta_r + phi_0 = phi_1$ by the $angle$ add. post.

$theta_(r 1) = phi_1 + pi / 2$ and $theta_(r 0) = phi_0 + pi / 2$ by the tangent radius theorem

$Delta theta_r = phi_1 - phi_0$, $phi_1 = theta_(r 1) - pi / 2$, and $phi_0 = theta_(r 0) - pi / 2$ by subtraction

$Delta theta_r = theta_(r 1) - pi / 2 - (theta_(r 0) - pi / 2)$ by substitution

$Delta theta_r = theta_(r 1) - pi / 2 - theta_(r 0) + pi / 2$ by multiplication

$Delta theta_r = theta_(r 1) - theta_(r 0)$ by substitution

$r_l = r_r + x_(t l)$ by the segment addition postulate

$r_r = r_l - x_(t l)$ by subtraction

$l_r = r_r Delta theta_r$ by the arc length formula

$l_r / (Delta theta_r) = r_r$ by division

$M_l A = Delta x_l$ by the definition of $tilde.equiv$ line segments

$A B_l = B_l M_l + M_l A$ by the sement addition postulate

$A B_l - M_l A = B_l M_l$ by subtraction

$A B_l - Delta x_l = B_l M_l$ by substitution

$l_l / theta_l - Delta x_l = B_l M_l$ by substitution

$Delta y_l$ is an opposite side to $angle theta_l$ by the definition of an opposite side

$overline(A B_l)$ is an adjacent side to $angle theta_l$ by the definition of an adjacent side

$overline(A B_l)$ is the hypotenuse of $triangle.stroked.t B M C$ by as the side opposite to the right $angle$ of a $triangle.stroked.t$ is the hypotenuse

$sin(theta_l) = (Delta y_l) / (A_l B_l)$, $cos(theta_l) = (B_l M_l) / (A B_l)$ by the definition of sine and cosine in right angle trigonometry

$sin(theta_l) = (Delta y_l) / (l_l / theta)$, $cos(theta_l) = (A B_l - Delta x_l) / A B_l$ by substitution

$(l_l / theta_l) sin(theta_l) = Delta y_l$, $A B_l cos(theta_l) = A B_l - Delta x_l$ by multiplication

$A B_l cos(theta_l) - A B_l = - Delta x_l$ by substraction

$- A B_l cos(theta_l) + A B_l = Delta x_l$ by division

$- A B_l (cos(theta_l) + 1) = Delta x_l$ by substitution

$- (l_l / theta_l) (cos(theta_l) + 1) = Delta x_l$ by substitution

$(l_l / theta_l) (cos(theta_l) + 1) = Delta x_l$ by the magnitude of $overline(B_l A)$
