Strategies
==========

.. contents:: :local:
    :depth: 2

..    include:: <isonum.txt>

A *strategy* is a study that can send, modify and cancel *orders* (to
buy/sell). Strategies allow you to perform *backtesting* (emulation of
strategy trading on historical data) and *forwardtesting* (emulation
of strategy trading on real-time data) according to your precoded
algorithms.

A strategy written in Pine Script language has all the same capabilities
as a Pine indicator. When you write a strategy code, it should start
with the `strategy <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy>`__
annotation call (instead of ``study``). Strategies not
only plot something, but also place, modify and cancel orders. They have
access to essential strategy performance information through specific
keywords. The same information is available for you on the *Strategy
Tester* tab. Once a strategy is calculated on historical data, you can
see hypothetical order fills.

A simple strategy example
-------------------------

::

    //@version=4
    strategy("test")
    if bar_index > 4000
        strategy.entry("buy", strategy.long, 10, when=strategy.position_size <= 0)
        strategy.entry("sell", strategy.short, 10, when=strategy.position_size > 0)
    plot(strategy.equity)

As soon as the script is compiled and applied to a chart, you can see
filled order marks on it and how your balance was changing during
backtesting (*equity* curve). It is a simplest strategy that buys and
sells on every bar.

The line ``strategy("test")`` states that the code belongs to strategy
type and its name is "test". ``strategy.entry()`` is a command to send
"buy" and "sell" orders. ``plot(strategy.equity)`` plots the equity
curve.

How to apply a strategy to the chart
------------------------------------

To test your strategy, apply it to the chart. Use the symbol and time
intervals that you want to test. You can use a built-in strategy from
the *Indicators & Strategies* dialog box, or write your own in *Pine
Editor*.

.. image:: images/Strategy_tester.png

.. note:: When using :doc:`non-standard types of chart <Non-standard_chart_types_data>`
   (Heikin Ashi, Renko, etc.) as a basis for strategy, you
   need to realize that the result will be different. The orders will be
   executed at the prices of this chart (e.g., for Heikin Ashi it'll take
   Heikin Ashi prices (the average ones) **not the real market prices**).
   Therefore we highly recommend you to use standard chart type for
   strategies.

Backtesting and forwardtesting
------------------------------

On TradingView strategies are calculated on all available historical
data on the chart and automatically continue calculation when real-time
data comes in.

Both during historical and real-time calculation, code is calculated on
bar closes by default.

If this is forwardtesting, code calculates on every tick in real-time.
To enable this, check off the option *Recalculate On Every Tick* in
settings or specify it in the script code: ``strategy(..., calc_on_every_tick=true)``.

You can set the strategy to perform additional calculation after an
order is filled. For this you need to check off *Recalculate After Order
filled* in settings or do it in the script code: ``strategy(..., calc_on_order_fills=true)``.

Broker emulator
---------------

There is a *broker emulator* on TradingView for testing strategies. Unlike
real trading, the emulator fills orders only at chart prices, that is
why an order can be filled only on next tick in forwardtesting and on
next bar in backtesting (or later) after the strategy calculated.

As stated above, in backtesting the strategy is calculated on bar's close.
The following logic is used to emulate order fills:

#. If opening price of bar is closer to the highest price of the same bar,
   the broker emulator assumes that intrabar price was moving this way:
   open → high → low → close.
#. If opening price of bar is closer to the lowest price of the same bar,
   the broker emulator assumes that intrabar price was moving this way:
   open → low → high → close.
#. Broker emulator assumes that there were no gaps inside bar, meaning
   all intrabar prices are available for order execution.
#. If the option *Recalculate On Every Tick* in strategy properties is
   enabled (or ``strategy`` parameter ``calc_on_every_tick=true`` is
   specified in the script), code is still calculated only on bar's close,
   following the above logic.

.. image:: images/Filled_stategy.png

Here is a strategy demonstrating how orders are filled by the broker
emulator::

    //@version=4
    strategy("History SAW demo", overlay=true, pyramiding=100, calc_on_order_fills=true)
    strategy.entry("LE", strategy.long)

This code is calculated once per bar by default, on its close, however
there is an additional calculation as soon as an order is filled. That
is why you can see 4 filled orders on every bar: 2 orders on open, 1
order on high and 1 order on low. This is backtesting. If it were at
real-time, orders would be executed on every new tick.

