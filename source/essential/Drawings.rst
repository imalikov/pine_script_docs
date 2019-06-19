Drawings
========

.. contents:: :local:
    :depth: 2

Since Pine version 4, it is possible to write indicators and strategies that
create *drawing objects* on chart. At the moment two kinds of 
drawings are supported - *label* and *line*:

.. image:: images/label_and_line_drawings.png

.. note:: There is a whole set of *Drawing Tools*
  on the chart which are created and modified manually by user's mouse actions. Though they look very similar to
  Pine drawing objects they are essentially different entities. 
  Drawing objects created from Pine code cannot be modified by mouse actions.

Lines and labels allow you to create more sophisticated indicators like pivot point support/resistance levels,
zig zag, various labels with dynamic text info, etc.

In contrast to indicator plots (plots are created with functions ``plot``, ``plotshape``, ``plotchar``), 
drawing objects could be created on historical or future bars (if there are no bars yet).

Creating drawings
-----------------

Drawing objects in Pine are created with functions `label.new <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}new>`__ 
and `line.new <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}new>`__. 
Each function has a number of various parameters, but only the coordinates are mandatory.
For example, a minimum code, that creates a label on every bar::
    
    //@version=4
    study("My Script", overlay=true)
    label.new(bar_index, high)

.. image:: images/minimal_label.png

Label is created with ``x=bar_index`` parameters (index of current bar, 
`bar_index <https://www.tradingview.com/study-script-reference/v4/#var_bar_index>`__) and ``y=high`` (current high).
When a new bar opens, a new label is created on it. Label object, created on the previous closed bar stays on the chart, 
until indicator deletes it with an explicit call of `label.delete <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}delete>`__ 
function or it would be automatically collected as an old garbage object after a while.

Here is a modified version of the same script that shows values of ``x`` and ``y`` coordinates of created labels::

    //@version=4
    study("My Script", overlay=true)
    label.new(bar_index, high, style=label.style_none, 
              text="x=" + tostring(bar_index) + "\ny=" + tostring(high))

.. image:: images/minimal_label_with_x_y_coordinates.png

In this example labels are shown without a background coloring (because of parameter ``style=label.style_none``) but with a 
dynamically created text (``text="x=" + tostring(bar_index) + "\ny=" + tostring(high)``) that prints actual values of label coordinates.

Finally, here is a minimum code, that creates line objects on the chart::

    //@version=4
    study("My Script", overlay=true)
    line.new(x1=bar_index[1], y1=low[1], x2=bar_index, y2=high)

.. image:: images/minimal_line.png


Calculation of drawings on bar updates
--------------------------------------

Drawing objects are subject to both *commit* and *rollback* actions as well as any other Pine variables, :doc:`/language/Execution_model`.

Here is an example:

    //@version=4
    study("My Script", overlay=true)
    label.new(bar_index, high)

Drawings that were created based on previous updates are going to be deleted automatically. Once the script has been calculated on a closing bar update a label object is finally commited and stays on the chart.

.. _drawings_coordinates:

Coordinates
-----------

Drawing objects are positioned on the chart according to the *x* and *y* coordinates. Meaning (and the resulting effect) could be different, depending on
values of drawing properties *x-location* and *y-location*. Plus there are minor nuances for label and line.

If drawing object uses `xloc.bar_index <https://www.tradingview.com/study-script-reference/v4/#var_xloc{dot}bar_index>`__, then
x-coordinate is treated as an absolute bar index. Bar index of the current bar could be obtained from built-in variable ``bar_index``. 
Bar index of the previous bars are ``bar_index[1]``, ``bar_index[2]`` and so on. ``xloc.bar_index`` is the default value for x-location parameters
of both label and line drawings.

If drawing object uses `xloc.bar_time <https://www.tradingview.com/study-script-reference/v4/#var_xloc{dot}bar_time>`__, then
x-coordinate is treated as UNIX time in milliseconds. Start time of the current bar could be obtained from built-in variable ``time``.
Bar time of the previous bars are ``time[1]``, ``time[2]`` and so on. Time could be set as an absolute time point with the help of 
function `timestamp <https://www.tradingview.com/study-script-reference/v4/#fun_timestamp>`__.

