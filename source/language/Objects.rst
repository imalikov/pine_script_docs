.. image:: /images/Pine_Script_logo.svg
   :alt: Pine Script™ logo
   :target: https://www.tradingview.com/pine-script-docs/en/v5/Introduction.html
   :align: right
   :width: 100
   :height: 100


.. _PageObjects:


Objects
=======

.. contents:: :local:
    :depth: 3


Introduction
------------

Pine Script™ objects are instantiations of *user-defined types* (UDTs). 
They are the equivalent of variables containing different parts called *fields*,
each able to contain independent values that can be of different types.
They are an advanced feature of the language; 
newcomers to Pine Script™ will want to explore the basics before tackling UDTs and objects.

How to create user-defined types is explained in the :ref:`Type system <PageTypeSystem_UserDefinedTypes>` page. 
Experienced programmers can think of UDTs as method-less classes. 
They allow you to create custom types which group different values under one logical entity.
As arrays and matrices can be defined to contain objects of user-defined types,
you can add virtual dimensions to those data structures.

Like drawing objects such as labels, lines, boxes or tables, objects created from UDTs are assigned by reference,
which entails that you must use explicit syntax to copy them.



Creating objects
----------------

Before an object can be created, its type must be defined. 
The :ref:`User-defined types <PageTypeSystem_UserDefinedTypes>` section of the 
:ref:`Type system <PageTypeSystem_UserDefinedTypes>` page explains how to do so.

Let's define a ``pivotPoint`` type to hold pivot information:

::

    type pivotPoint
        int x
        float y
        string xloc = xloc.bar_time

Note that:

- We use the `type <https://www.tradingview.com/pine-script-reference/v5/#op_type>__` keyword to declare the creation of a UDT.
- We name our new UDT ``pivotPoint``.
- After the first line, we create a local block containing the type and name of each field.
- The ``x`` field will hold the x-coordinate of the pivot. 
  It is declared as an "int" because it will hold either a timestamp or a bar index, which are of "int" type.
- ``y`` is a "float" because it will hold the pivot's price.
- ``xloc`` is a field that will specify the units of ``x``:
  `xloc.bar_index <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_index>__` or
  `xloc.bar_time <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_time>`__.
  We set its default value to `xloc.bar_time <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_time>`__ 
  by using the ``=`` operator. When an object is created from that UDT, its ``xloc`` field will thus be set to that value.

Now that our ``pivotPoint`` UDT is defined, we can proceed to creating objects from it. 
We create objects by using the ``new()`` built-in method on the UDT.
To create a new ``foundPoint`` object from our ``pivotPoint`` UDT, we use:

::

    foundPoint = pivotPoint.new()

We can also specify field values for the created object using:

::

    foundPoint = pivotPoint.new(time, high)

Or the equivalent:

::

    foundPoint = pivotPoint.new(x = time, y = high)

At this point, the ``foundPoint`` object's ``x`` field will contain the value of the
`time <https://www.tradingview.com/pine-script-reference/v5/#var_time>__` built-in when it is created, 
``y`` will contain the value of `high <https://www.tradingview.com/pine-script-reference/v5/#var_na>__`
and the ``xloc`` field will contain its default value of 
`xloc.bar_time <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_time>`__
because no explicit value was defined for it when creating the object.

Object placeholders can also be created by declaring `na` object names using:

::

    pivotPoint foundPoint = na


This example displays a label where high pivots are detected. 
The pivots are detected ``legsInput`` bars after they occur, so we must plot the label in the past for it to appear on the pivot:

::

    //@version=5
    indicator("Pivot labels", overlay = true)
    int legsInput = input(10)

    // Define the `pivotPoint` UDT.
    type pivotPoint
        int x
        float y
        string xloc = xloc.bar_time

    // Detect high pivots.
    pivotHighPrice = ta.pivothigh(legsInput, legsInput)
    if not na(pivotHighPrice)
        // A new high pivot was found, display a label where it occurred `legsInput` bars back.
        foundPoint = pivotPoint.new(time[legsInput], pivotHighPrice)
        label.new(
          foundPoint.x,
          foundPoint.y,
          str.tostring(foundPoint.y, format.mintick),
          foundPoint.xloc,
          textcolor = color.white)

Note that the line:

::

    foundPoint = pivotPoint.new(time[legsInput], pivotHighPrice)

Could also be written using:

::

    pivotPoint foundPoint = na
    foundPoint := pivotPoint.new(time[legsInput], pivotHighPrice)

When objects are created using the `var <https://www.tradingview.com/pine-script-reference/v5/#op_var>__` or 
`varip <https://www.tradingview.com/pine-script-reference/v5/#op_varip>__` keywords, 
that property applies to all the object's fields:

::

    //@version=5
    indicator("")
    type barInfo
        int i = bar_index
        int t = time
        float c = close

    // Created on bar zero.
    var firstBar = barInfo.new()
    // Created on every bar.
    currentBar = barInfo.new()

    plot(firstBar.i)
    plot(currentBar.i)



Changing field values
---------------------

The value of an object's fields can be changed using the 
:ref:`:= <PageOperators_ReassignmentOperator>` reassignment operator.

This line of our previous example:

::

    foundPoint = pivotPoint.new(time[legsInput], pivotHighPrice)

Could be written using:

