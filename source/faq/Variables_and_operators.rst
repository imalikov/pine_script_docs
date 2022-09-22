.. _PageVariablesAndOperatorsFaq:

.. image:: /images/Pine_Script_logo.svg
   :alt: Pine Script™ logo
   :target: https://www.tradingview.com/pine-script-docs/en/v5/Introduction.html
   :align: right
   :width: 100
   :height: 100


Variables and operators FAQ
===========================


.. contents:: :local:
    :depth: 3



What is the variable name for the current price?
------------------------------------------------

The `close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ variable holds both the price at the 
`close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ of historical bars and the current price when an indicator runs on the real-time bar. 
If the script is a strategy running on the real-time bar, it runs only at the bar’s `close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__. 
If the ``calc_on_every_tick`` parameter of the `strategy() <https://www.tradingview.com/pine-script-reference/v5/#fun_strategy>`__ declaration statement is set to 
`true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__, the strategy will behave as an indicator and run on every price change of the real-time bar.

To access the `close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ of the previous bar’s 
`close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ in Pine Script™, use ``close[1]``. 
In Pine Script™, brackets are used as the history-referencing operator.



Why and when should the ‘var’ keyword be used together with a variable? 
-----------------------------------------------------------------------

The `var <https://www.tradingview.com/pine-script-reference/v5/#op_var>`__ keyword is ideal for when you want to save data between bars. 
If you declare a variable without using the `var <https://www.tradingview.com/pine-script-reference/v5/#op_var>`__ keyword, then it won't save the data between each bar. 
For the example below, we are illustrating how you could plot an all-time `high <https://www.tradingview.com/pine-script-reference/v5/#var_high>`__ using the 
`var <https://www.tradingview.com/pine-script-reference/v5/#op_var>`__ keyword compared to a typical 
`float <https://www.tradingview.com/pine-script-reference/v5/#op_float>`__ variable.

::

    //@version=5
    indicator("Var float vs regular float example")

    float maxFloat = high
    var float maxVar = high

    if high > maxFloat
        maxFloat := high
        
    if high > maxVar
        maxVar := high
        
    plot(maxFloat, color = color.red)
    plot(maxVar, color = color.blue)



What is a ‘varip’?
------------------

The `varip <https://www.tradingview.com/pine-script-reference/v5/#op_varip>`__ keyword is virtually identical to the 
`var <https://www.tradingview.com/pine-script-reference/v5/#op_var>`__ keyword with one notable exception: the variable declared with the 
`varip <https://www.tradingview.com/pine-script-reference/v5/#op_varip>`__ keyword will remember its value across multiple updates and bars. 
Here is an example displaying that the only difference between both keywords is that the 
`varip <https://www.tradingview.com/pine-script-reference/v5/#op_varip>`__ variable will increase between bars using real-time data while the 
`var <https://www.tradingview.com/pine-script-reference/v5/#op_var>`__ variable doesn't change.

::

    //@version=5
    indicator("Varip vs var example")

    var int varCount = -1
    varCount := varCount + 1

    varip int varipCount = -1
    varipCount := varipCount + 1
        
    plot(varCount, color = color.red)
    plot(varipCount, color = color.blue)



What is the code for an up bar?
-------------------------------

::

    upBar = close > open

Once you have defined the ``upBar`` variable, if you wanted a `bool <https://www.tradingview.com/pine-script-reference/v5/#op_bool>`__ variable to be 
`true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__ when the last three bars were up bars, you could write:

::

    threeUpBars = upBar and upBar[1] and upBar[2]

You could also achieve the same using:

::

    threeUpBars = sum(upBar ? 1 : 0, 3) == 3

Which produces a value of 1 every time the ``upBar`` boolean variable is `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__, 
and adds the number of those values for the last 3 bars. When that rolling sum equals 3, ``threeUpBars`` is `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__.
Note that the variable name ``3UpBars`` would have caused a compilation error. In addition, it is not legal in Pine Script™ as it begins with a digit.

If you wanted to have a condition `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__ when there were seven or more up bars in the last 10, you could use:

::

    sevenUpBarsInLastTen = math.sum(upBar ? 1 : 0, 10) >= 7

If you need to define up and down bars and want to account for all possibilities, make sure one of those definitions allows for the case where 
`open <https://www.tradingview.com/pine-script-reference/v5/#var_open>`__ and `close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ are equal:

::

    upBar = close > open
    dnBar = not upBar

In this case, when ``close == open``, ``upBar`` will be `false <https://www.tradingview.com/pine-script-reference/v5/#op_false>`__ and ``dnBar`` will be 
`true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__.

You can use these functions below to define further what constitutes an up and down bar. 
They are helpful on smaller timeframes when the price does not move during bars. However, these combined functions do not account for all possible situations, 
as none of them will return `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__ when the price does not move during a bar, and the bar closes 
at the same level as the previous bar. These functions also use price values that are rounded to tick precision (see the following FAQ entry for the reasons why that can be useful):

