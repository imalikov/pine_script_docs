# Pine Script documentation

Official documentation of Pine Script language. You may read it (`TODO need URL`).
It's a replacement of [Pine Tutorial Wiki](https://www.tradingview.com/wiki/Pine_Script_Tutorial).

## How to build html docs
Follow these steps:

* Install [sphinx-doc](http://www.sphinx-doc.org/en/master/usage/installation.html)
* Execute `make syncpackages` (this would download the theme)
* Execute `make html`

Your docs will be in the `build/html` folder.

## Notes for writers

### Rules for capitalization in titles
* Capitalize the first word of the title
* Capitalize all proper nouns

### Filenames for *.rst files
Take a page title, replace all spaces with underscores (`_`), remove all punctuation (except dashes, `-`), add `.rst` extension.
For example such a content:
```
Expressions, declarations and statements
========================================
```
Should be saved on disk as `Expressions_declarations_and_statements.rst`.

### Automatic table of contents
Use reStructuredText directive `contents`. Place it after the title of a section, which table of contents you want.
For example:
```
Expressions, declarations and statements
========================================

.. contents:: :local:
    :depth: 2
```

### Quotation marks
Documentation uses American style which considers a double quotes are the default ones. Single quotes are used if nested in the double ones. For example: 
* Joe said, "Will you marry me?"
* Joe smiled and said, "Jenny said 'yes' when I asked her to marry me."

### Inline markup
* One asterisk: `*text*` for emphasis (italics),
* Two asterisks: `**text**` for strong emphasis (boldface), and
* Two backquotes: &#96;&#96;text&#96;&#96; for inline code samples.

### Special unicode characters

There is a set of macros in file [isonum.txt](http://docutils.sourceforge.net/docs/ref/rst/definitions.html).
For example for &rarr; (RIGHTWARDS ARROW) use `|rarr|` macro. 
For example:
```
..    include:: <isonum.txt>
Indicators |rarr| Built-ins
```