::

    foundPoint = pivotPoint.new()
    foundPoint.x := time[legsInput]
    foundPoint.y := pivotHighPrice

	

Collecting objects
------------------

Arrays and matrices can contain objects. To declare them, use UDT names in *type templates* which are constructed by using angle brackets.
This declares an empty array that will contain objects of the ``pivotPoint`` UDT and initializes the ``pivotHighArray`` variable with its ID:

::

    pivotHighArray = array.new<pivotPoint>()

To explicitly declare the type of a variable as an `array <https://www.tradingview.com/pine-script-reference/v5/#op_array>__` or 
a `matrix <https://www.tradingview.com/pine-script-reference/v5/#op_matrix>__` of a user-defined type, 
you can use the `array<> <https://www.tradingview.com/pine-script-reference/v5/#op_array>__` and 
`matrix<> <https://www.tradingview.com/pine-script-reference/v5/#op_matrix>__` keywords, e.g.:

::

    var array<pivotPoint> pivotHighArray = na
    pivotHighArray := array.new<pivotPoint>()

Let's use what we have learned to create a script that detects high pivot points. 
The script first collects historical pivot information in an array. 
On the last historical bar it then loops through the array, 
creating a label for each pivot and connecting the pivots with a line:

.. image:: images/Objects-CollectingObjects-1.png

::

    //@version=5
    indicator("Pivot Points High", overlay = true)

    int legsInput = input(10)

    // Define the `pivotPoint` UDT containing the time and price of pivots.
    type pivotPoint
        int openTime
        float level

    // Create an empty array of pivot points.
    var pivotHighArray = array.new<pivotPoint>()

    // Detect new pivots (`na` is returned when no pivot is found).
    pivotHighPrice = ta.pivothigh(legsInput, legsInput)

    // Create an object for each new pivot and add it to the end of the array.
    if not na(pivotHighPrice)
        // A new pivot is found; create a new object of `pivotPoint` type, setting its `openTime` and `level` fields.
        newPivot = pivotPoint.new(time[legsInput], pivotHighPrice)
        // Add the new pivot object to the array.
        array.push(pivotHighArray, newPivot)

    // On the last historical bar, draw pivot labels and connecting lines.
    if barstate.islastconfirmedhistory
        var pivotPoint previousPoint = na
        for eachPivot in pivotHighArray
            // Display a label at the pivot point.
            label.new(eachPivot.openTime, eachPivot.level, str.tostring(eachPivot.level, format.mintick), xloc.bar_time, textcolor = color.white)
            // Create a line between pivots.
            if not na(previousPoint)
                // Only create a line starting at the loop's second iteration because lines connect two pivots.
                line.new(previousPoint.openTime, previousPoint.level, eachPivot.openTime, eachPivot.level, xloc = xloc.bar_time)
            // Save this iteration's pivot for use in the next iteration.
            previousPoint := eachPivot
 


Copying objects
---------------

Pine Script™ objects are assigned by reference, which means that when we assign an existing object to a new variable, 
both point to the same object. In the example below, we create a ``pivot1`` object and set its ``x`` field to 1000. 
After that, we declare a ``pivot2`` variable containing the reference to the ``pivot1`` object, so both variables point to the same object. 
Changing ``pivot2.x`` will thus also change ``pivot1.x`` as both refer to the ``x`` field of the same object:

::

    //@version=5
    indicator("")
    type pivotPoint
        int x
        float y
    pivot1 = pivotPoint.new()
    pivot1.x := 1000
    pivot2 = pivot1
    pivot2.x := 2000
    // Both plot the value 2000.
    plot(pivot1.x)
    plot(pivot2.x)

To create a copy of an object that is independent of the original, the ``copy()`` built-in method can be used with any UDT.
In the following example, we create a new ``pivot2`` object that is copy of ``pivot1``.
The two are from that point on independent entities, so ``pivot2``'s fields can be changed without affecting ``pivot1``:

::

    //@version=5
    indicator("")
    type pivotPoint
        int x
        float y
    pivot1 = pivotPoint.new()
    pivot1.x := 1000
    pivot2 = pivotPoint.copy(pivot1)
    pivot2.x := 2000
    // Plots 1000 and 2000.
    plot(pivot1.x)
    plot(pivot2.x)



Shadowing
---------

To avoid potential conflicts in the eventuality where namespaces added to Pine Script™ in the future 
would collide with UDTs or object names in existing scripts, as a rule, UDTs and object names shadow the language's namespaces.
For example, a UDT or object can use the name of built-in types such as 
`line <https://www.tradingview.com/pine-script-reference/v5/#op_line>__` or 
`table <https://www.tradingview.com/pine-script-reference/v5/#op_table>__`.

Only the language's five primitive types cannot be used to name UDTs or objects: 
`int <https://www.tradingview.com/pine-script-reference/v5/#op_int>__`, 
`float <https://www.tradingview.com/pine-script-reference/v5/#op_float>__`, 
`string <https://www.tradingview.com/pine-script-reference/v5/#op_string>__`, 
`bool <https://www.tradingview.com/pine-script-reference/v5/#op_bool>__`, and 
`color <https://www.tradingview.com/pine-script-reference/v5/#op_color>__`.




.. image:: /images/TradingView-Logo-Block.svg
    :width: 200px
    :align: center
    :target: https://www.tradingview.com/