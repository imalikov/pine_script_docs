Line wrapping
=============

Any statement that is too long in Pine Script can be placed on more than
one line. Syntactically, a statement **must** begin at the beginning of the
line. If it wraps to the next line then the continuation of the
statement **must** begin with one or several (different from multiple of 4)
spaces. For example::

    a = open + high + low + close

may be wrapped as:

::

    a = open +
          high +
              low +
                 close

A long ``plot`` call may be wrapped as:

::

    plot(correlation(src, ovr, length),
       color=color.purple,
       style=plot.style_area,
       transp=40)

Statements inside user functions can also be wrapped.
However, since a local statement must syntactically begin with an
indentation (4 spaces or 1 tab), when splitting it onto the
following line, the continuation of the statement must start with more
than one indentation (not equal to multiple of 4 spaces). For
example:

::

    updown(s) =>
        isEqual = s == s[1]
        isGrowing = s > s[1]
        ud = isEqual ?
               0 :
               isGrowing ?
                   (nz(ud[1]) <= 0 ?
                         1 :
                       nz(ud[1])+1) :
                   (nz(ud[1]) >= 0 ?
                       -1 :
                       nz(ud[1])-1)

Do not use comments with line wrapping.
The following code does NOT compile::

    //@version=4
    study("My Script")
    c = open > close ? color.red :
      high > high[1] ? color.lime : // a comment
      low < low[1] ? color.blue : color.black
    bgcolor(c)


The compiler fails with the error:
``Add to Chart operation failed, reason: line 3: syntax error at input 'end of line without line continuation'``.
To make this code compile, simply remove the ``// a comment`` comment.
