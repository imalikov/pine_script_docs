Pine compilation errors
=======================

.. contents:: :local:
    :depth: 2

Script requesting too many securities
-------------------------------------

The maximum number of securities in script is limited to 40. If you
declare a variable as a ``security`` function call and then use that variable as
input for other variables and calculations, it will not result in
multiple ``security`` calls. But if you will declare a function that calls
``security`` --- every call to this function will count as a ``security`` call.

It is not easy to say how many securities will be called looking at the
source code. Following example have exactly 3 calls to ``security``
after compilation:

::

    //@version=4
    study("Securities count")
    a = security(syminfo.tickerid, '42', close)  // (1) first unique security call
    b = security(syminfo.tickerid, '42', close)  // same call as above, will not produce new security call after optimizations

    plot(a)
    plot(a + 2)
    plot(b)

    sym(p) =>  // no security call on this line
        security(syminfo.tickerid, p, close)
    plot(sym('D'))  // (2) one indirect call to security
    plot(sym('W'))  // (3) another one indirect call to security

    security(syminfo.tickerid, timeframe.period, open)  // result of this line is never used, and will be optimized-out



Script could not be translated from: null
-----------------------------------------

::

    study($)

Usually this error occurs in version 1 pine scripts, and means that code
is incorrect. Pine of version 2 (and higher) is better at
explaining errors of this kind. So you can try to switch to version 2 by
adding a :ref:`special attribute <versions>` in the first line. You'll get
``line 2: no viable alternative at character '$'``

::

    // @version=2
    study($)

line 2: no viable alternative at character '$'
----------------------------------------------

This error message gives a hint on what is wrong. ``$`` stands in place
of string with script title. For example::

    // @version=2
    study("title")


Mismatched input <...> expecting <???>
--------------------------------------

Same as ``no viable alternative``, but it is known what should be at that
place. Example::

    //@version=4
    study("My Script")
        plot(1)

``line 3: mismatched input 'plot' expecting 'end of line without line continuation'``

To fix this you should start line with ``plot`` on a new line without an
indent::

    //@version=4
    study("My Script")
    plot(1)

Loop is too long (> 200 ms)
---------------------------

We limit the computation time of loop on every historical bar and
realtime tick to protect our servers from infinite or very long loops.
This limit also fail-fast indicators that will take too long to compute.
For example, if you'll have 5000 bars, and indicator takes 200 milliseconds to
compute on each of bars, it would have result in more than 16 minutes of
loading.

::

    //@version=4
    study("Loop is too long", max_bars_back=101)
    s = 0
    for i = 1 to 1e3  // to make it longer
        for j = 0 to 100
            if timestamp(2017, 02, 23, 00, 00) <= time[j] and time[j] < timestamp(2017, 02, 23, 23, 59)
                s := s + 1
    plot(s)

It might be possible to optimize algorithm to overcome this error. In
this case, algorithm may be optimized like this:

::

    //@version=4
    study("Loop is too long", max_bars_back=101)
    bar_back_at(t) =>
        i = 0
        step = 51
        for j = 1 to 100
            if i < 0
                i := 0
                break
            if step == 0
                break
            if time[i] >= t
                i := i + step
                i
            else
                i := i - step
                i
            step := step / 2
            step
        i

    s = 0
    for i = 1 to 1e3  // to make it longer
        s := s - bar_back_at(timestamp(2017, 02, 23, 23, 59)) +
             bar_back_at(timestamp(2017, 02, 23, 00, 00))
        s
    plot(s)

Script has too many local variables
-----------------------------------

This error appears if the script is too large to be compiled. A
statement ``var=expression`` creates a local variable for ``var``. Apart
from this, it is important to note, that auxiliary variables can be
implicitly created during the process of a script compilation. The limit
applies to variables created both explicitly and implicitly. The
limitation of 1000 variables is applied to each function individually.
In fact, the code placed in a *global* scope of a script also implicitly
wrapped up into the main function and the limit of 1000 variables
becomes applicable to it. There are few refactorings you can try to
avoid this issue::

    var1 = expr1
    var2 = expr2
    var3 = var1 + var2

can be сonverted into::

    var3 = expr1 + expr2