It is also possible to emulate an *order queue*. The setting is called
*Verify Price For Limit Orders* and can be found in strategy properties
or set in the script code: ``strategy(..., backtest_fill_limits_assumption=X)``.
The specified value is a number of points/pips (minimum price movements), default value is 0.
A limit order is filled if current price is better (higher for sell
orders, lower for buy orders) for the specified number of points/pips.
The execution price still matches the limit order price. Example:

* ``backtest_fill_limits_assumption = 1``. Minimum price movement is ``0.25``.

* A buy limit order is placed at price ``12.50``.

* Current price is ``12.50``.

* The order cannot be filled at the current price only because
  ``backtest_fill_limits_assumption = 1``. To fill the order the price must
  become ``0.25*1`` lower. The order is put in the queue.

* Assume that the next tick comes at price ``12.00``. This price is 2 points
  lower, what means the condition ``backtest_fill_limits_assumption = 1``
  is satisfied, so the order should be filled. The order is filled at
  ``12.50`` (original order price), even if the price is not available
  anymore.

Order placement commands
------------------------

All keywords that are designed for strategies start with a
``strategy.`` prefix. The following commands are used for placing
orders: ``strategy.entry``, ``strategy.order`` and ``strategy.exit``:

`strategy.entry <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy{dot}entry>`__
   This command places only entry orders. It is
   affected by ``pyramiding`` setting (in strategy properties) and by
   ``strategy.risk.allow_entry_in`` function. If there is an open
   market position when an opposite direction order is generated, the
   number of contracts/shares/lots/units will be increased by the number
   of currently open contracts (script equivalent: ``strategy.position_size + quantity``).
   As the result, the size of market position to open will be equal to order size, specified in
   the command ``strategy.entry``.

`strategy.order <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy{dot}order>`__
   This command places both entry and exit orders. It is not affected by pyramiding setting and by
   ``strategy.risk.allow_entry_in`` function. It allows you to create
   complex enter and exit order constructions when capabilities of the
   ``strategy.entry`` and ``strategy.exit`` are not enough.

`strategy.exit <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy{dot}exit>`__
   This command allows you to exit a market position
   by an order or or form multiple exit order strategy (stop loss,
   profit target, trailing stop). All such orders are part of the same
   ``strategy.oca.reduce`` group. An exit order cannot be placed if
   there is no open market position or there is no active entry order
   (an exit order is bound to ID of an entry order). It is not possible
   to exit a position with a market order using the command
   ``strategy.exit``. For this goal the following commands should be
   used: `strategy.close <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy{dot}close>`__
   or `strategy.close_all <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy{dot}close_all>`__.
   If number of contracts/shares/lots/units specified for the ``strategy.exit`` is
   less than the size of current open position, the exit will be
   partial. It is not possible to exit from the same entry order more
   than 1 time using the same exit order (ID), that allows you to create
   exit strategies with multiple levels. In case, when a market position
   was formed by multiple entry orders (pyramiding enabled), each exit
   orders is bound to each entry order individually.

Example 1::

    //@version=4
    strategy("revers demo")
    if bar_index > 4000
        strategy.entry("buy", strategy.long, 4, when=strategy.position_size <= 0)
        strategy.entry("sell", strategy.short, 6, when=strategy.position_size > 0)
    plot(strategy.equity)

The above strategy constantly reverses market position from +4 to -6,
back and forth, what is shown by its plot.

Example 2::

    //@version=4
    strategy("exit once demo")
    strategy.entry("buy", strategy.long, 4, when=strategy.position_size <= 0)
    strategy.exit("bracket", "buy",  2, profit=10, stop=10)

This strategy demonstrates the case, when market position is never
closed, because it uses exit order to close market position only
partially and it cannot be used more than once. If you double the line
for exiting, the strategy will close market position completely.

Example 3::

    //@version=4
    strategy("Partial exit demo")
    if bar_index > 4000
        strategy.entry("buy", strategy.long, 4, when=strategy.position_size <= 0)
    strategy.exit("bracket1", "buy",  2, profit=10, stop=10)
    strategy.exit("bracket2", "buy",  profit=20, stop=20)

This code generates 2 levels of brackets (2 take profit orders and 2
stop loss orders). Both levels are activated at the same time: first
level to exit 2 contracts and the second one to exit all the rest.

.. image:: images/Levels_brackets.png

The first take profit and stop loss orders (level 1) are in an :ref:`OCA group <oca_groups>`.
The other orders (level 2) are in another OCA group. It means
that as soon as the order from level 1 is filled, the orders from level 2
are not cancelled, they stay active.

