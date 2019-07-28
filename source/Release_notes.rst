Release notes
=============

.. contents:: :local:
    :depth: 2

This page contains release notes of notable changes in Pine Script.

Pine version 4 (June 2019)
--------------------------

* Support for drawing objects. Added *label* and *line* drawings
* ``var`` keyword for one time variable initialization
* Type system improvements:

  * *series string* data type
  * functions for explicit type casting
  * syntax for explicit variable type declaration
  * new *input* type forms

* Renaming of built-ins and a version 3 to 4 converter utility
* ``max_bars_back`` function to control series variables internal history buffer sizes
* Pine Script documentation versioning


Pine version 3 (17 May 2017)
----------------------------

Added `compile-time constants <https://blog.tradingview.com/en/possibilities-compile-time-constants-4127/>`__.
Pine Script used to have 3 types of constants ---
literal, non-literal and
serial. Now there's one more, but let's look at existing ones first.

Some functions (``input``, ``color``) could only accept literals as
arguments. To make it more convenient, we added a
new type of constants that can be calculated during compilation. In
addition to literals, they include mathematical expressions that use
other literals and constants.

Any type of Pine Script literal (integer, float, boolean, string) is the
most narrow type while the serial type is the most general one. The
compilation-time constants take a spot between the literal and
non-literal types. All of the functions that accepted literal as an
argument will now accept compilation-time constants as well.

Pine version 3 (26 Apr 2017)
----------------------------

Added `string input with options <https://blog.tradingview.com/en/several-new-features-added-pine-scripting-language-3933/>`__.
Some built-in indicators have a setting that lets you choose several
options. The same is possible in Pine Script now. For example::

    //@version=3
    study("Input with Options")
    s = input(title="Session", defval="24x7", options=["24x7", "0900-1300", "1300-1700", "1700-2100"])
    plot(time(period, s))

.. _kwargs_syntax_for_all_builtin_functions:

Pine version 3 (17 Apr 2017)
----------------------------

Added `kwargs syntax <https://blog.tradingview.com/en/kwargs-syntax-now-covers-built-functions-3914/>`__ for all built-in functions.
Pinescript had different calls for annotation functions (``study``, ``plot``, ...)
and built-in functions (``sma``, ``security``, ...). Annotation functions used to
accept keyword arguments while built-in functions didn't.

You are now able to call all built-in functions using keyword arguments.
This will be especially useful for the ``security`` function to specify the
``lookahead`` argument but skip the gaps argument::

    security('TSLA', 'D', close, lookahead=barmerge.lookahead_off)

.. _release_notes_v3:

Pine version 3 (20 Mar 2017)
----------------------------

`Repainting <https://getsatisfaction.com/tradingview/topics/strategies-and-indicators-are-repainting>`__
and `backtesting <https://getsatisfaction.com/tradingview/topics/backtesting-using-higher-time-frames-is-a-complete-lie>`__
issues have been reported for some time. These issues are not identical,
but they are interrelated. Version 3 aims to solve the backtesting
issue. Here's a more detailed explanation.

Repainting issue
~~~~~~~~~~~~~~~~

There's a substantial difference between historical and real-time data
that a Pine Script study or strategy uses. The key difference: a
historical bar does NOT contain information about price movements
between *high* and *low* of a bar. Only a few Pine Script language tools are
sensitive to this difference, read more :doc:`/essential/Indicator_repainting`.

Here is a basic example that describes this case::

    //@version=2
    study("My Script")
    a = barstate.isrealtime or barstate.islast ? close : na
    plot(a)

The above script is based on historical data and always returns ``na``. It
can be plotted only on the last bar of both historical and real-time
data. After each chart reload (after pressing *F5*) the border that
divides historical data and real-time will be shifted, in accordance
with the current time period.

Backtesting issue
~~~~~~~~~~~~~~~~~

The second issue is a security function that allows you to get "future"
data while doing calculations using historical data. For example:
``security(tickerid, "D", high)`` on historical data will show the daily
high price on the first hourly bar of the whole day. This can be used to
create an incorrect backtesting strategy::

    //@version=2
    strategy("Fake strategy", overlay=true)

    r = input("D", type=resolution)
    l = security(tickerid, r, low)
    h = security(tickerid, r, high)

    longCondition = low == l
    if (longCondition)
        strategy.entry("My Long Entry Id", strategy.long)

    shortCondition = high == h
    if (shortCondition)
        strategy.entry("My Short Entry Id", strategy.short)

However, we believe that this type of behavior of the security function
could be useful when it's being used in studies. For instance,
`ChrisMoody <https://www.tradingview.com/u/ChrisMoody/>`__
uses this effect in a popular indicator called
`CM_Pivot Points_M-W-D-4H-1H_Filtered <https://www.tradingview.com/script/kqKEuQpn-CM-Pivot-Points-M-W-D-4H-1H-Filtered/>`__
(over 3000 likes) that is used to create pivot lines. Other examples include:
`Open Close Daily Line <https://www.tradingview.com/script/qDvoNB8f-Open-Close-Daily-Line/>`__,
`Time Frame Superimpose <https://www.tradingview.com/script/QCvh8Cyx-Time-Frame-Superimpose/>`__,
as well as the
`Get Satisfaction comment <https://getsatisfaction.com/tradingview/topics/strategies-and-indicators-are-repainting#reply_18341804>`__.
We decided that the old behavior will remain available only when it's explicitly indicated.

By default, in Pine Script version 3, the ``security`` function will NOT return future data (in contrast to version 2).
We also added the new ``lookahead`` parameter with two values:
`barmerge.lookahead_off <https://www.tradingview.com/pine-script-reference/v4/#var_barmerge.lookahead_off>`__
and
`barmerge.lookahead_on <https://www.tradingview.com/pine-script-reference/v4/#var_barmerge.lookahead_on>`__
to switch between the new and old behavior of the
`security <https://www.tradingview.com/pine-script-reference/v4/#fun_security>`__
function. Detailed description of this parameter can be found in the section :ref:`barmerge_gaps_and_lookahead`.

Other changes
~~~~~~~~~~~~~

* Self-referenced and forward-referenced variables are removed.
* Math operations with booleans are forbidden.

See :doc:`appendix/Pine_version_3_migration_guide` for more
details.


Pine version 2
--------------

-  :ref:`Variable assignment<variable_assignment>` (or mutable variables),
-  :ref:`if_statement`,
-  :ref:`for_statement`,

