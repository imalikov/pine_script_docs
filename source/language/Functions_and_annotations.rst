Functions and annotations
=========================

Pine Script distinguishes between *functions* and *annotation functions* (or just *annotations*).
Syntactically they are similar, but they serve different purposes.

While functions are generally used to calculate values and for the result they return,
annotations are mostly used for their side effects and only occasionally for the result some of them return.

Functions may be built-in, such as
`sma <https://www.tradingview.com/pine-script-reference/v4/#fun_sma>`__,
`ema <https://www.tradingview.com/pine-script-reference/v4/#fun_ema>`__,
`rsi <https://www.tradingview.com/pine-script-reference/v4/#fun_rsi>`__,
or :doc:`user-defined <Declaring_functions>`. All annotations are built-in.

The side effects annotations are used for include:

-  assigning a name or other global properties to a script using
   `study <https://www.tradingview.com/pine-script-reference/v4/#fun_study>`__
   or `strategy <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy>`__
-  determining the inputs of a script using
   `input <https://www.tradingview.com/pine-script-reference/v4/#fun_input>`__
-  determining the outputs of a script using
   `plot <https://www.tradingview.com/pine-script-reference/v4/#fun_plot>`__

In addition to having side effects, a few annotations such as ``plot`` and ``hline``
also return a result which may be used or not. This result, however, can only be used in other annotations
and can't take part in the script's calculations
(see `fill <https://www.tradingview.com/pine-script-reference/v4/#fun_fill>`__ annotation).

A detailed overview of Pine annotations can be found :doc:`here </annotations/index>`.

Syntactically, user-defined functions, built-in functions and annotation
functions are similar, i.e., we call them by name with a list of
arguments in parentheses. Differences between them are mostly semantic, except
for the fact that annotations and
built-in functions accept keyword arguments while user-defined functions
do not (see :ref:`release note on kwargs in built-in
functions <kwargs_syntax_for_all_builtin_functions>`).

Example of an annotation call with positional arguments::

    study('Example', 'Ex', true)

The same call with keyword arguments::

    study(title='Example', shorttitle='Ex', overlay=true)

It's possible to mix positional and keyword arguments. Positional
arguments must go first and keyword arguments should follow them. So the
following call is not valid:

::

    study(precision=3, 'Example') // Compilation error!
