.. image:: /images/Pine_Script_logo.svg
   :alt: Pine Script™ logo
   :target: https://www.tradingview.com/pine-script-docs/en/v5/Introduction.html
   :align: right
   :width: 100
   :height: 100

   
.. _PageTechniquesFaq:


Techniques FAQ
==============


.. contents:: :local:
    :depth: 3



How do I prevent the ‘x1 is too far from the current bar_index’ error?
------------------------------------------------------------------



How can I update all x2/right side of all lines/boxes in an \'array.new_line()\' / \'array.new_box()\'?
-----------------------------------------------------------------------------------------------



How to avoid repainting when using the \'request.security()\' function?
-----------------------------------------------------------

See the discussion published with the PineCoders indicator script: 
`How to avoid repainting when using request.security() <https://www.tradingview.com/script/cyPWY96u-How-to-avoid-repainting-when-using-security-PineCoders-FAQ/>`__

The easiest way is to use the following syntax for v5:

::

    request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

This is how you do it for v4:

::

    security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

And this is the method for v3:

::

    security(tickerid, "D", close[1], lookahead = barmerge.lookahead_on)



How to avoid repainting when NOT using the \'request.security()\' function?
---------------------------------------------------------------

See the discussion published with the PineCoders indicator script: 
`How to avoid repainting when NOT using request.security() <https://www.tradingview.com/script/s8kWs84i-How-to-avoid-repainting-when-NOT-using-security/>`__

The general idea is to use the confirmed information from the last bar for calculations.



How can I trigger a condition only when a number of bars have elapsed since the last condition occurred?
--------------------------------------------------------------------------------------------------------

Use the `ta.barssince() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}barssince>`__ function.

::

    //@version=5
    indicator("Bars since example", overlay = true)
    len = input(3)
    cond = close > open and close[1] > open[1]
    trigger = cond and ta.barssince(cond[1]) > len - 1
    plotchar(cond)
    plotchar(trigger, "", "O", color = color.new(color.red, 0))



How can my script identify what chart type is active?
-----------------------------------------------------

Use everget’s `Chart Type Identifier <https://www.tradingview.com/script/8xCRJkGR-RESEARCH-Chart-Type-Identifier/>`__.



How can I plot the chart’s historical high and low?
---------------------------------------------------



How can I remember when the last time a condition occurred?
-----------------------------------------------------------



How can I plot the previous and current day’s open?
---------------------------------------------------



How can I count the occurrences of a condition in the last x bars?
------------------------------------------------------------------



How can I implement an On/Off switch?
--------------------------------------

::

    //@version=5
    indicator("On/Off condition example", "", true)
    upBar = close > open
    // On/off conditions.
    triggerOn = upBar and upBar[1] and upBar[2]
    triggerOff = not upBar and not upBar[1]
    // Switch state is implicitly saved across bars thanks to initialize-only-once keyword "var".
    var onOffSwitch = false
    // Turn the switch on when triggerOn is true. If it is already on,
    // keep it on unless triggerOff occurs.
    onOffSwitch := triggerOn or onOffSwitch and not triggerOff
    bgcolor(onOffSwitch ? color.new(color.green, 90) : na)
    plotchar(triggerOn, "triggerOn", "▲", location.belowbar, color.new(color.lime, 0), size = size.tiny, text = "On")
    plotchar(triggerOff, "triggerOff", "▼", location.abovebar, color.new(color.red, 0), size = size.tiny, text = "Off")



How can I allow transitions from condition A►B or B►A, but not A►A nor B►B
--------------------------------------------------------------------------

One way to do it is by using `ta.barssince() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}barssince>`__. This method is more flexible and faster:

::

    //@version=5
    //@author=LucF, for PineCoders
    indicator("AB or BA example", "", true)

    // ————— Trigger conditions.
    bool upBar        = close > open
    bool condATrigger = upBar and upBar[1]
    bool condBTrigger = not upBar and not upBar[1]
    // ————— Conditions. These variable will only be true/false on the bar where they occur.
    bool condA = false
    bool condB = false
    // ————— State variable set to true when last triggered condition was A, and false when it was condition B.
    // This variable"s state is propagated troughout bars (because we use the "var" keyword to declare it).
    var bool LastCondWasA = false

    // ————— State transitions so that we allow A►B or B►A, but not A►A nor B►B.
    if condATrigger and not LastCondWasA
        // The trigger for condA occurs and the last condition set was condB.
        condA := true
        LastCondWasA := true
    else
        if condBTrigger and LastCondWasA
            // The trigger for condB occurs and the last condition set was condA.
            condB := true
            LastCondWasA := false

    bgcolor(LastCondWasA ? color.new(color.green, 90) : na)
    plotchar(condA, "condA", "▲", location.belowbar, color.new(color.lime, 30), size = size.tiny, text = "A")
    plotchar(condB, "condB", "▼", location.abovebar, color.new(color.red, 30), size = size.tiny, text = "B")
    // Note that we do not plot the marker for triggers when they are allowed to change states, since we then have our condA/B marker on the chart.
    plotchar(condATrigger and not condA, "condATrigger", "•", location.belowbar, color.new(color.green, 0), size = size.tiny, text = "a")
    plotchar(condBTrigger and not condB, "condBTrigger", "•", location.abovebar, color.new(color.maroon, 0), size = size.tiny, text = "b")


Can I merge two or more indicators into one?
--------------------------------------------



How can I rescale an indicator from one scale to another?
---------------------------------------------------------



How can I monitor script run time?
----------------------------------



How can I save a value when an event occurs?
--------------------------------------------



How can I count touches of a specific level?
--------------------------------------------



What does the Return type of 'then' block (series[label]) is not compatible with return type of 'else' block (series[integer]) compilation error mean?
------------------------------------------------------------------------------------------------------------------------------------------------------



How can I know if something is happening for the first time since the beginning of the day?
-------------------------------------------------------------------------------------------

We show 3 techniques to do it. In the first, we use `ta.barssince() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}barssince>`__ to check if the number 
of bars since the last condition, plus one, is greater than the number of bars since the beginning of the new day.

In the second and third methods we track the condition manually, foregoing the need for `ta.barssince() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}barssince>`__. 
Method 2 is more readable. Method 3 is a more concise method.

::

    //@version=5
    indicator("First time since BOD example", "", true)
    bool cond = close > open

    // ————— Method 1.
    bool first1 = cond and ta.barssince(cond[1]) + 1 > ta.barssince(ta.change(time("D")))
    plotchar(first1, "first1", "•", location.top)

    // ————— Method 2.
    var bool allowTrigger2 = false
    bool first2 = false
    if ta.change(time("D"))
        allowTrigger2 := true
    if cond and allowTrigger2
        first2 := true
        allowTrigger2 := false
    plotchar(first2, "first2", "•", location.top, color = color.new(color.silver, 0), size = size.normal)

    // ————— Method 3.
    var bool allowTrigger3 = false
    bool first3 = false
    allowTrigger3 := ta.change(time("D")) or allowTrigger3 and not first3[1]
    first3 := allowTrigger3 and cond
    plotchar(first3, "first3", "•", location.top, color = color.new(color.orange, 0), size = size.large)



How can I optimize Pine Script™ code?
-------------------------------------



How can I access a stock's financial information using Pine Script™?
--------------------------------------------------------------------



How can I save a value from a signal when a pivot occurs?
---------------------------------------------------------



How can I find the maximum value among the last pivots?
-------------------------------------------------------

We will be finding the highest value of the last 3 `high <https://www.tradingview.com/pine-script-reference/v5/#var_high>`__ pivots here, 
but the technique can be extended to any number of pivots. We will be using `ta.valuewhen() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}valuewhen>`__ 
to fetch the value from the nth occurrence of a `high <https://www.tradingview.com/pine-script-reference/v5/#var_high>`__ pivot, 
remembering to offset the value we are retrieving with number of right legs used to detect the pivot, 
as a pivot is only detected after than number of bars has elapsed from the actual pivot bar.

::

    //@version=5
    indicator("Max pivot example", "", true)
    int legs    = input.int(4)
    float pH    = ta.pivothigh(legs, legs)
    bool newPH  = not na(pH)
    float p00   = ta.valuewhen(newPH, high[legs], 00)
    float p01   = ta.valuewhen(newPH, high[legs], 01)
    float p02   = ta.valuewhen(newPH, high[legs], 02)
    float maxPH = math.max(p00, p01, p02)
    plot(maxPH)
    plotchar(newPH, "newPH", "•", location.abovebar, offset = -legs)
    plotchar(newPH, "newPH", "▲", location.top)

.. note:: We use ``not na(pH)`` to detect a new pivot, rather than the more common way of simply relying on the fact that pH will be different from zero or na—so true—when a pivot is found. While the common technique will work most of the time, it will not work when a pivot is found at a value of zero, because zero is evaluated as false in a conditional expression. Our method is thus more robust, and the recommended way to test for a pivot.