``xloc.bar_time`` mode gives an ability to place a drawing object in the future, in front of the current bar. For example::

    //@version=4
    study("My Script", overlay=true)
    dt = time - time[1]
    if barstate.islast
        label.new(time + 3*dt, close, xloc=xloc.bar_time)

.. image:: images/label_in_the_future.png

This code places a label object in the future. X-location logic works identically for both label and line drawings.

In contrast, y-location logic is different for label and line drawings.
For *line* drawings there is only one option here, they use `yloc.price <https://www.tradingview.com/study-script-reference/v4/#var_yloc{dot}price>`__.
It means, that y-coordinate is treated as an absolute price value.

Label drawing has additional y-location values: `yloc.abovebar <https://www.tradingview.com/study-script-reference/v4/#var_yloc{dot}abovebar>`__ and
`yloc.belowbar <https://www.tradingview.com/study-script-reference/v4/#var_yloc{dot}belowbar>`__.
In this case, value of ``y`` parameter is ignored, because drawing object is placed on chart near the corresponding bar, above or below it.


Changing drawings
-----------------

Once a drawing object is created, it could be changed later. Functions ``label.new`` and ``line.new`` return 
a reference to the created drawing object (of type *series label* and *series line* respectively).
This reference then could be used as the first argument to functions ``label.set_*`` and ``line.set_*`` to modify the drawing. 
For example::

    //@version=4
    study("My Script", overlay=true)
    l = label.new(bar_index, na)
    if close >= open
        label.set_text(l, "green")
        label.set_color(l, color.green)
        label.set_yloc(l, yloc.belowbar)
        label.set_style(l, label.style_labelup)
    else
        label.set_text(l, "red")
        label.set_color(l, color.red)
        label.set_yloc(l, yloc.abovebar)
        label.set_style(l, label.style_labeldown)

.. image:: images/label_changing_example.png

This simple script creates a label on the current bar first and then it writes a reference to it in a variable ``l``. 
Then, depending on whether current bar is a rising or a falling bar (condition ``close >= open``), a number of label drawing properties are modified:
text, color, *y* coordinate location (``yloc``) and label style.

One may notice that ``na`` is passed as ``y`` argument to the ``label.new`` function call. The reason for this is that
label use either ``yloc.belowbar`` or ``yloc.abovebar`` y-locations. It means that label is bounded to the bar position on the chart. 
A finite value for ``y`` is needed only if label uses ``yloc.price`` as y-location value.

List of available *setter* functions for label drawing:

    * `label.set_color <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_color>`__ --- changes color of label
    * `label.set_size <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_size>`__ --- changes size of label
    * `label.set_style <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_style>`__ --- changes :ref:`style of label <drawings_label_styles>`
    * `label.set_text <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_text>`__ --- changes text of label
    * `label.set_textcolor <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_textcolor>`__ --- changes color of label text
    * `label.set_x <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_x>`__ --- changes x-coordinate of label
    * `label.set_y <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_y>`__ --- changes y-coordinate of label
    * `label.set_xy <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_xy>`__ --- changes both x and y coordinates of label at once
    * `label.set_xloc <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_xloc>`__ --- changes x-location of label
    * `label.set_yloc <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_yloc>`__ --- changes y-location of label

List of available *setter* functions for line drawing:

    * `line.set_color <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_color>`__ --- changes color of line
    * `line.set_extend <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_extend>`__ --- changes attribute that makes 
      
      - ``extend.none`` - a line segment
      - ``extend.left``/``extend.right`` - a ray
      - ``extend.both`` - an endless line

    * `line.set_style <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_style>`__ --- changes :ref:`style of line <drawings_line_styles>`
    * `line.set_width <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_width>`__ --- changes width of line
    * `line.set_xloc <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_xloc>`__ --- changes x-location of line both x1 and x2 coordinates
    * `line.set_x1 <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_x1>`__ --- changes x1-coordinate of line
    * `line.set_y1 <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_y1>`__ --- changes y1-coordinate of line
    * `line.set_xy1 <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_xy1>`__ --- changes both x1 and y1 coordinates of line at once
    * `line.set_x2 <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_x2>`__ --- changes x2-coordinate of line
    * `line.set_y2 <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_y2>`__ --- changes y2-coordinate of line
    * `line.set_xy2 <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_xy2>`__ --- changes both x2 and y2 coordinates of line at once


