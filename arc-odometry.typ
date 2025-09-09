#import "@preview/cetz:0.4.1"

#let r = 10
#let h = r * (calc.sin(50deg))/(calc.sin(65deg))
#let x = r - h*(calc.cos(65deg))
#let y = h*(calc.sin(65deg))
#cetz.canvas({
  import cetz.draw: *

  arc((r,0), start: 0deg, stop: 50deg, radius: r, mode: "PIE", name: "myarc")
  content((0.5,0.2), $ theta $)
  content((-.2,-0.2), $B$)
  content((9.5,0.3), $ alpha $)
  content((10.2,-0.2), $A$)
  content((6.4,7.9), $C$)
  line((r,0),(x, y))
  line((x, y),(x,0))
  content((7,-0.2), $ Delta x $)
  content((6,4), $ Delta y $)
  content((9,5), $ l $)
  rect((7, -3),(13, 3))
  line((8.5,-.5),(8.5,.5))
})

Given the measures of $l$ and $theta$; AC is an arc; find $Delta x$ and $Delta y$

The measures of $l$ and $theta$ and AC is an arc because they are given

$l = r theta$ by the arc length formula in radians

$l = (c + Delta x_v) theta$ by substitution

$l / theta = c + Delta x_v$ by division

$l / theta - Delta x_v = c$ by subtraction

$overline(A B) tilde.equiv overline(B C)$ because radii $tilde.equiv$

$A B = B C$ by the definition of $tilde.equiv$ segments

$triangle.stroked.t A B C$ is an isosceles $triangle.stroked.t$ by the definition of an isosceles $triangle.stroked.t$

$alpha tilde.equiv angle B C A$ by base $angle$'s $tilde.equiv$

$alpha = m angle B C A$ by the definition of $tilde.equiv$ $angle$'s

$pi = theta + alpha + m angle B C A$ by the $angle$ sum Th. in radians

$pi = theta + alpha + alpha$ by substitution

$pi = theta + 2 alpha$ by substitution

$pi - theta = 2 alpha$ by subtraction

$(pi - theta) / 2 = alpha$ by subtraction

$pi / 2 - theta / 2 = alpha$ by the distributive property

$a / sin(alpha) = b / sin(theta)$ by the Law of Sines

$(l / theta - Delta x_v) / sin(pi / 2 - theta / 2) = b / sin(theta)$ by substitution

$cos(pi / 2 - x) = sin(x)$ and $sin(pi / 2 - x) = cos(x)$ by the complementary-angle identities

$(l / theta - Delta x_v) / cos(theta / 2) = b / sin(theta)$ by substitution

$l / (cos(theta / 2) theta) = b / sin(theta)$ by the associative property

$sin(theta) (l / (cos(theta / 2) theta)) = b$ by multiplication

$(sin(theta) l) / (cos(theta / 2) theta) = b$ by the distributive property

$sin(2x) = 2 sin(x) cos(x)$ by the sine double-angle formula

$sin(x) = 2 sin(x / 2) cos(x / 2)$ by division

$(2 sin(theta / 2) cos(theta / 2) l) / (cos(theta / 2) theta) = b$ by substitution

$(2 sin(theta / 2)) (l / theta - Delta x_v) = b$ by division

$sin(alpha) = "opposite" / "hypotenuse"$ by the definition of sine in right angle trigonometry

$cos(alpha) = "adjacent" / "hypotenuse"$ by the definition of cosine in right angle trigonometry

$sin(alpha) = (Delta y) / b$ and $cos(alpha) = (- Delta x) / b$ by substitution

$b sin(alpha) = Delta y$ and $b cos(alpha) = - Delta x$ by multiplication

$(2 sin(theta / 2)) (l / (theta) - Delta x_v) sin(alpha) = Delta y$ and $(2 sin(theta / 2)) (l / (theta) - Delta x_v) cos(alpha) = - Delta x$ by substitution

$(2 sin(theta / 2)) (l / theta - Delta x_v) sin(pi / 2 - theta / 2) = Delta y$ and $(2 sin(theta / 2)) (l / theta - Delta x_v) cos(pi / 2 - theta / 2) = - Delta x$ by substitution

$(2 sin(theta / 2)) (l / theta - Delta x_v) cos(theta / 2) = Delta y$ and $(2 sin(theta / 2)) (l / theta - Delta x_v) sin(theta / 2) = - Delta x$ by substitution

$(2 sin(theta / 2) cos(theta / 2)) (l / theta - Delta x_v) = Delta y$ and $(2 sin(theta / 2) sin(theta / 2)) (l / theta - Delta x_v) = - Delta x$ by the associative property

$sin(theta) (l / theta - Delta x_v) = Delta y$ and $(2 sin^2(theta / 2) (l / theta - Delta x_v) = - Delta x$ by substitution

$- 2 sin^2(theta / 2) (l / theta - Delta x_v) = Delta x$ by division

$sin^2(x) = (1 - cos(2 x))/2$ by the sine lowering power formula

$- 2 ((1 - cos(theta)) / 2) (l / theta - Delta x_v) = Delta x$ by substitution

$- ((1 - cos(theta)) (l / theta - Delta x_v) = Delta x$ by the associative property

$(l / theta - Delta x_v) (-1 + cos(theta)) = Delta x$ by substitution
