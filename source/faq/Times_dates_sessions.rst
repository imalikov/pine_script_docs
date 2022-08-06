.. image:: /images/Pine_Script_logo.svg
   :alt: Pine Script™ logo
   :target: https://www.tradingview.com/pine-script-docs/en/v5/Introduction.html
   :align: right
   :width: 100
   :height: 100


.. _PageTimesDatesSessionsFaq:


Times, dates and sessions FAQ
=============================


.. contents:: :local:
    :depth: 3



How can I get the time of the first bar in the dataset?
-------------------------------------------------------

The following code will save the time of the dataset’s first bar. 
When we declare a variable using the `var <https://www.tradingview.com/pine-script-reference/v5/#op_var>`__ keyword, it is only initialized on the first bar. 
We use that here to save the value of ``time``, which returns the `time <https://www.tradingview.com/pine-script-reference/v5/#var_time>`__ in Unix format, i.e., 
the number of milliseconds that have elapsed since 00:00:00 UTC, 1 January 1970:

::

    //@version=5
    indicator('Time at first bar')

    // Get time at beginning of the dataset.
    var t = time
    plot(t)



How can I convert a time to a date-time string?
-----------------------------------------------

Use our ``timeToString()`` function, which accepts any ``timestamp`` in Unix format and returns the corresponding date-time in string format. 
This code shows four different ways of using it to get the date-time from various starting points and using a 4-day offset in the future for the last two uses demonstrated:

::

    //@version=5
    indicator("Time to string example")

    // Get the time at the beginning of the dataset.
    var t = time

    timeToString(t) =>
        //str.format("{0, number, ####}.{1, number, ##}.{2, number, ##} {3, number, ##}:{4, number, ##}:{5, number, ##}", year(t), month(t), dayofmonth(t), hour(t), minute(t), second(t))
        str.tostring(year(t), "0000") + "." + str.tostring(month(t), "00") + "." + str.tostring(dayofmonth(t), "00") + " " + str.tostring(hour(t), "00") + ":" + str.tostring(minute(t), "00") + ":" + str.tostring(second(t), "00")

    print(txt) =>
        var label lbl = label.new(bar_index, ta.highest(10)[1], txt, xloc.bar_index, yloc.price, #00000000, label.style_none, color.gray, size.large, text.align_center)
        label.set_xy(lbl, bar_index, ta.highest(10)[1])
        label.set_text(lbl, txt)

    print(str.format("Date-time at bar_index = 0: {0}\n\n\n\n\n\n", timeToString(t)))
    print(str.format("Current Date-time: {0}\n\n\n\n", timeToString(timenow)))
    print(str.format("Date-time 4 days from current time: {0}\n\n\n", timeToString(timestamp(year(timenow), month(timenow), dayofmonth(timenow) + 4, hour(timenow), minute(timenow), second(timenow)))))
    print(str.format("Date-time at beginning of last bar: {0}\n", timeToString(time)))
    print(str.format("Date-time at the start of the day, 4 days past the last bar\'s time: {0}", timeToString(timestamp(year, month, dayofmonth + 4, 00, 00, 00))))



How can I know how many days are in the current month?
------------------------------------------------------

Use `this function <https://www.tradingview.com/script/mHHDfDB8-RS-Function-Days-in-a-Month/>`__ by RicardoSantos.



How can I detect the chart’s last day?
--------------------------------------

To do this, we will use the `request.security() <https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security>`__ function called at the ``1D`` resolution 
and have it evaluate the `barstate.islast <https://www.tradingview.com/pine-script-reference/v5/#var_barstate{dot}islast>`__ variable on that time frame, 
which returns `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__ when the bar is the last one in the dataset, even if it is not a realtime bar 
if the market is closed. We also allow the `request.security() <https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security>`__ function to ``lookahead``, 
otherwise it will only return `true <https://www.tradingview.com/pine-script-reference/v5/#op_true>`__ on the last bar of the chart’s resolution.

::

    //@version=5
    indicator("Last day example")
    lastDay = request.security(syminfo.tickerid, "1D", barstate.islast, lookahead = barmerge.lookahead_on)
    bgcolor(lastDay ? color.new(color.red, 90) : na)



How can I detect if a bar’s date is today?
------------------------------------------

::

    //@version=5
    //@author=mortdiggiddy, for PineCoders
    indicator("Detect today", "", true)
    isToday() =>
        currentYear = year(timenow)
        currentMonth = month(timenow)
        currentDay = dayofmonth(timenow)
        result = year == currentYear and month == currentMonth and dayofmonth == currentDay
    bgcolor(isToday() ? color.new(color.gray, 90) : na)



How can I plot a value starting X months/years back?
----------------------------------------------------

The `timestamp() <https://www.tradingview.com/pine-script-reference/v5/#fun_timestamp>`__ function allows the use of negative argument values and will convert them 
into the proper date. Using a negative month value, for example, will subtract the proper number of months from the result. 
We use this feature here to allow us to look back on an arbitrary number of months or years. 
A choice is given to identify the first of the target month, or go back from the current date and time.

::

    //@version=5
    indicator("Plot value starting n months/years back", "", true)
    int monthsBack = input.int(3, minval = 0)
    int yearsBack = input.int(0, minval = 0)
    bool fromCurrentDateTime = input(false, "Calculate from current Date/Time instead of first of the month")

    bool isTargetDate = time >= timestamp(year(timenow) - yearsBack, month(timenow) - monthsBack, fromCurrentDateTime ? dayofmonth(timenow) : 1, 
    fromCurrentDateTime ? hour(timenow) : 0, fromCurrentDateTime ? minute(timenow) : 0, fromCurrentDateTime ? second(timenow) : 0)
    bool isBeginMonth = not isTargetDate[1] and isTargetDate

    var float valueToPlot = na
    if isBeginMonth
        valueToPlot := high
    plot(valueToPlot)
    bgcolor(isBeginMonth ? color.new(color.green, 90) : na)



How can I track highs/lows for a specific timeframe?
----------------------------------------------------

This code shows how to do that without using `request.security() <https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security>`__ calls, 
which slow down your script. The source used to calculate the highs/lows can be selected in the script’s ``Inputs``, as well as the period after which the high/low must be reset.

::

    //@version=5
    //@author=LucF, for PineCoders
    indicator("Periodic hi/lo example", "", true)
    bool showHi = input.bool(true, "Show highs")
    bool showLo = input.bool(true, "Show lows")
    float srcHi = input.source(high, "Source for Highs")
    float srcLo = input.source(low, "Source for Lows")
    string period = input.timeframe("1D", "Period after which hi/lo is reset")

    var hi = 10e-10
    var lo = 10e10
    // When a new period begins, reset hi/lo.
    hi := ta.change(time(period)) ? srcHi : math.max(srcHi, hi)
    lo := ta.change(time(period)) ? srcLo : math.min(srcLo, lo)

    plot(showHi ? hi : na, "Highs", color.new(color.blue, 0), 3, plot.style_circles)
    plot(showLo ? lo : na, "Lows", color.new(color.fuchsia, 0), 3, plot.style_circles)



How can I track highs/lows for a specific period of time?
---------------------------------------------------------



How can I track highs/lows between specific intrabar hours?
-----------------------------------------------------------



How can I detect a specific date/time?
--------------------------------------



How can I know the date when a highest value was found?
-------------------------------------------------------



How can I detect bars opening at a specific hour?
-------------------------------------------------



Can I time the duration of a condition?
---------------------------------------



How can I identify the nth occurrence of a weekday in the month?
----------------------------------------------------------------



How can I implement a countdown timer?
--------------------------------------



How can I get the week of the month?
------------------------------------




.. image:: /images/TradingView-Logo-Block.svg
    :width: 200px
    :align: center
    :target: https://www.tradingview.com/