Custom OHLC bars and candles
============================

.. contents:: :local:
    :depth: 2

You may create your own custom *bars* and *candles* in Pine scripts by using the
`plotbar <https://www.tradingview.com/pine-script-reference/v4/#fun_plotbar>`__
and `plotcandle <https://www.tradingview.com/pine-script-reference/v4/#fun_plotcandle>`__
annotation functions::

    //@version=4
    study("Example 1")
    plotbar(open, high, low, close)

.. image:: images/Custom_ohlc_bars_and_candles_1.png

*Example 1* simply replicates bars of the current symbol.
To color them green or red, we can use the following code::

    //@version=4
    study("Example 2")
    palette = close >= open ? color.lime : color.red
    plotbar(open, high, low, close, color=palette)

.. image:: images/Custom_ohlc_bars_and_candles_2.png

*Example 2* illustrates using the ``color`` argument, which can be given
constant values such as ``red``, ``lime``, ``"#FF9090"``, as well as expressions that
calculate colors conditionally at runtime (see the ``palette`` variable in the example above).

The ``plotcandle`` annotation function is similar to ``plotbar``, but it plots candles
instead of bars and has an optional argument: ``wickcolor``.

Both ``plotbar`` and ``plotcandle`` need four series as the arguments that will be
used for new bar/candle OHLC prices. If one of
the arguments for a bar has a ``na`` value, then the bar is not
plotted. Example::

    //@version=4
    study("Example 3")
    c = close > open ? na : close
    plotcandle(open, high, low, c)

.. image:: images/Custom_ohlc_bars_and_candles_3.png

You can build bars or candles using values other than the actual OHLC values.
For example you could calculate and plot *smoothed* candles using the following code::

    //@version=4
    study("Example 4")
    len = input(9)
    smooth(x) =>
        sma(x, len)
    o = smooth(open)
    h = smooth(high)
    l = smooth(low)
    c = smooth(close)
    plotcandle(o, h, l, c)

.. image:: images/Custom_ohlc_bars_and_candles_4.png

You may find it useful to plot OHLC values taken from a
higher timeframe. You can, for example, plot daily bars on a *60 minutes* chart::

    // NOTE: add this script on intraday chart
    //@version=4
    study("Example 5")
    higherRes = input("D", type=input.resolution)
    is_newbar(res) =>
        t = time(res)
        not na(t) and (na(t[1]) or t > t[1])
    o = security(syminfo.tickerid, higherRes, open)
    h = security(syminfo.tickerid, higherRes, high)
    l = security(syminfo.tickerid, higherRes, low)
    c = security(syminfo.tickerid, higherRes, close)
    plotbar(is_newbar(higherRes) ? o : na, h, l, c, color=c >= o ? color.lime : color.red)

.. image:: images/Custom_ohlc_bars_and_candles_5.png

The ``plotbar`` and ``plotcandle`` annotation functions also have a ``title`` argument, so users can distinguish them in
the *Style* tab of the *Settings* dialog box.