.. _drawings_label_styles:

Label styles
------------

Pine labels support a number of various styles. Style could be set either with
`label.new <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}new>`__ or 
`label.set_style <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}set_style>`__ 
function:

+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| Label style name               | Label                                           | Label with text                                 |
+================================+=================================================+=================================================+
| ``label.style_none``           |                                                 | |label_style_none_t|                            |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_xcross``         | |label_style_xcross|                            | |label_style_xcross_t|                          |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_cross``          | |label_style_cross|                             | |label_style_cross_t|                           |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_triangleup``     | |label_style_triangleup|                        | |label_style_triangleup_t|                      |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_triangledown``   | |label_style_triangledown|                      | |label_style_triangledown_t|                    |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_flag``           | |label_style_flag|                              | |label_style_flag_t|                            |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_circle``         | |label_style_circle|                            | |label_style_circle_t|                          |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_arrowup``        | |label_style_arrowup|                           | |label_style_arrowup_t|                         |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_arrowdown``      | |label_style_arrowdown|                         | |label_style_arrowdown_t|                       |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_labelup``        | |label_style_labelup|                           | |label_style_labelup_t|                         |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_labeldown``      | |label_style_labeldown|                         | |label_style_labeldown_t|                       |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_square``         | |label_style_square|                            | |label_style_square_t|                          |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+
| ``label.style_diamond``        | |label_style_diamond|                           | |label_style_diamond_t|                         |
+--------------------------------+-------------------------------------------------+-------------------------------------------------+

.. |label_style_xcross| image:: images/label.style_xcross.png
.. |label_style_cross| image:: images/label.style_cross.png
.. |label_style_triangleup| image:: images/label.style_triangleup.png
.. |label_style_triangledown| image:: images/label.style_triangledown.png
.. |label_style_flag| image:: images/label.style_flag.png
.. |label_style_circle| image:: images/label.style_circle.png
.. |label_style_arrowup| image:: images/label.style_arrowup.png
.. |label_style_arrowdown| image:: images/label.style_arrowdown.png
.. |label_style_labelup| image:: images/label.style_labelup.png
.. |label_style_labeldown| image:: images/label.style_labeldown.png
.. |label_style_square| image:: images/label.style_square.png
.. |label_style_diamond| image:: images/label.style_diamond.png

.. |label_style_none_t| image:: images/label.style_none_t.png
.. |label_style_xcross_t| image:: images/label.style_xcross_t.png
.. |label_style_cross_t| image:: images/label.style_cross_t.png
.. |label_style_triangleup_t| image:: images/label.style_triangleup_t.png
.. |label_style_triangledown_t| image:: images/label.style_triangledown_t.png
.. |label_style_flag_t| image:: images/label.style_flag_t.png
.. |label_style_circle_t| image:: images/label.style_circle_t.png
.. |label_style_arrowup_t| image:: images/label.style_arrowup_t.png
.. |label_style_arrowdown_t| image:: images/label.style_arrowdown_t.png
.. |label_style_labelup_t| image:: images/label.style_labelup_t.png
.. |label_style_labeldown_t| image:: images/label.style_labeldown_t.png
.. |label_style_square_t| image:: images/label.style_square_t.png
.. |label_style_diamond_t| image:: images/label.style_diamond_t.png


.. _drawings_line_styles:

Line styles
-----------

Pine lines support a number of various styles. Style could be set either with
`line.new <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}new>`__ or 
`line.set_style <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}set_style>`__ 
function:

+--------------------------------+-------------------------------------------------+
| Line style name                | Line                                            |
+================================+=================================================+
| ``line.style_solid``           | |line_style_solid|                              |
+--------------------------------+-------------------------------------------------+
| ``line.style_dotted``          | |line_style_dotted|                             |
+--------------------------------+-------------------------------------------------+
| ``line.style_dashed``          | |line_style_dashed|                             |
+--------------------------------+-------------------------------------------------+
| ``line.style_arrow_left``      | |line_style_arrow_left|                         |
+--------------------------------+-------------------------------------------------+
| ``line.style_arrow_right``     | |line_style_arrow_right|                        |
+--------------------------------+-------------------------------------------------+
| ``line.style_arrow_both``      | |line_style_arrow_both|                         |
+--------------------------------+-------------------------------------------------+