Every command placing an order has an ID (string value) --- unique order
identifier. If an order with same ID is already placed (but not yet
filled), current command modifies the existing order. If modification is
not possible (conversion from buy to sell), the old order is cancelled,
the new order is placed. ``strategy.entry`` and ``strategy.order`` work
with the same IDs (they can modify the same entry order).
``strategy.exit`` works with other order IDs (it is possible to have an
entry order and an exit order with the same ID).

To cancel a specific order (by its ID) the command
`strategy.cancel(string ID) <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy{dot}cancel>`__
should be used. To cancel all pending
orders the command `strategy.cancel_all() <https://www.tradingview.com/pine-script-reference/v4/#fun_strategy{dot}cancel_all>`__
should be used. Strategy orders are placed as soon as their conditions are satisfied and command
is called in code. Broker emulator doesn't execute orders before next
tick comes after the code was calculated, while in real trading with
real broker, an order can be filled sooner. It means that if a market
order is generated at close of current bar, it is filled at open price of the
next bar.

Example::

    //@version=4
    strategy("next bar open execution demo")
    if bar_index > 4000
        strategy.order("buy", strategy.long, when=strategy.position_size == 0)
        strategy.order("sell", strategy.short, when=strategy.position_size != 0)

If this code is applied to a chart, all orders are filled at open of
every bar.

Conditions for order placement (``when``, ``pyramiding``, ``strategy.risk``)
are checked when script is calculated. If all
conditions are satisfied, the order is placed. If any condition is not
satisfied, the order is not placed. It is important to cancel price
orders (limit, stop and stop-limit orders).

Example (for MSFT, 1D)::

    //@version=4
    strategy("Priced Entry demo")
    var c = 0
    if year > 2014
        c := c + 1
    if c == 1
        strategy.entry("LE1", strategy.long, 2, stop = high + 35 * syminfo.mintick)
        strategy.entry("LE2", strategy.long, 2, stop = high + 2 * syminfo.mintick)

Even though pyramiding is disabled, these both orders are filled in
backtesting, because when they are generated there is no open long
market position. Both orders are placed and when price satisfies order
execution, they both get executed. It is recommended to to put the
orders in 1 OCA group by means of ``strategy.oca.cancel``. in this case
only one order is filled and the other one is cancelled. Here is the
modified code::

    //@version=4
    strategy("Priced Entry demo")
    var c = 0
    if year > 2014
        c := c + 1
    if c == 1
        strategy.entry("LE1", strategy.long, 2, stop = high + 35 * syminfo.mintick, oca_type = strategy.oca.cancel, oca_name = "LE")
        strategy.entry("LE2", strategy.long, 2, stop = high + 2 * syminfo.mintick, oca_type = strategy.oca.cancel, oca_name = "LE")

If, for some reason, order placing conditions are not met when executing
the command, the entry order will not be placed. For example, if
pyramiding settings are set to 2, existing position already contains two
entries and the strategy tries to place a third one, it will not be
placed. Entry conditions are evaluated at the order generation stage and
not at the execution stage. Therefore, if you submit two price type
entries with pyramiding disabled, once one of them is executed the other
will not be cancelled automatically. To avoid issues we recommend using
``strategy.oca.cancel`` groups for entries so when one entry order is filled the
others are cancelled.

The same is true for price type exits --- orders will be placed once their
conditions are met (i.e. an entry order with the respective ID is
filled).

Example::

    //@version=4
    strategy("order place demo")
    var counter = 0
    counter := counter + 1
    strategy.exit("bracket", "buy", profit=10, stop=10, when = counter == 1)
    strategy.entry("buy", strategy.long, when=counter > 2)

If you apply this example to a chart, you can see that the exit order
has been filled despite the fact that it had been generated only once
before the entry order to be closed was placed. However, the next entry
was not closed before the end of the calculation as the exit command has
already been triggered.


Closing market position
-----------------------

Despite it is possible to exit from a specific entry in code, when
orders are shown in the *List of Trades* on *Strategy Tester* tab, they all
are linked according FIFO (first in, first out) rule. If an entry order
ID is not specified for an exit order in code, the exit order closes the
first entry order that opened market position. Let's study the following
example::

    //@version=4
    strategy("exit Demo", pyramiding=2, overlay=true)
    strategy.entry("Buy1", strategy.long, 5,
                   when = strategy.position_size == 0 and year > 2014)
    strategy.entry("Buy2", strategy.long,
                   10, stop = strategy.position_avg_price +
                   strategy.position_avg_price*0.1,
                   when = strategy.position_size == 5)
    strategy.exit("bracket", loss=10, profit=10, when=strategy.position_size == 15)

