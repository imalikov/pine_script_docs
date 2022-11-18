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
We use that here to save the value of ``time``, which returns the `time <https://www.tradingview.com/pine-script-reference/v5/#var_time>`__ 
in Unix format, i.e., the number of milliseconds that have elapsed since 00:00:00 UTC, 1 January 1970:

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

    // Function converts a timestamp to a formatted string.
    timeToString(t) =>
        str.format("{0, date, YYYY.MM.dd HH:mm:ss}", t)

    // Create table on the first bar only.
    var table tbl = table.new(position.middle_right, 1, 1)

    // On the first bar, build the table cell.
    if barstate.isfirst
        table.cell(tbl, 0, 0, "", bgcolor = color.yellow)
    // On the last bar, build displayed text and populate the table.
    else if barstate.islast
        string txt = 
        "Date-time at bar_index = 0: "            + timeToString(time) +
        "\nCurrent Date-time: "                   + timeToString(timenow) +
        "\nDate-time 4 days from current time: "  + timeToString(timestamp(year(timenow), month(timenow), dayofmonth(timenow) + 4, hour(timenow), minute(timenow), second(timenow))) +
        "\nDate-time at beginning of last bar: "  + timeToString(time) +
        "\nDate-time at the start of the day, 4 days past the last bar\'s time:" + timeToString(timestamp(year, month, dayofmonth + 4))
        table.cell_set_text(tbl, 0, 0, txt)



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
into the proper date. For example, a negative month value will subtract the appropriate number of months from the result. 
We use this feature here to allow us to look back on an arbitrary number of months or years. 
A choice is given to identify the first of the target month or return the result from the current date and time.

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
which slow down your script. The source used to calculate the highs/lows can be selected in the script’s ``Inputs``and the period after which the high/low must be reset.

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

We use session information in the 2-parameter version of the `time() <https://www.tradingview.com/pine-script-reference/v5/#fun_time>`__ function to test if we are 
in the user-defined hours during which we must keep track of the highs/lows. A setting allows the user to choose if they want levels to plot outside hours or not.

::

    //@version=5
    //@author=LucF, for PineCoders
    indicator("Session hi/lo", "", true)
    bool noPlotOutside = input.bool(true, "Don\'t plot outside of hours")
    bool showHi        = input.bool(true, "Show highs")
    bool showLo        = input.bool(true, "Show lows")
    float srcHi        = input.source(high, "Source for Highs")
    float srcLo        = input.source(low, "Source for Lows")
    string timeAllowed = input.session("1200-1500", "Allowed hours")

    // Check to see if we are in allowed hours using session info on all 7 days of the week.
    int timeIsAllowed = time(timeframe.period, timeAllowed + ":1234567")
    var hi = 10e-10
    var lo = 10e10
    if timeIsAllowed
        // We are entering allowed hours; reset hi/lo.
        if not timeIsAllowed[1]
            hi := srcHi
            lo := srcLo
        else
            // We are in allowed hours; track hi/lo.
            hi := math.max(srcHi, hi)
            lo := math.min(srcLo, lo)

    plot(showHi and not(noPlotOutside and not timeIsAllowed) ? hi : na, "Highs", color.new(color.blue, 0), 3, plot.style_circles)
    plot(showLo and not(noPlotOutside and not timeIsAllowed) ? lo : na, "Lows", color.new(color.fuchsia, 0), 3, plot.style_circles)



How can I track highs/lows between specific intrabar hours?
-----------------------------------------------------------

We use the intrabar inspection technique explained `here <>`__ to inspect intrabars and save the `high <https://www.tradingview.com/pine-script-reference/v5/#var_high>`__ 
or `low <https://www.tradingview.com/pine-script-reference/v5/#var_low>`__ if the intrabar is within the user-defined start and end times.