::

    //@version=5
    indicator("Up or down bar example")
    roundToOHLCTicks() =>
        [math.round_to_mintick(open), math.round_to_mintick(high), math.round_to_mintick(low), math.round_to_mintick(close)]
    [o, h, l, c] = roundToOHLCTicks()
    // ————— Function returning true when a bar is considered to be an up bar.
    isBarUp() =>
        // Dependencies: `o` and `c`, which are the open and close values rounded to tick precision.
        // Account for the normal "close > open" condition, but also for zero movement bars when their close is higher than previous close.
        result = c > o or c == o and c > nz(c[1], c)
    // ————— Function returning true when a bar is considered to be a down bar.
    isBarDn() =>
        // Dependencies: `o` and `c`, which are the open and close values rounded to tick precision.
        // Account for the normal "close < open" condition, but also for zero movement bars when their close is lower than previous close.
        result = c < o or c == o and c < nz(c[1], c)
    plot(na)



Why do the OHLC built-ins sometimes return different values than the ones shown on the chart?
---------------------------------------------------------------------------------------------

Data feeds sometimes contain prices that exceed the symbol’s tick precision. 
When this happens, the value returned by the `close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ built-in variable may differ from the chart’s 
`close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ value. This is because chart prices are always rounded to tick precision, 
but built-in variables are not. This makes it possible for occurrences like the one illustrated here, where the exchange feed contains a 
`close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ price of ``30181.07``is more precise than the symbol’s ``0.1`` tick size. 
In that case, the chart will show ``30181.1, `` but the `close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ 
built-in’s value will be the feed’s value of ``30181.07``.

The difference is subtle, but such discrepancies should be considered when troubleshooting unexpected script behavior or designing precision-critical calculations. 
Crossover detections are an example of calculations that can be affected.

One solution is to force a rounding of OHLC built-ins and use the rounded values in further calculations, as is done in this example script, 
which spots discrepancies between the evaluation of the ``open == close`` conditional expression with and without rounded values:

.. image:: /images/TradingView-Logo-Block.svg

::

    //@version=5
    indicator("Different tick values example 1", overlay = true, precision = 10)
    o = math.round_to_mintick(open)
    c = math.round_to_mintick(close)
    bgcolor(o == c and open != close ? color.new(color.red, 90) : na)
    plotchar(o, "o", "", location.top, size = size.tiny)
    plotchar(c, "c", "", location.top, size = size.tiny)
    plotchar(open, "open", "", location.top, size = size.tiny)
    plotchar(close, "close", "", location.top, size = size.tiny)

You can also use this version of the function which returns rounded OHLC values in a single call:

::

    //@version=5
    indicator("Different tick values example 2", precision = 10)
    roundToOHLCTicks() =>
        [math.round_to_mintick(open), math.round_to_mintick(high), math.round_to_mintick(low), math.round_to_mintick(close)]
    getTickColor(_v1, _v2) =>
        _v1 != _v2 ? color.red : color.blue

    [o, h, l, c] = roundToOHLCTicks()

    plotchar(o, "o", "", location.top, getTickColor(o, open))
    plotchar(open, "open", "", location.top, getTickColor(o, open))
    plotchar(h, "h", "", location.top, getTickColor(h, high))
    plotchar(high, "high", "", location.top, getTickColor(h, high))
    plotchar(l, "l", "", location.top, getTickColor(l, low))
    plotchar(low, "low", "", location.top, getTickColor(l, low))
    plotchar(c, "c", "", location.top, getTickColor(c, close))
    plotchar(close, "close", "", location.top, getTickColor(c, close))

    bgcolor(o != open or h != high or l != low or c != close ? color.new(color.red, 90) : na)



What’s the difference between ==, =, and :=?
-------------------------------------------

== is a `comparison operator <https://www.tradingview.com/pine-script-docs/en/v5/language/Operators.html#comparison-operators>`__ used to test for true/false conditions.
= is used to `declare and initialize variables <https://www.tradingview.com/pine-script-docs/en/v5/language/Variable_declarations.html>`__.
:= is used to `assign values to variables <https://www.tradingview.com/pine-script-docs/en/v5/language/Variable_declarations.html#variable-reassignment>`__ 
after initialization, transforming them into mutable variables.

::

    //@version=5
    indicator("Variable operators example")
    a = 0
    b = 1
    plot(a == 0 ? 1 : 2)
    plot(b == 0 ? 3 : 4, color=color.new(color.orange, 0))
    a := 2
    plot(a == 0 ? 1 : 2, color=color.new(color.aqua, 0))



