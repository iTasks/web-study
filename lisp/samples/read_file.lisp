(include <stdio.h>)

(function main () -> int
  (decl ((int c)
         (int nl = 0))
    (while (!= (set c (getchar)) EOF)
      (if (== c #\newline)
          ++nl))
    (printf "%d\\n" nl)
    (return 0)))