.. |line_style_solid| image:: images/line.style_solid.png
.. |line_style_dotted| image:: images/line.style_dotted.png
.. |line_style_dashed| image:: images/line.style_dashed.png
.. |line_style_arrow_left| image:: images/line.style_arrow_left.png
.. |line_style_arrow_right| image:: images/line.style_arrow_right.png
.. |line_style_arrow_both| image:: images/line.style_arrow_both.png


Deleting drawings
-----------------

Functions `label.delete <https://www.tradingview.com/study-script-reference/v4/#fun_label{dot}delete>`__ 
and `line.delete <https://www.tradingview.com/study-script-reference/v4/#fun_line{dot}delete>`__ 
delete *label* and *line* drawing objects on chart correspondingly. 

As an example, here is a Pine code that keeps just one label drawing object on the current bar,
*deleting the old ones*::

    //@version=4
    study("Last Bar Close 1", overlay=true)

    c = close >= open ? color.lime : color.red
    l = label.new(bar_index, na, 
      text=tostring(close), color=c, 
      style=label.style_labeldown, yloc=yloc.abovebar)

    label.delete(l[1])

.. image:: images/Last_Bar_Close_1.png

In "Last Bar Close 1" study, on every new bar update a new label object is created and written to variable ``l``.
Variable ``l`` has type *series label*, so operator ``[]`` is used to get label object on the previous bar. 
That old label then is passed to ``label.delete`` function to delete it.

Functions ``label.delete`` and ``line.delete`` do nothing if ``na`` object is passed to them. Here is why::

    if not na(l[1])
        label.delete(l[1])

Such "protection" (the ``if`` statement) is not necessary.

Exactly the same behaviour could be achieved with another approach. An old label could be deleted and then a new one created using just one 
reference ``l`` on the same current bar::

    //@version=4
    study("Last Bar Close 2", overlay=true)

    var label l = na
    label.delete(l)
    c = close >= open ? color.lime : color.red
    l := label.new(bar_index, na, 
      text=tostring(close), color=c,
      style=label.style_labeldown, yloc=yloc.abovebar)

In more detail, when study "Last Bar Close 2" gets a new bar update, variable ``l`` is still referencing to the old label object, created on the previous bar.
So, it is deleted with call ``label.delete(l)`` and then a new label is created and written to ``l``. That is why in this approach there is 
no need to use operator ``[]``.

Note the use of new (since Pine v4) :ref:`var keyword <variable_declaration>`. It creates variable ``l`` and initializes it with ``na`` value just once. 
Without this detail, ``label.delete(l)`` call would not delete any objects.

By the way, there is one more approach without objects deletions. A drawing object may be created just once and then
on every bar update it is moved forward along with the current bar::

    //@version=4
    study("Last Bar Close 3", overlay=true)

    var label l = label.new(bar_index, na,
      style=label.style_labeldown, yloc=yloc.abovebar)

    c = close >= open ? color.lime : color.red
    label.set_color(l, c)
    label.set_text(l, tostring(close))
    label.set_x(l, bar_index)

Once again, the use of new :ref:`var keyword <variable_declaration>` is essential. Call ``label.new`` is executed only once on the very first 
history bar.


Examples of classic indicators
------------------------------

Pivot points standard
^^^^^^^^^^^^^^^^^^^^^

.. image:: images/drawings_pivot_points_std.png