Can I use the := operator to assign values to past values of a series?
----------------------------------------------------------------------

No. Past values in a Pine Script™ series are read-only, as is the past in real life. Only the current bar instance (``variableName[0]``) of a series variable 
can be assigned a value, and when you do, only the variable name and not the [] history-referencing operator must be used.

You can create a series with the values you require as the script is executed, bar by bar. 
The following code creates a new series called ``range`` with a value containing the difference between the bar’s 
`close <https://www.tradingview.com/pine-script-reference/v5/#var_close>`__ and `open <https://www.tradingview.com/pine-script-reference/v5/#var_open>`__, 
but only when it is positive. Otherwise, the series value is zero.

::

    range = close > open ? close - open : 0.0

In the previous example, we could determine the value to assign to the ``range`` series variable as we reviewed each bar in the dataset because the condition 
used to assign values was known on that bar. Sometimes, you will only obtain enough information to identify the condition after several bars have elapsed. 
In such cases, a for loop must be used to go back in time and analyze past bars. This will be the case in situations where you want to identify fractals or pivots. 

::

    //@version=5
    indicator("Pivot Points High Low", shorttitle = "Pivots HL2", overlay = true)

    lenH = input.int(title = "Length High", defval = 10, minval = 1)
    lenL = input.int(title = "Length Low", defval = 10, minval = 1)

    getPivotLevel(src, len, isHigh, pivotStyle, pivotYloc, pivotColor) =>
        pHi = ta.pivothigh(src, len, len)
        pLo = ta.pivotlow(src, len, len)
        
        if isHigh and not na(pHi)
            label.new(bar_index[len], pHi, str.tostring(pHi), style = pivotStyle, yloc = pivotYloc, color = pivotColor)
        else if not isHigh and not na(pLo)
            label.new(bar_index[len], pLo, str.tostring(pLo), style = pivotStyle, yloc = pivotYloc, color = pivotColor)

    getPivotLevel(high, lenH, true, label.style_label_down, yloc.abovebar, color.lime)
    getPivotLevel(low, lenL, false, label.style_label_up, yloc.belowbar, color.red)



Why do some logical expressions not evaluate as expected when na values are involved?
-------------------------------------------------------------------------------------

Pine Script™ logical expressions have three possible values: `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__, 
`false <https://www.tradingview.com/pine-script-reference/v5/#op_false>`__, and `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__. 
Whenever a `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__ value is used in a logical expression, the result of the logical expression will be 
`na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__. 
Thus, contrary to what could be expected, ``na == na``, ``na == true``, ``na == false``, or ``na != true`` all evaluate to 
`na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__. Furthermore, when a logical expression evaluates to 
`na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__, the `false <https://www.tradingview.com/pine-script-reference/v5/#op_false>`__ 
branch of a conditional statement will be executed. This may lead to unexpected behavior and entails that special cases must be accounted for if you want your code to 
handle all possible logical expression results according to your expectations.

Let’s take a case where, while we are debugging code, we want to compare two variables that should always have the same value, 
but where one of the variables or both can have a `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__ value. 
When that is the case, neither ``a == b`` nor ``a != b`` will return `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__ or 
`false <https://www.tradingview.com/pine-script-reference/v5/#op_false>`__, as they both return `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__.

When we understand this, we can see why the first `bgcolor() <https://www.tradingview.com/pine-script-reference/v5/#fun_bgcolor>`__ line in the following code shows no background. 
While you could expect the ``a != b`` logical expression to be `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__ and thus the background to appear ``lime`` 
This is not the case because the value of variable ``a`` does not equal the value of ``b``. 
Because the logical expression returns `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>`__, the 
`false <https://www.tradingview.com/pine-script-reference/v5/#op_false>`__ branch of the ternary is executed, and no color is plotted in the background.

The second `bgcolor() <https://www.tradingview.com/pine-script-reference/v5/#fun_bgcolor>`__ line will produce the expected behavior. 
You will see this if you comment out the first one and uncomment the second line. The other lines show different variations of this concept.

::

    //@version=5
    indicator("Na example")
    int a = 1
    int b = na
    bgcolor(a != b ? color.lime : na, transp=20)  // na, so goes to the false branch.
    // bgcolor(a == b ? na : color.red, transp = 20) // na, so goes to the false branch.
    // bgcolor(na((a != b)) ? color.orange : na, transp = 20) // true, so this works.
    // bgcolor(a != b or na(a != b) ? color.fuchsia : na, transp = 20) // true, so this works.




.. image:: /images/TradingView-Logo-Block.svg
    :width: 200px
    :align: center
    :target: https://www.tradingview.com/