The code given above places 2 orders sequentially: "Buy1" at market
price and "Buy2" at 10% higher price (stop order). Exit order is placed
only after entry orders have been filled. If you apply the code to a
chart, you will see that each entry order is closed by exit order,
though we did not specify entry order ID to close in this line:
``strategy.exit("bracket", loss=10, profit=10, when=strategy.position_size == 15)``

Another example::

    //@version=4
    strategy("exit Demo", pyramiding=2, overlay=true)
    strategy.entry("Buy1", strategy.long, 5, when = strategy.position_size == 0)
    strategy.entry("Buy2", strategy.long,
                10, stop = strategy.position_avg_price +
                strategy.position_avg_price*0.1,
                when = strategy.position_size == 5)
    strategy.close("Buy2",when=strategy.position_size == 15)
    strategy.exit("bracket", "Buy1", loss=10, profit=10, when=strategy.position_size == 15)
    plot(strategy.position_avg_price)

-  It opens 5 contracts long position with the order "Buy1".
-  It extends the long position by purchasing 10 more contracts at 10%
   higher price with the order "Buy2".
-  The exit order (strategy.close) to sell 10 contracts (exit from
   "Buy2") is filled.

If you take a look at the plot, you can see that average entry price =
"Buy2" execution price and our strategy closed exactly this entry order,
while on the *Trade List* tab we can see that it closed the first "Buy1"
order and half of the second "Buy2". It means that the no matter what
entry order you specify for your strategy to close, the broker emulator
will still close the the first one (according to FIFO rule). It works
the same way when trading with through a real broker.

.. _oca_groups:

OCA groups
----------

It is possible to put orders in 2 different One-Cancells-All (OCA) groups in Pine Script:

`strategy.oca.cancel <https://www.tradingview.com/pine-script-reference/v4/#var_strategy{dot}oca{dot}cancel>`__
   As soon as an order from the group is filled
   (even partially) or cancelled, the other orders from the same group
   get cancelled. One should keep in mind that if order prices are the
   same or they are close, more than 1 order of the same group may be
   filled. This OCA group type is available only for entry orders
   because all exit orders are placed in ``strategy.oca.reduce``.

Example::

    //@version=4
    strategy("oca_cancel demo")
    if year > 2014 and year < 2016
        strategy.entry("LE", strategy.long, oca_type = strategy.oca.cancel, oca_name="Entry")
        strategy.entry("SE", strategy.short, oca_type = strategy.oca.cancel, oca_name="Entry")

You may think that this is a reverse strategy since pyramiding is not
allowed, but in fact both order will get filled because they are market
orders, what means they are to be executed immediately at the current price.
The second order doesn't get cancelled because both are filled almost at
the same moment and the system doesn't have time to process first order
fill and cancel the second one before it gets executed. The same would
happen if these were price orders with same or similar prices. Strategy
places all orders (which are allowed according to market position, etc).

The strategy places all orders that do not contradict the rules (in our
case market position is flat, therefore any entry order can be filled).
At each tick calculation, firstly all orders with the satisfied
conditions are executed and only then the orders from the group where an
order was executed are cancelled.

`strategy.oca.reduce <https://www.tradingview.com/pine-script-reference/v4/#var_strategy{dot}oca{dot}reduce>`__
   This group type allows multiple orders
   within the group to be filled. As one of the orders within the group
   starts to be filled, the size of other orders is reduced by the
   filled contracts amount. It is very useful for the exit strategies.
   Once the price touches your take-profit order and it is being filled,
   the stop-loss is not cancelled but its amount is reduced by the
   filled contracts amount, thus protecting the rest of the open
   position.

`strategy.oca.none <https://www.tradingview.com/pine-script-reference/v4/#var_strategy{dot}oca{dot}none>`__
   The order is placed outside of the group
   (default value for the ``strategy.order`` and ``strategy.entry`` functions).

Every group has its own unique id (the same way as the orders have). If
two groups have the same id, but different type, they will be considered a
different groups. Example::

    //@version=4
    strategy("My Script")
    if year > 2014 and year < 2016
        strategy.entry("Buy", strategy.long, oca_name="My oca", oca_type=strategy.oca.reduce)
        strategy.exit("FromBy", "Buy", profit=100, loss=200, oca_name="My oca")
        strategy.entry("Sell", strategy.short, oca_name="My oca", oca_type=strategy.oca.cancel)
        strategy.order("Order", strategy.short, oca_name="My oca", oca_type=strategy.oca.none)

