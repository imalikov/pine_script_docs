Operators
=========

.. contents:: :local:
    :depth: 2

Arithmetic operators
--------------------

There are five arithmetic operators in Pine Script:

+-------+------------------------------------+
| ``+`` | Addition                           |
+-------+------------------------------------+
| ``-`` | Subtraction                        |
+-------+------------------------------------+
| ``*`` | Multiplication                     |
+-------+------------------------------------+
| ``/`` | Division                           |
+-------+------------------------------------+
| ``%`` | Modulo (remainder after division)  |
+-------+------------------------------------+

The arithmetic operators above are all binary, whith ``+`` and ``-`` also serving as unary operators.
When using arithmetic operators, the type of the result depends on
the type of the operands. If at least one of the operands is a *series*, then
the result will also have a *series* type. If both operands are numeric,
but at least one of these has the type *float*, then the result will
also have the type *float*. If both operands are of type *integer*, then the
result will also have the type *integer*.

Footnote: if at least one operand is ``na`` then the result is also
``na``.

Comparison operators
--------------------

There are six comparison operators in Pine Script:

+--------+---------------------------------+
| ``<``  | Less Than                       |
+--------+---------------------------------+
| ``<=`` | Less Than or Equal To           |
+--------+---------------------------------+
| ``!=`` | Not Equal                       |
+--------+---------------------------------+
| ``==`` | Equal                           |
+--------+---------------------------------+
| ``>``  | Greater Than                    |
+--------+---------------------------------+
| ``>=`` | Greater Than or Equal To        |
+--------+---------------------------------+

Comparison operations are binary. The result is determined by the type
of the operands. If at least one of these operands has a *series* type, then
the type of the result will also be *series* (a series of logical
values). If both operands have a numerical type, then the result will be
of the logical type *bool*.

Logical operators
-----------------

There are three logical operators in Pine Script:

+---------+---------------------------------+
| ``not`` | Negation                        |
+---------+---------------------------------+
| ``and`` | Logical Conjunction             |
+---------+---------------------------------+
| ``or``  | Logical Disjunction             |
+---------+---------------------------------+

All logical operators can operate with *bool* operands, numerical
operands, or *series* type operands. As is the case with arithmetic and comparison
operators, if at least one of the operands is of *series*
type, then the result will also be of *series* type. In all other cases
the type of the result will be the logical type *bool*.

The operator ``not`` is unary. When applied to a ``true``
operand the result will be ``false``, and vice versa.

``and`` operator truth table:

+---------+---------+-----------+
| a       | b       | a and b   |
+=========+=========+===========+
| true    | true    | true      |
+---------+---------+-----------+
| true    | false   | false     |
+---------+---------+-----------+
| false   | true    | false     |
+---------+---------+-----------+
| false   | false   | false     |
+---------+---------+-----------+

``or`` operator truth table:

+---------+---------+----------+
| a       | b       | a or b   |
+=========+=========+==========+
| true    | true    | true     |
+---------+---------+----------+
| true    | false   | true     |
+---------+---------+----------+
| false   | true    | true     |
+---------+---------+----------+
| false   | false   | false    |
+---------+---------+----------+

.. _ternary_operator:

``?:`` conditional operator and the ``iff`` function
----------------------------------------------------

The ``?:`` `conditional ternary
operator <https://www.tradingview.com/pine-script-reference/v4/#op_{question}{colon}>`__
calculates the first expression (condition) and returns the value of either
the second operand (if the condition is ``true``) or of the third
operand (if the condition is ``false``). Syntax is::

    condition ? result1 : result2

If ``condition`` is ``true`` then the ternary operator will return ``result1``,
otherwise it will return ``result2``.

A combination of conditional operators can build
constructs similar to *switch* statements in other languages. For
example::

    isintraday ? red : isdaily ? green : ismonthly ? blue : na

The example is calculated from left to right.
First, the ``isintraday`` condition is calculated; if it is ``true`` then
``red`` will be the result. If it is ``false`` then ``isdaily`` is calculated,
if this is ``true``, then ``green`` will be the result. If it is
``false``, then ``ismonthly`` is calculated. If it is ``true``, then ``blue``
will be the result, otherwise ``na`` will be the result.

For those who find using the ``?:`` operator syntax inconvenient,
there is an alternative: the built-in ``iff`` function.
The function has the following signature::

    iff(condition, result1, result2)

The function acts identically to the ``?:`` operator, i.e., if the
condition is ``true`` then it returns ``result1``, otherwise ``result2``.
This is the equivalent of the previous example using ``iff``::

    iff(isintraday, red, iff(isdaily, green,
                         iff(ismonthly, blue, na)))

.. _history_referencing_operator:

History reference operator ``[]``
---------------------------------

