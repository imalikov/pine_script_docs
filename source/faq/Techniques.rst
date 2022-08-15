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



How can I update all x2/right side of all lines/boxes in an array.new_line() / array.new_box()?
-----------------------------------------------------------------------------------------------



How to avoid repainting when using the request.security() function?
-----------------------------------------------------------



How to avoid repainting when NOT using the request.security() function?
---------------------------------------------------------------



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



How can I optimize Pine code?
-----------------------------



How can I access financials information on stocks from Pine?
------------------------------------------------------------



How can I save a value from a signal when a pivot occurs?
---------------------------------------------------------



How can I find the maximum value among the last pivots?
-------------------------------------------------------



How can I access normal bar OHLC values on a non-standard chart?
----------------------------------------------------------------



How can I initialize a series on specific dates using external data?
--------------------------------------------------------------------



How can I display plot values in the chart’s scale?
---------------------------------------------------



How can I reset a sum on a condition?
-------------------------------------



How can I cumulate a value for two exclusive states?
----------------------------------------------------



How can I organize my script’s inputs in the Settings/Inputs tab?
-----------------------------------------------------------------



How can I find the nth highest/lowest value in the last bars?
-------------------------------------------------------------



How can I calculate the all-time high and all-time low?
-------------------------------------------------------




.. image:: /images/TradingView-Logo-Block.svg
    :width: 200px
    :align: center
    :target: https://www.tradingview.com/