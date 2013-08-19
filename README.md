My LaTeX templates 
===

The example *LaTeX* files are processed using *LuaTeX.*.

The example article file include code for using images. Bear in mind that PDF
is a vector format [2], so including raster images might lead to poor results.
You can ameliorate the problem by trial and error, tweaking scale factors,
image width, etc. 

Article: one vs. two columns 
---

The **article_skel.tex** file contains two comments that start with
XXX. One is before the two `\documentclass` lines, and another is
before the `\usepackage[...]{geometry}` lines. The first line of
each pair of lines is to produce an article with *one* column; and
the second of each set is to produce an article with *two* columns.
Comment and uncomment accordingly.

The rationale is that for just one column, we use a 12pt font, and
3cm lateral margins. For two columns, 10pt and 1.5 respectively.

ArchLinux (AL) packages 
---

The __endnotes__ package can be found in the AL package:
*texlive-latexextra*.

LaTeX Hacks 
---

\usepackage[bitstream-charter]{mathdesign}
\DeclareSymbolFont{usualmathcal}{OMS}{cmsy}{m}{n}
\DeclareSymbolFontAlphabet{\mathcal}{usualmathcal}

The last two lines are to use the default mathcal font, instead of the one with 
bitstream-charter, which is harder to read [1].

[1] - http://www.latex-community.org/forum/viewtopic.php?f=48&t=6989
[2] - http://www.youthedesigner.com/2012/08/12/how-to-explain-raster-vs-vector-to-your-clients/