It is possible to refer to the historical values of any variable of the
*series* type with the ``[]`` operator (*historical* values are the values for the previous bars).
Let's assume we have the variable ``close``,
containing 10 values corresponding to a chart with 10 bars:

+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| Index   | 0       | 1       | 2       | 3       | 4       | 5       | 6       | 7       | 8       | 9       |
+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| close   | 15.25   | 15.46   | 15.35   | 15.03   | 15.02   | 14.80   | 15.01   | 12.87   | 12.53   | 12.43   |
+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+

Applying the ``[]`` operator with arguments 1, 2, 3, we will receive the
following vector:

+------------+-------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| Index      | 0     | 1       | 2       | 3       | 4       | 5       | 6       | 7       | 8       | 9       |
+------------+-------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| close[1]   | ``na``| 15.25   | 15.46   | 15.35   | 15.03   | 15.02   | 14.80   | 15.01   | 12.87   | 12.53   |
+------------+-------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| close[2]   | ``na``| ``na``  | 15.25   | 15.46   | 15.35   | 15.03   | 15.02   | 14.80   | 15.01   | 12.87   |
+------------+-------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| close[3]   | ``na``| ``na``  | ``na``  | 15.25   | 15.46   | 15.35   | 15.03   | 15.02   | 14.80   | 15.01   |
+------------+-------+---------+---------+---------+---------+---------+---------+---------+---------+---------+

When a vector is shifted, a special ``na`` value is pushed to the vector's
tail. ``na`` means that the numerical value based on the given index is
absent (*not available*). The values to the right, which do not have enough space to be
placed in a vector of 10 elements, are simply removed. The
value from the vector's head is *popped*. In the given example, the index
of the current bar is equal to 9. The value of the ``close[1]`` vector on the current bar will be equal
to the previous value of the initial ``close`` vector.
The value ``close[2]`` will be equal to the value ``close`` two bars ago, etc.

So the ``[]`` operator can be thought of as a history-referencing
operator.

**Note 1**. Almost all built-in functions in Pine's standard library
return a *series* result. It is therefore
possible to apply the ``[]`` operator directly to function calls, as is done here:

::

    sma(close, 10)[1]

**Note 2**. Despite the fact that the ``[]`` operator returns a result
of *series* type, it is prohibited to apply this operator to the same
operand over and over again. Here is an example of incorrect use
which will generate a compilation error:

::

    close[1][2] // Error: incorrect use of [] operator

In some situations, the user may want to shift the series to the left.
Negative arguments for the operator ``[]`` are prohibited. This can be
accomplished using the ``offset`` parameter in the ``plot`` annotation, which
supports both positive and negative values. Note though that it is a
visual shift., i.e., it will be applied after all calculations.
Further details on ``plot`` and its parameters can be found
`here <https://www.tradingview.com/pine-script-reference/v4/#fun_plot>`__.

There is another important consideration when using the ``[]`` operator in
Pine. The script executes a calculation on each bar,
beginning from the earliest bar until the last.
As seen in the table, ``close[3]`` has ``na`` values on the
first three bars. ``na`` represents a value which is not a number and
using it in any math expression will produce a result that is also ``na`` (similar
to `NaN <https://en.wikipedia.org/wiki/NaN>`__),
which in some cases can ripple through results all the way to the realtime bar.
Your code must provide for handling the special cases in early history
when expressions may result in ``na`` values. This can be accomplished using the
`na <https://www.tradingview.com/pine-script-reference/v4/#fun_na>`__ and
`nz <https://www.tradingview.com/pine-script-reference/v4/#fun_nz>`__ functions.

Operator precedence
---------------------

The order of calculations is determined by the operators' precedence.
Operators with greater precedence are calculated first. Below is a list
of operators sorted by decreasing precedence:

+------------+-------------------------------------+
| Precedence | Operator                            |
+============+=====================================+
| 9          | ``[]``                              |
+------------+-------------------------------------+
| 8          | unary ``+``, unary ``-``, ``not``   |
+------------+-------------------------------------+
| 7          | ``*``, ``%``                        |
+------------+-------------------------------------+
| 6          | ``+``, ``-``                        |
+------------+-------------------------------------+
| 5          | ``>``, ``<``, ``>=``, ``<=``        |
+------------+-------------------------------------+
| 4          | ``==``, ``!=``                      |
+------------+-------------------------------------+
| 3          | ``and``                             |
+------------+-------------------------------------+
| 2          | ``or``                              |
+------------+-------------------------------------+
| 1          | ``?:``                              |
+------------+-------------------------------------+

If in one expression there are several operators with the same precedence,
then they are calculated left to right.

If the expression must be calculated in a different order than precedence would dictate,
then parts of the expression can be grouped together with parentheses.