::

    //@version=4
    study("Pivot Points Standard", overlay=true)
    higherTF = input("D", type=input.resolution)
    prevCloseHTF = security(syminfo.tickerid, higherTF, close[1], lookahead=true)
    prevOpenHTF = security(syminfo.tickerid, higherTF, open[1], lookahead=true)
    prevHighHTF = security(syminfo.tickerid, higherTF, high[1], lookahead=true)
    prevLowHTF = security(syminfo.tickerid, higherTF, low[1], lookahead=true)

    pLevel = (prevHighHTF + prevLowHTF + prevCloseHTF) / 3
    r1Level = pLevel * 2 - prevLowHTF
    s1Level = pLevel * 2 - prevHighHTF

    var line r1Line = na
    var line pLine = na
    var line s1Line = na

    if pLevel[1] != pLevel
        line.set_x2(r1Line, bar_index)
        line.set_x2(pLine, bar_index)
        line.set_x2(s1Line, bar_index)
        line.set_extend(r1Line, extend.none)
        line.set_extend(pLine, extend.none)
        line.set_extend(s1Line, extend.none)
        r1Line := line.new(bar_index, r1Level, bar_index, r1Level, extend=extend.right)
        pLine := line.new(bar_index, pLevel, bar_index, pLevel, width=3, extend=extend.right)
        s1Line := line.new(bar_index, s1Level, bar_index, s1Level, extend=extend.right)
        label.new(bar_index, r1Level, "R1", style=label.style_none)
        label.new(bar_index, pLevel, "P", style=label.style_none)
        label.new(bar_index, s1Level, "S1", style=label.style_none)
        
    if not na(pLine) and line.get_x2(pLine) != bar_index
        line.set_x2(r1Line, bar_index)
        line.set_x2(pLine, bar_index)
        line.set_x2(s1Line, bar_index)




Pivot points high/low
^^^^^^^^^^^^^^^^^^^^^

.. image:: images/drawings_pivot_points_hl.png

::

    //@version=4
    study('Pivots HL', overlay=true)

    lenH = input(title='Length High', type=input.integer, defval=10, minval=1)
    lenL = input(title='Length Low', type=input.integer, defval=10, minval=1)

    fun(src, len, isHigh, _style, _yloc, _color) => 
        p = nz(src[len])
        isFound = true
        for i = 0 to len * 2
            if isHigh and src[i] > p
                isFound := false
            
            if not isHigh and src[i] < p
                isFound := false
        
        if isFound
            label.new(bar_index[len], p, tostring(p), style=_style, yloc=_yloc, color=_color)

    fun(high, lenH, true, label.style_labeldown, yloc.abovebar, color.lime)
    fun(low, lenL, false, label.style_labelup, yloc.belowbar, color.red)


Linear Regression
^^^^^^^^^^^^^^^^^

.. image:: images/drawings_linear_regression.png

::

    //@version=4
    study("Linear Regression", overlay=true)
    src = input(close)
    len = input(50)

    calcSlope(src, len0) =>
        if not barstate.islast
            [float(na), float(na), float(na)]
        else
            sumX = 0.0
            sumY = 0.0
            sumXSqr = 0.0
            sumXY = 0.0
            for i = 0 to len - 1
                val = src[i]
                per = i + 1.0
                sumX := sumX + per
                sumY := sumY + val
                sumXSqr := sumXSqr + per * per
                sumXY := sumXY + val * per
            slope = (len * sumXY - sumX * sumY) / (len * sumXSqr - sumX * sumX)
            average = sumY / len
            intercept = average - slope * sumX / len + slope
            [slope, average, intercept]

    [s, a, i] = calcSlope(src, len)

    startPrice = i + s * (len - 1)
    endPrice = i
    var line baseLine = na
    if na(baseLine)
        baseLine := line.new(bar_index - len + 1, startPrice, bar_index, endPrice, width=4, extend=extend.right)
    else
        line.set_xy1(baseLine, bar_index - len + 1, startPrice)
        line.set_xy2(baseLine, bar_index, endPrice)
        na // To match the 'then' block type
        

Zig Zag
^^^^^^^

.. image:: images/drawings_zig_zag.png

