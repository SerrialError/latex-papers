$integral^sqrt(2)_0 [3/2 cos^(-1)(sqrt(2 / (2 + x^2))) + 1/4 sin^(-1)((2 sqrt(2) x) / (2 + x^2)) + tan^(-1)(sqrt(2)/x)] d x$

$x := tan t sqrt(2)$

$d x = sec^2 t sqrt(2) d t$

$sqrt(2) integral^(pi/4)_0 [3/2 cos^(-1)(sqrt(2 / (2 + (tan t sqrt(2))^2))) + 1/4 sin^(-1)((2 sqrt(2) (tan t sqrt(2))) / (2 + (tan t sqrt(2))^2)) + tan^(-1)(sqrt(2)/(tan t sqrt(2)))] sec^2 t d t$

$sqrt(2) integral^(pi/4)_0 [3/2 t + 1/4 sin^(-1)((2 tan t) / (sec^2 t)) + tan^(-1)(tan(pi/2 - t))] sec^2 t d t$

$sqrt(2) integral^(pi/4)_0 [3/2 t + 1/4 sin^(-1)((2 sin t cos^2 t) / (cos t))+ pi/2 - t] sec^2 t d t$

$sqrt(2) integral^(pi/4)_0 [1/2 t + pi/2 + 1/4 sin^(-1)(2 sin t cos t)] sec^2 t d t$

$sqrt(2) integral^(pi/4)_0 [1/2 t + pi/2 + 1/4 sin^(-1)(sin (2 t))] sec^2 t d t$

$sqrt(2) integral^(pi/4)_0 (1/2 t + pi/2 + 1/2 t) sec^2 t d t$

$sqrt(2) (integral^(pi/4)_0 t sec^2 t d t + pi/2 integral^(pi/4)_0 sec^2 t d t)$

$u := t$ $d v := sec^2 t$

$d u = d t$ $v = tan t$

$sqrt(2) (t tan t |^(pi/4)_0 - integral^(pi/4)_0 tan t d t + pi/2 tan t |^(pi/4)_0)$

$sqrt(2) (pi/4 - integral^(pi/4)_0 (sin t) / (cos t) d t + pi/2)$

$w := cos t$

$d w := -sin t d t$

$sqrt(2) ((3pi)/4 + integral^(sqrt(2)/2)_1 1 / w d w)$

$sqrt(2) ((3pi)/4 + ln|w| |^(sqrt(2)/2)_1)$

$sqrt(2) ((3pi)/4 - 1/2 ln 2)$

$(3 pi sqrt(2)) / 4 - (sqrt(2)) / 2 ln 2$
