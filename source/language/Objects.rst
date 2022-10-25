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

    // Define a new `pivotPoint` type.
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

Objects of user-defined types can be used with Pine Script™ structures like arrays and matrices. 
However, when creating such structures, you also need to specify the type in the function that creates the structure itself. 
This can be done by using the `array.new<>()` or `matrix.new<>()` functions and specifying the name of our type inside the triangular brackets. 
In the example below, we create an `array <https://www.tradingview.com/pine-script-reference/v5/#op_array>__` for our ``pivotPoint`` objects:

::

    var pivotHighArray = array.new<pivotPoint>()

If you want to explicitly typify the variable as an `array <https://www.tradingview.com/pine-script-reference/v5/#op_array>__` or a `matrix <https://www.tradingview.com/pine-script-reference/v5/#op_matrix>__` of a custom type, 
you can use the `array<> <https://www.tradingview.com/pine-script-reference/v5/#op_array>__` and `matrix<> <https://www.tradingview.com/pine-script-reference/v5/#op_matrix>__` keywords, e.g.:

::

    var array<pivotPoint> pivotHighArray = na
    pivotHighArray := array.new<pivotPoint>()

Using the examples we went through above, 
we create a script that connects historical Pivot High points by going over an array of ``pivotPoint`` objects:

::

    //@version=5
    indicator("Pivot Points High", overlay = true)
    
    int legsInput = input(10)
    
    // Define a new `pivotPoint` type containing the time and price of pivots.
    type pivotPoint
        int openTime
        float level
    
    // Create an empty array of pivot points.
    var pivotHighArray = array.new<pivotPoint>()
    
    // Detect new pivots (`na` is returned when no pivot is found).
    pivotHighPrice = ta.pivothigh(legsInput, legsInput)
    
    // Save new pivot information and display a label for each new pivot.
    if not na(pivotHighPrice)
        // A new pivot is found; create a new object of type `pivotPoint` with the pivot's time and price.
        newPivot = pivotPoint.new(time[legsInput], pivotHighPrice)
        // Display a label at the pivot point.
        label.new(newPivot.openTime, newPivot.level, str.tostring(newPivot.level, format.mintick), xloc = xloc.bar_time)
        // Add the new pivot to the array of pivots.
        array.push(pivotHighArray, newPivot)
    
    // On the last historical bar, connect the pivots using lines.
    if barstate.islastconfirmedhistory
        var pivotPoint previousPoint = na
        for eachPivot in pivotHighArray
            if not na(previousPoint)
                // Only create a line starting at the loop's second iteration because lines connect two pivots.
                line.new(previousPoint.openTime, previousPoint.level, eachPivot.openTime, eachPivot.level, xloc = xloc.bar_time)
            // Save this iteration's pivot for use in the next iteration.
            previousPoint := eachPivot
 


Copying objects
---------------

Pine Script™ objects are assigned by reference, which means that when we assign an existing object to a new variable, 
both the old and the new variable point to the same object. 
In the example below, we create a ``pivot1`` object and set its ``x`` to 1000. 
After that, we create a ``pivot2`` object by equating it to ``pivot1``. 
Changing ``pivot2.x`` changes ``pivot1.x`` too, because both these variables point to the same underlying object:

::

    var pivot1 = pivotPoint.new()
    pivot1.x := 1000
    pivot2 = pivot1
    pivot2.x := 2000
    plot(pivot1.x) // 2000
    plot(pivot2.x) // 2000

To create an independent copy of any object, we can use the `.copy()` function that is inherent to every user-created object. 
In the following example, we copy ``pivot1`` with the ``pivotPoint.copy()`` function, 
which creates a separate object that can be changed without affecting ``pivot1``:

::

    var pivot1 = pivotPoint.new()
    pivot1.x := 1000
    pivot2 = pivotPoint.copy(pivot1)
    Pivot2.x := 2000
    plot(pivot1.x) // 1000
    plot(pivot2.x) // 2000



Shadowing
---------

As one 
Due to the fact that objects create their own namespaces, 
there might be potential conflicts when an object is created with the same name as an existing namespace. 
For backwards compatibility, the user-created objects and types shadow the existing ones, 
which means that if we were to add a new type or namespace to Pine Script™ and you already have a script with the type with the same name, 
your script will be unaffected. The specific behavior is as follows:

A user-defined type or object cannot share the name of any of the five primitive types in Pine Script™: 
`int <https://www.tradingview.com/pine-script-reference/v5/#op_int>__`, 
`float <https://www.tradingview.com/pine-script-reference/v5/#op_float>__`, 
`string <https://www.tradingview.com/pine-script-reference/v5/#op_string>__`, 
`bool <https://www.tradingview.com/pine-script-reference/v5/#op_bool>__`, and 
`color <https://www.tradingview.com/pine-script-reference/v5/#op_color>__`.

A user-defined type or object can use the name of any other built-in type 
(e.g., `line <https://www.tradingview.com/pine-script-reference/v5/#op_line>__` or 
`table <https://www.tradingview.com/pine-script-reference/v5/#op_table>__`).



.. image:: /images/TradingView-Logo-Block.svg
    :width: 200px
    :align: center
    :target: https://www.tradingview.com/