::

        //@version=5
        //@author=LucF, for PineCoders
        indicator("Pre-market high/low", "", true)
        int begHour      = input.int(7, "Beginning time (hour)")
        int begMinute    = input.int(0, "Beginning time (minute)")
        int endHour      = input.int(9, "End time (hour)")
        int endMinute    = input.int(25, "End time (minute)")

        // Lower TF we are inspecting. Cannot be in seconds and must be lower that chart"s resolution.
        string insideRes = input("5", "Intrabar resolution used")
        int startMinute  = begHour * 60 + begMinute
        int finishMinute = endHour * 60 + endMinute

        highBetweenTime(start, finish) =>
            // Returns low between specific times.
            var float result = 0.0
            var reset = true
            minuteNow = hour * 60 + minute
            if minuteNow >= start and minuteNow <= finish
                // We are inside period.
                if reset
                    // We are at first bar inside period.
                    result := high
                    reset := false
                else
                    result := math.max(result, high)
            else
                // We are past period; enable reset for when we next enter period.
                reset := true
            result

        lowBetweenTime(start, finish) =>
            // Returns low between specific times.
            var float result = 10e10
            var reset = true
            minuteNow = hour * 60 + minute
            if minuteNow >= start and minuteNow <= finish
                // We are inside period.
                if reset
                    // We are at first bar inside period.
                    result := low
                    reset := false
                else
                    result := math.min(result, low)
            else
                // We are past period; enable reset for when we next enter period.
                reset := true
            result

        highAtTime = request.security(syminfo.tickerid, insideRes, highBetweenTime(startMinute, finishMinute))
        lowAtTime = request.security(syminfo.tickerid, insideRes, lowBetweenTime(startMinute, finishMinute))
        plot(highAtTime, "High", color.new(color.green, 0))
        plot(lowAtTime, "Low", color.new(color.red, 0))



How can I detect a specific date/time?
--------------------------------------

We will be using the `year <https://www.tradingview.com/pine-script-reference/v5/#var_year>`__, `month <https://www.tradingview.com/pine-script-reference/v5/#var_month>`__, 
`dayofmonth <https://www.tradingview.com/pine-script-reference/v5/#var_dayofmonth>`__, `hour <https://www.tradingview.com/pine-script-reference/v5/#var_hour>`__, 
`minute <https://www.tradingview.com/pine-script-reference/v5/#var_minute>`__, and `second <https://www.tradingview.com/pine-script-reference/v5/#var_second>`__ 
built-in variables to achieve this here. All of these variables return their value converted to the exchange's timezone at the bar the script is running on, as it is documented 
`here <https://www.tradingview.com/pine-script-docs/en/v5/concepts/Time.html#time-built-ins>`__ in the Pine Script™ User Manual. 
So for the target date/time, you will enter in the script’s Settings/Inputs to match the date/time on the chart, 
you will need to ensure your chart’s time is set to display the exchange’s timezone, as is shown in step 1 in the chart. 
Once that is done, step 2 shows how the chart will automatically display the exchange’s timezone at the bottom.

In this chart, we have set the hour to ``12`` and the minute to ``30`` in the script’s inputs. 
The bright green bar shows when our target time is reached, and the lighter green bars show the bars where the condition we are testing is true, i.e., 
since we haven’t entered a specific date, the cycle repeats while our time threshold has been reached each day. You can test for either condition in your script. 
You can see at step 3 on the chart that the time matches ``12:30``, which would not be the case if the chart’s time had not been set to the exchange’s timezone.

Pine Script™ programmers often want to save values on the transition to the target time. 
We show how one could save the `open <https://www.tradingview.com/pine-script-reference/v5/#var_open>`__ every time the target date/time is reached. 
Note how, when plotting the saved value, we test for transitions when applying color to the plot so that we do not plot any color on transitions. 
This prevents the inelegant steps from showing on the plot:

::

    //@version=5
    indicator("Detecting a specific time (in the exchange\"s timezone)", "", true)
    int targetYear   = input.int(0, "Year (use 0 for all)", minval = 0)
    int targetMonth  = input.int(0, "Month (use 0 for all)", minval = 0, maxval = 12)
    int targetDay    = input.int(0, "Day (use 0 for all)", minval = 0, maxval = 31)
    int targetHour   = input.int(24, "Hour (use 24 for all)", minval = 0, maxval = 24)
    int targetMinute = input.int(60, "Minute (use 60 for all)", minval = 0, maxval = 60)
    int targetSecond = input.int(60, "Second (use 60 for all)", minval = 0, maxval = 60)

    // Detect target date/time or greater, until the next higher generic value (i.e., using its default value in Inputs) changes.
    bool targetReached = (targetYear == 0 or year >= targetYear) and (targetMonth == 0 or month >= targetMonth) and 
    (targetDay == 0 or dayofmonth >= targetDay) and (targetHour == 24 or hour >= targetHour) and (targetMinute == 60 or minute >= targetMinute) and 
    (targetSecond == 60 or second >= targetSecond)

    // Plot light bg whenever target date/time has been reached and next period hasn"t reset the state.
    bgcolor(targetReached ? color.new(color.green, 90) : na, title = "In allowed time")
    // Plot brighter bg the first time we reach the target date/time.
    bgcolor(not targetReached[1] and targetReached ? color.new(color.lime, 50) : na, title = "Entry into allowed time")

    // Save open at the beginning of each detection of the beginning of the date/time.
    var float savedOpen = na
    if not targetReached[1] and targetReached
        savedOpen := open
    plot(savedOpen, "Saved open", ta.change(savedOpen) ? na : color.gray, 3)

    // Plot current bar"s date/time in the Data Window.
    plotchar(year, "year", "", location.top)
    plotchar(month, "month", "", location.top)
    plotchar(dayofmonth, "dayofmonth", "", location.top)
    plotchar(hour, "hour", "", location.top)
    plotchar(minute, "minute", "", location.top)
    plotchar(second, "second", "", location.top)



How can I know the date when a highest value was found?
-------------------------------------------------------

Both `ta.highest() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}highest>`__ and 
`ta.lowest() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}lowest>`__ have a corresponding function that can be used to get the offset to the bar 
where the highest/lowest value was found. Those `ta.highestbars() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}highestbars>`__ and 
`ta.lowestbars() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}lowestbars>`__ functions return a negative offset, 
so we need to change its sign before using it as a value with the [] history-referencing operator.

Once we have the offset, we can use it with the overloaded version of the `dayofmonth() <https://www.tradingview.com/pine-script-reference/v5/#fun_dayofmonth>`__ 
built-in, which allows it to be used with a specific `time <https://www.tradingview.com/pine-script-reference/v5/#var_time>`__ at the offset returned by the 
`ta.highestbars() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}highestbars>`__ call, with its sign changed from negative to positive:

::

    //@version=5
    indicator("Day of High", "", true)
    int len      = input.int(100)
    float hi     = ta.highest(len)
    int hiOffset = -ta.highestbars(len)
    int hiDay    = dayofmonth(time[hiOffset])
    plotchar(hiDay, "hiDay", "", location.top)
    plotchar(dayofmonth, "dayofmonth", "", location.top)
    plot(hi)



How can I detect bars opening at a specific hour?
-------------------------------------------------

This code shows three methods to detect bars opening at 18h00:

::

    //@version=5
    indicator("")
    int t        = time(timeframe.period, "1800-1900:1234567")
    int tt       = timestamp(year, month, dayofmonth, 18, 00, 00)
    bool method1 = hour == 18 and minute == 00
    bool method2 = not na(t) and na(t[1])
    bool method3 = tt == time
    plotchar(method1 ? 1 : na, "method1", "•", location.absolute, size = size.tiny)
    plotchar(method2 ? 2 : na, "method2", "•", location.absolute, size = size.tiny)
    plotchar(method3 ? 3 : na, "method3", "•", location.absolute, size = size.tiny)



Can I time the duration of a condition?
---------------------------------------