:: 

    //@version=4
    study('Zig Zag', overlay=true)

    dev_threshold = input(title='Deviation', type=input.float, defval=5, minval=0)
    depth = input(title='Depth', type=input.integer, defval=10, minval=1)

    pivots(src, length, isHigh) => 
        l2 = length * 2 
        c = nz(src[length])
        ok = true
        for i = 0 to l2
            if isHigh and src[i] > c
                ok := false
            
            if not isHigh and src[i] < c
                ok := false
        if ok
            [bar_index[length], c]
        else
            [int(na), float(na)]

    [iH, pH] = pivots(high, depth / 2, true)
    [iL, pL] = pivots(low, depth / 2, false)

    calc_dev(base_price, price) =>
        100 * (price - base_price) / base_price

    var line lineLast = na
    var int iLast = 0
    var float pLast = 0
    var isHighLast = false // otherwise the last pivot is a low pivot

    pivotFound(dev, isHigh, index, price) => 
        if isHighLast == isHigh and not na(lineLast)
            // same direction
            if isHighLast ? price > pLast : price < pLast
                line.set_xy2(lineLast, index, price)
                [lineLast, isHighLast]
            else
                [line(na), bool(na)]
        else // reverse the direction (or create the very first line)
            if abs(dev) > dev_threshold
                // price move is significant
                id = line.new(iLast, pLast, index, price, color=color.red, width=2)
                [id, isHigh]
            else
                [line(na), bool(na)]
            
    if not na(iH)
        dev = calc_dev(pLast, pH)
        [id, isHigh] = pivotFound(dev, true, iH, pH)
        if not na(id)
            lineLast := id
            isHighLast := isHigh
            iLast := iH
            pLast := pH
    else
        if not na(iL)
            dev = calc_dev(pLast, pL)
            [id, isHigh] = pivotFound(dev, false, iL, pL)
            if not na(id)
                lineLast := id
                isHighLast := isHigh
                iLast := iL
                pLast := pL


Issues
------

Total number of drawings limit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Pine code that operates with drawing objects consume server resources. That is why there is a limitation of total number of drawings 
per study or strategy. If Pine code creates too many drawings, the old ones are automatically deleted by the Pine runtime.

For example, here is a code that creates a drawing on every bar::

    //@version=4
    study("My Script", overlay=true)
    label.new(bar_index, high)

Scrolling the chart back will demonstrate that drawings were removed:

.. image:: images/drawings_total_number_limit.png


Additional securities
^^^^^^^^^^^^^^^^^^^^^

Pine code may use additional symbols and/or timeframes with the :doc:`security <Context_switching_the_security_function>` function. 
But all the drawing functions are allowed to be called only on the main symbol context. Anyway, secondary symbols are not displayed on the
chart, so this limitation is quite standard.


max_bars_back of time
^^^^^^^^^^^^^^^^^^^^^

Usage of ``barstate.isrealtime`` in combination with drawings could sometimes lead to not so obvious behaviour of Pine code.
For example, there is a code that is supposed to create label drawings on the *realtime* bars, skipping
all the historical bars::

    //@version=4
    study("My Script", overlay=true)

    if barstate.isrealtime
        label.new(bar_index[10], na, text="Label", yloc=yloc.abovebar)

This study doesn't add anything on the chart at all. In fact, it fails in runtime with an error. 
The reason for the error is that Pine could not determine the buffer size for historical values of ``time`` plot, but...
``time`` built-in variable even was not mentioned in the Pine code!

Firstly, a built-in ``label.new``function on the back end works with ``time`` series. To get the time value that was recorded 10 bars ago this data must be stored in a buffer. 

Secondly, in Pine there is a mechanism that automaticaly detects historical buffer sizes in most of the cases.
Autodetection works like this. For a limited number of bars study is allowed to access historical values any bars back from the current bar.
Thus the system knows what historical buffer size a series or a variable needs. Condition `if barstate.isrealtime` makes the line with
``bar_index[10]`` to be skipped for all historical bars, so the system does not know anything about the ``time`` (but remembers ``bar_index`` variable)
historical buffer size needed. That is why the code fails.

Solution for this is to use `max_bars_back <https://www.tradingview.com/pine-script-reference/v4/#fun_max_bars_back>`__ function to explicitly set the historical buffer size for ``time`` series::

    //@version=4
    study("My Script", overlay=true)

    max_bars_back(time, 10)

    if barstate.isrealtime
        label.new(bar_index[10], na, text="Label", yloc=yloc.abovebar)

This case is rare and very confusing. Pine team knows about it and works hard to make things simpler and clearer.

