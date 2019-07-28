Declaring functions
===================

.. contents:: :local:
    :depth: 2

Pine has an extensive library of built-in functions which
can be used to create scripts. Users can also create their own functions.

Single-line functions
---------------------

Simple functions can often be written on one line. This
is the syntax of single-line functions:

.. code-block:: text

    <identifier>(<list of arguments>) => <expression>

Here is an example::

    f(x, y) => x + y

After the function ``f`` has been declared, it's possible to call it using different types of arguments::

    a = f(open, close)
    b = f(2, 2)
    c = f(open, 2)

The type of the value returned by function ``f`` is determined automatically
and depends on the type of the arguments used in each particular function call. In the example above, the
type of variable ``a`` is *series* because the arguments are both *series*. The type of variable ``b`` is
*integer* because arguments are both *literal integers*. The type of variable ``c`` is *series*
because the addition of a *series* and *literal integer* produces a *series* result.

Pine Scipt functions do not support recursion. It is **not allowed** for a function to call itself from within its own code.


.. _multi_line_functions:

Multi-line functions
--------------------

Pine also supports multi-line functions with the following syntax:

.. code-block:: text

    <identifier>(<list of arguments>) =>
        <variable declaration>
        ...
        <variable declaration or expression>

The body of a multi-line function consists of several statements. Each
statement is placed on a separate line and must be preceded by 1
indentation (4 spaces or 1 tab). The indentation before the statement
indicates that it is a part of the body of the function and not part of the
script's global scope. After the function's code, the first statement without an indent
indicates the body of the function has ended.

Either an expression or a declared variable should be the last statement
of the function's body. The result of this expression (or variable) will
be the result of the function's call. For example::

    geom_average(x, y) =>
        a = x*x
        b = y*y
        sqrt(a + b)

The function ``geom_average`` has two arguments and creates two variables
in the body: ``a`` and ``b``. The last statement calls the function ``sqrt``
(an extraction of the square root). The ``geom_average`` call will return
the value of the last expression: ``(sqrt(a + b))``.

Scopes in the script
--------------------

Variables declared outside the body of a function or of other local blocks belong to
the *global* scope. User-declared and buit-in functions, as well as built-in
variables also belong to the global scope.

Each function has its own *local* scope. All the variables declared
within the function, as well as the function's arguments, belong to the scope of
that function, meaning that it is impossible to reference them from
outside --- e.g., from the global scope or the local scope of another
function.

On the other hand, since it is possible to refer to any variable or function
declared in the global scope from the scope of a function (except for
self-referencing recursive calls), one can say
that the local scope is embedded into the global scope.

In Pine, nested functions are not allowed, i.e., one cannot declare a
function inside another one. All user functions are declared in the
global scope. Local scopes cannot intersect with each other.


Functions that return multiple results
--------------------------------------

In most cases a function returns only one result, but it is possible to
return a list of results (a *tuple*-like result)::

    fun(x, y) =>
        a = x+y
        b = x-y
        [a, b]

Special syntax is required for calling such functions:

::

    [res0, res1] = fun(open, close)
    plot(res0)
    plot(res1)