How can I access normal bar OHLC values on a non-standard chart?
----------------------------------------------------------------

You need to use the `request.security() <https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security>`__ function. 
This script allows you to view normal candles on the chart, although depending on the non-standard chart type you use, this may or may not make much sense:

::

    //@version=5
    indicator("Plot underlying OHLC", "", true)

    // ————— Allow plotting of underlying candles on chart.
    plotCandles = input(true, "Plot Candles")
    method = input.int(1, "Using Method", minval = 1, maxval = 2)

    // ————— Method 1: Only works when chart is on default exchange for the symbol.
    o1 = request.security(syminfo.ticker, timeframe.period, open)
    h1 = request.security(syminfo.ticker, timeframe.period, high)
    l1 = request.security(syminfo.ticker, timeframe.period, low)
    c1 = request.security(syminfo.ticker, timeframe.period, close)
    // ————— Method 2: Works all the time because it use the chart"s symbol and exchange information.
    ticker = ticker.new(syminfo.prefix, syminfo.ticker)
    o2 = request.security(ticker, timeframe.period, open)
    h2 = request.security(ticker, timeframe.period, high)
    l2 = request.security(ticker, timeframe.period, low)
    c2 = request.security(ticker, timeframe.period, close)
    // ————— Get value corresponding to selected method.
    o = method == 1 ? o1 : o2
    h = method == 1 ? h1 : h2
    l = method == 1 ? l1 : l2
    c = method == 1 ? c1 : c2

    // ————— Plot underlying close.
    plot(c, "Underlying close", color = color.new(color.gray, 0), linewidth = 3, trackprice = true)
    // ————— Plot candles if required.
    invisibleColor = color.new(color.white, 100)
    plotcandle(plotCandles ? o : na, plotCandles ? h : na, plotCandles ? l : na, plotCandles ? c : na, color = color.orange, wickcolor = color.orange)

    var table tbl = table.new(position.top_right, 1, 1)

    if barstate.isfirst
        table.cell(tbl, 0, 0, "", bgcolor = color.yellow)
    else if barstate.islast
        string txt = str.format("Underlying Close1 = {0, number, #.##}\nUnderlying Close2 = {1, number, #.##} \n{2} close = {3, number, #.##}\n Delta = {4, number, #.##}"
        , c1, c2, "Chart\'s", close, close - c)
        table.cell_set_text(tbl, 0, 0, txt)



How can I initialize a series on specific dates using external data?
--------------------------------------------------------------------



How can I display plot values in the chart’s scale?
---------------------------------------------------



How can I reset a sum on a condition?
-------------------------------------

We first need a variable whose value is preserved bar to bar, so we will use the `var <https://www.tradingview.com/pine-script-reference/v5/#op_var>`__ keyword to 
initialize our ``vol`` variable on the first bar only. We then need to define the resetting condition, in this case a MACD cross. 
We then add the `volume <https://www.tradingview.com/pine-script-reference/v5/#var_volume>`__ to our ``vol`` variable on each bar, except when a cross occurs, 
in which case we reset our sum to zero. We also plot a dot on crosses for debugging purposes:

::

    //@version=5
    indicator("Reset sum on condition example")
    [macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
    var float vol = na
    bool cond = ta.cross(macdLine, signalLine)
    vol := cond ? 0. : vol + volume
    plot(vol)
    plotchar(cond, "cond", "•", location.top, size = size.tiny)

.. note:: We do not use the third tuple value in the `ta.macd() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}macd>`__ call, so we replace it with an underscore.



How can I accumulate a value for two exclusive states?
------------------------------------------------------



How can I organize my script’s inputs in the Settings/Inputs tab?
-----------------------------------------------------------------



How can I find the nth highest/lowest value in the last bars?
-------------------------------------------------------------



How can I calculate the all-time high and all-time low?
-------------------------------------------------------

Use the `ta.max() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}max>`__ and the 
`ta.min() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}min>`__ functions. These functions will return the all-time high and low for the given data source.

::

    //@version=5
    indicator("All-time high and low example")
    ath = ta.max(high)
    atl = ta.min(low)
    plot(ath, color = color.green)
    plot(atl, color = color.red)




.. image:: /images/TradingView-Logo-Block.svg
    :width: 200px
    :align: center
    :target: https://www.tradingview.com/