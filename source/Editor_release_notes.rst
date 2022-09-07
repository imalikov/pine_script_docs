The new Pine Script™ Editor is here! 
This is a list of the **new** features added to the editor, and a few of the **changes** made.


New features
^^^^^^^^^^^^^

There are many new options and commands available using the new Command Palette. You can access this by either right-clicking in the editor itself or by pressing ``F1``.
You can either scroll through all of the new options or you can use keywords to use the new search function.

The new editor is now fully accessible on mobile devices! If your device doesn't support showing the Pine Script™ editor by default, then you can either
view the page in Desktop mode or you can access it by clicking on the detached editor link.

There is now full documentation for all built-in functions, and their parameters as well. 
This even works for exported `library <https://www.tradingview.com/pine-script-reference/v5/#fun_library>`__ functions as well as the 
functions and variables declared in the current script, provided that they use the ``//@function``, ``//@param``, and ``//@returns`` annotations.

A new Autocomplete feature has now been added which will provide a helpful popup to give you a list of possible keywords that will make writing 
Pine Script™ faster and easier. This will also display the full descriptions and examples for each keyword and it works with any custom functions and variables,
if they use the ``//@function``, ``//@param``, and ``//@returns`` annotations.

The editor can now provide real-time errors and warnings so you won't need to add the script to your chart to view any potential errors or warnings anymore. 
Lines of code that will produce an error are now underlined in red or in orange if they will produce a warning.

Lines of code that are indented or wrapped around are now able to be minimized by using the new Fold function ``(Ctrl + Shift + L)``. 
You can also create minimized sections of code by utilizing the new ``//#region`` and ``//#endregion`` annotations.

The Find ``(Ctrl + F)`` and Replace ``(Ctrl + H)`` functions have been completely overhauled to not only provide dynamic results as you type, 
but also allows you to find matching words easier. There are now many more options available such as finding matching words in a highlighted section or the entire script.

A new minimap has been added which will allow you to see a zoomed out version of your code. This is especially helpful with larger scripts, 
because it will show you error and warning highlighted lines of code as well as highlighting lines when you use the Find and Replace functions.

A color preview window has been added and will appear whenever you hover over a color function, hex value, or a built-in color. 
This will allow you to quickly and easily change any color on the fly.

The new editor will now store your code locally, so this means no more losing unsaved code with an accidental page refresh! 



Changes
^^^^^^^

``Ctrl + D`` no longer deletes a line of code and now adds the highlighted word to the next Find match.

``Ctrl + /`` no longer highlights multiple lines of code and now collapses all block comments.

``Ctrl + Backspace`` or ``Ctrl + Delete`` used to remove the word to the left and right respectively, but now there are no matching keyboard shortcuts in the new editor.

The multi-cursor feature that can be accessed on either editor by using ``Ctrl + Alt + (Up or Down)`` won't work correctly on lines that use a color swatch.