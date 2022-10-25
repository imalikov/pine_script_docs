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
  .  coordinate is expressed in: bar index or bar time. 
This field is present in many existing Pine Script™ drawings, like lines, 
and it is always set to `xloc.bar_index <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_index>__` by default, 
but we set its default to `xloc.bar_time <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_time>`__ 
by using the ``=`` operator to assign a default value to the field.

In the same way, declaring a function does not execute any code, and the function needs to be called to see its effects; 
declaring a type by itself does not do anything -- you need to create objects of that type to use the new functionality. 
In this regard, user-created objects largely follow the same logic that existing Pine Script™ built-ins use. 
To create a new object, we need to call the ``<type_indentifier>.new()`` function inherent to every custom type. 
Once called, it creates an object of our custom type with the specified number of fields.

In the example below, we wait for a new High-based pivot point to be found, and once it is, 
we create a new object of the ``pivotPoint`` type by calling the ``pivotPoint.new()`` function:

::

    // The ta.pivothigh() function returns a price value when a pivot is found, `na` otherwise.
    pivotHighPrice = ta.pivothigh(10, 10)
    if not na(pivotHighPrice)
        foundPoint = pivotPoint.new()
	
Once created with `pivotPoint.new()`, our object has three fields. However, only one of these has an actual value 
(not `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>__` <>) assigned to it: 
the `xloc` field, which we have as `xloc.bar_time <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_time>`__ by default. 
The two other fields will return `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>__` 
until we modify them by assigning them a more fitting value.

If you want to create a variable of the chosen type without calling the ``.new()`` function, 
you can do so by assigning `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>__` to it. 
In that case, you also need to specify the variable type before its name. The syntax is:

.. code-block:: text

    <type_identifier> <variable_name> = na

The example above could be rewritten to use this method:

::

    pivotHighPrice = ta.pivothigh(10, 10)
    if not na(pivotHighPrice)
        pivotPoint foundPoint = na
        foundPoint := pivotPoint.new()

If an object is created with the `var <https://www.tradingview.com/pine-script-reference/v5/#op_var>__` or 
`varip <https://www.tradingview.com/pine-script-reference/v5/#op_varip>__` keywords, 
all its fields will behave as if they were created with the keyword in question:

::

    type barInfo
        int _index = bar_index
        int _time = time
        float _close = close

    var firstBar = barInfo.new() // Created on bar 0
    currentBar = barInfo.new() // Created on every bar

    plot(firstBar._index)
    plot(currentBar._index)



Reading and modifying object fields
-----------------------------------

When created, each object reserves its own namespace based on the name given to that object. 
This namespace is used to reference the particular object's fields, either to request their value or to change it. 

The easiest way to assign a value to an object's field is during the object creation. 
You can pass a value directly to the `.new()` method, and the field can be referenced both by position and by name. 
In the example below, we pass ``time[10]`` as a value to our ``x`` field (implicitly, because ``x`` is the first field our object has), 
and then we assign ``pivotHighPrice`` to the ``y`` field explicitly, 
by referencing the field by its name. 
The ``xloc`` field is not specified at all, so the default value of the field, 
`xloc.bar_time <https://www.tradingview.com/pine-script-reference/v5/#var_xloc{dot}bar_time>`__, is assigned to it.

::

    pivotHighPrice = ta.pivothigh(10, 10)
    if not na(pivotHighPrice)
        foundPoint = pivotPoint.new(time[10], y = pivotHighPrice)


Alternatively, the fields can be assigned after the object is was created. 
In Pine Script™, the ``:=`` operator is used when a new value needs to be assigned to a variable 
that already was declared with a specific certain value. 
With objects, we only ever use ``:=`` to change the object's fields because all fields are declared when the object itself is created 
(if the value for the field is not explicitly specified, it will be `na <https://www.tradingview.com/pine-script-reference/v5/#var_na>__`).

Continuing our example indicator, we assign each field of our newly created ``foundPoint`` object 
a new value inside of the ``pivotPoint.new()`` function. 
E.g., we assign the ``x`` field the value of ``time[10]`` -- 
because the `ta.pivothigh() <https://www.tradingview.com/pine-script-reference/v5/#fun_ta{dot}pivothigh>__` function 
waits for several (in our case, 10) bars to confirm that the pivot has been found.
Once all values are assigned, we pass them to the 
`label.new() <https://www.tradingview.com/pine-script-reference/v5/#fun_label{dot}new>__` function 
to create a `label <https://www.tradingview.com/pine-script-reference/v5/#op_label>__` at the coordinates where the pivot was found.

::

    pivotHighPrice = ta.pivothigh(10, 10)
    if not na(pivotHighPrice)
        foundPoint = pivotPoint.new(time[10], pivotHighPrice)

        // Also a good valid way to create an object and assign values to its fields:
        // foundPoint = pivotPoint.new()
        // foundPoint.x := bar_index[10]
        // foundPoint.y := pivotHighPrice

        // Passing various `foundPoint` values to the `label.new() function to create a label based on them
        label.new(foundPoint.x, foundPoint.y, text = "Pivot High", xloc = foundPoint.xloc)
	
	

Collecting objects
------------------

Objects of user-defined types can be used with Pine Script™ structures like arrays and matrices. 
However, when creating such structures, you also need to specify the type in the function that creates the structure itself. 
This can be done by using the `array.new<>()` or `matrix.new<>()` functions and specifying the name of our type inside the triangular brackets. 
In the example below, we create an `array <https://www.tradingview.com/pine-script-reference/v5/#op_array>__` for our ``pivotPoint`` objects:

::

    var pivotHighArray = array.new<pivotPoint>()

If you want to explicitly typify the variable as an array or a matrix of a custom type, 
you can use the `array<> <https://www.tradingview.com/pine-script-reference/v5/#op_array>__` and 
`matrix<> <https://www.tradingview.com/pine-script-reference/v5/#op_matrix>__` keywords, e.g.:

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