This example script shows how to use our ``secondsSince(cond, resetCond)`` function to calculate how many seconds have passed since the true condition. 
Keep in mind that this is designed to work on real-time data only.

::

//@version=5
indicator("Seconds since cond example")

secondsSince(bool cond, bool resetCond = barstate.isnew) =>
    varip int timeBegin = na
    varip bool lastCond = false
    if resetCond
        timeBegin := cond ? timenow : na
    else if cond
        if not lastCond
            timeBegin := timenow
    else
        timeBegin := na
    lastCond := cond
    int result = (timenow - timeBegin) / 1000

plot(secondsSince(close < ta.sma(close, 200)))



How can I identify the nth occurrence of a weekday in the month?
----------------------------------------------------------------

This shows how to use our ``nthDayOfWeekInMonth(nth, dayNo)`` function to detect the first Monday of the month:

::

    //@version=5
    indicator("Nth occurence of a weekday example", "", true)

    // The default inputs look for the first Monday of the month.
    // Note that days must be trading days for the function to work correctly.
    int nth   = input.int(1, "nth Occurence of the day", minval = 1, maxval = 5)
    int dayNo = input.int(2, "Day number", minval = 1, maxval = 7, tooltip = "1 is Sunday")

    // ————— Function returning `true` on the `nth` occurrence of `dayNo` in the month.
    nthDayOfWeekInMonth(nth, dayNo) =>
        // int nth  : The occurrence required. Use 1 for the first occurrence.
        // int dayNo: The day of the week number (Sunday is 1, Saturday is 7). Days not found on the chart are not accounted for.
        var int occurrence = 0
        bool isNewMonth = ta.change(time("M")) > 0
        bool isNewDay = dayofweek == dayNo and dayofweek[1] != dayNo
        if isNewMonth
            if isNewDay
                occurrence := 1
            else
                occurrence := 0
        else if isNewDay
            occurrence += 1
        bool result = occurrence == nth and dayofweek == dayNo

    plotchar(nthDayOfWeekInMonth(nth, dayNo), "Day", "•", location.top, size = size.tiny)



How can I implement a countdown timer?
--------------------------------------

This code will work on intraday and ``1D`` timeframes. However, it would require more discerning logic for it to work on timeframes higher than that:

::

    //@version=5
    indicator("Countdown timer example", "", true)
    int timeLeftInBar = timeframe.isdaily and timeframe.multiplier == 1 or timeframe.isintraday ? time_close - time - (timenow - time) : 0

    // Create table on the first bar only.
    var table tbl = table.new(position.middle_right, 1, 1)

    // On the first bar, build the table cell.
    if barstate.isfirst
        table.cell(tbl, 0, 0, "", bgcolor = color.yellow)
    // On the last bar, build displayed text and populate the table.
    else if barstate.islast
        string txt  = str.format("{0, time, HH:mm:ss}", timeLeftInBar)
        table.cell_set_text(tbl, 0, 0, txt)



How can I get the week of the month?
------------------------------------

This code uses changes in the `week <https://www.tradingview.com/pine-script-reference/v5/#var_week>`__ of the 
`year <https://www.tradingview.com/pine-script-reference/v5/#var_year>`__ to determine the `week <https://www.tradingview.com/pine-script-reference/v5/#var_week>`__ of the 
`month <https://www.tradingview.com/pine-script-reference/v5/#var_month>`__:

::

    //@version=5
    //@author=Bjorgum, for PineCoders
    indicator("Week of month example")
    weekOfMonth(timestamp = time) =>
        var week = weekofyear(timestamp) % 4
        if ta.change(weekofyear(timestamp))    
            week += 1
        if ta.change(month(timestamp))
            week := 1
        int result = timeframe.ismonthly ? na : week

    plot(weekOfMonth())



.. image:: /images/TradingView-Logo-Block.svg
    :width: 200px
    :align: center
    :target: https://www.tradingview.com/