"Buy" and "Sell" will be placed in different groups as their type is
different. "Order" will be outside of any group as its type is set to
``strategy.oca.none``. Moreover, "Buy" will be placed in the exit group
as exits are always placed in the ``strategy.oca.reduce_size`` type
group.

Risk management
---------------

It is not easy to create a universal profitable strategy. Usually,
strategies are created for certain market patterns and can produce
uncontrollable losses when applied to other data. Therefore stopping
auto trading in time should things go bad is a serious issue. There is a
special group of strategy commands to manage risks. They all start with
the ``strategy.risk.`` prefix.

You can combine any number of risks in any combination within one
strategy. Every risk category command is calculated at every tick as
well as at every order execution event regardless of the
``calc_on_order_fills`` strategy setting. There is no way to disable
any risk rule at runtime from script. Regardless of where in the script
the risk rule is located it will always be applied unless the line with
the rule is deleted and the script is recompiled.

If on the next calculation any of the rules is triggered, no orders will
be sent. Therefore if a strategy has several rules of the same type with
different parameters, it will stop calculating when the rule with the
most strict parameters is triggered. When a strategy is stopped all
unexecuted orders are cancelled and then a market order is sent to close
the position if it is not flat.

Furthermore, it is worth remembering that when using resolutions higher
than 1 day, the whole bar is considered to be 1 day for the rules
starting with prefix ``strategy.risk.max_intraday_``.

Example (MSFT, 1)::

    //@version=4
    strategy("multi risk demo", overlay=true, pyramiding=10, calc_on_order_fills = true)
    if year > 2014
        strategy.entry("LE", strategy.long)
    strategy.risk.max_intraday_filled_orders(5)
    strategy.risk.max_intraday_filled_orders(2)

The position will be closed and trading will be stopped until the end of
every trading session after two orders are executed within this session
as the second rule is triggered earlier and is valid until the end of
the trading session.

One should remember that the ``strategy.risk.allow_entry_in`` rule is
applied to entries only so it will be possible to enter in a trade using
the ``strategy.order`` command as this command is not an entry command
per se. Moreover, when the ``strategy.risk.allow_entry_in`` rule is
active, entries in a "prohibited trade" become exits instead of reverse
trades.

Example (MSFT, 1D)::

    //@version=4
    strategy("allow_entry_in demo", overlay=true)
    if year > 2014
        strategy.entry("LE", strategy.long, when=strategy.position_size <= 0)
        strategy.entry("SE", strategy.short, when=strategy.position_size > 0)
    strategy.risk.allow_entry_in(strategy.direction.long)

As short entries are prohibited by the risk rules, instead of reverse
trades long exit trades will be made.

Currency
--------

TradingView strategies can operate in a currency that is different from the
instrument currency. *Net Profit* and *Open Profit* are recalculated in the
account currency. Account currency is set in the strategy properties ---
the *Base Currency* drop-down list or in the script via the
``strategy(..., currency=currency.*)`` parameter. At the same time,
performance report values are calculated in the selected currency.

Trade profit (open or closed) is calculated based on the profit in the
instrument currency multiplied by the cross-rate on the *close* of the
trading day previous to the bar where the strategy is calculated.

Example: we trade EURUSD, D and have selected ``currency.EUR`` as the strategy
currency. Our strategy buys and exits the position using 1 point
profit target or stop loss.

::

    //@version=4
    strategy("Currency test", currency=currency.EUR)
    if year > 2014
        strategy.entry("LE", true, 1000)
        strategy.exit("LX", "LE", profit=1, loss=1)
    profit = strategy.netprofit
    plot(abs((profit - profit[1])*100), "1 point profit", color=color.blue, linewidth=2)
    plot(1 / close[1], "prev usdeur", color=color.red)

After adding this strategy to the chart we can see that the plot lines
are matching. This demonstrates that the rate to calculate the profit
for every trade was based on the *close* of the previous day.

When trading on intra-day resolutions the cross-rate on the close of the
trading day previous to the bar where the strategy is calculated will be
used and it will not be changed during whole trading session.

When trading on resolutions higher than 1 day the cross-rate on the
close of the trading day previous to the close of the bar where the
strategy is calculated will be used. Let's say we trade on a weekly
chart, then the cross rate on Thursday's session close will always be
used to calculate the profits.

In real-time the yesterday's session close rate is used.
