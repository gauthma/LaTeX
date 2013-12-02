My LaTeX templates 
===

The example *LaTeX* files are processed using *LuaTeX.*.

The example article file include code for using images. Bear in mind that PDF
is a vector format [2], so including raster images might lead to poor results.
You can ameliorate the problem by trial and error, tweaking scale factors,
image width, etc. 

Usage 
---

```bash
$ mkdir article_dir
$ cd article_dir
$ git clone https://github.com/gauthma/LaTeX.git .
$ rm -rf .git()
```

Do work with LaTeX skeletons provided, and enjoy profit!!

Article: 
---

### One vs. two columns  

The **article_skel.tex** file contains two comments that start with
XXX. One is before the two `\documentclass` lines, and another is
before the `\usepackage[...]{geometry}` lines. The first line of
each pair of lines is to produce an article with *one* column; and
the second of each set is to produce an article with *two* columns.
Comment and uncomment accordingly.

### The *microtype* package

The last line in the code for fonts loads the *microtype* package
(commented by default). This package improves the way spacing is
computed, which usually results in an improved layout. However, it
slows down, very noticeably, the compile time; which is why it is
recommended to use (uncomment) it only when producing the final
version.

The rationale is that for just one column, we use a 12pt font, and
3cm lateral margins. For two columns, 10pt and 1.5 respectively.

### The xcolor package

The *documentclass* line contains two options (usenames and
dvipsnames) that belong to the *xcolor* package, but setting those
options only when loading it might cause conflicts with other
packages that also automagically load *xcolor* (namely *tikz*).
Having those options given to *documentclass* avoids the possibility
of any such conflict.

ArchLinux (AL) packages 
---

The __endnotes__ package can be found in the AL package:
*texlive-latexextra*. The Charis SIL font can be found in an AUR
package, but seems not be working. So for now the best approach
seems to be to get the font's sources from
[here](http://scripts.sil.org/cms/scripts/page.php?item_id=CharisSIL_download#b3a62bff)
and install them like this:

1. $ kpsewhich --show-path .ttf 
2. Choose one of the locations (in my case
	 ~/.texlive/texmf-var/fonts/truetype/ and put the *.ttf files in
	 there.
3. cd to that location and run $ texhash . -- the dot is part of the
	 command!

LaTeX Hacks 
---

\usepackage[bitstream-charter]{mathdesign}
\DeclareSymbolFont{usualmathcal}{OMS}{cmsy}{m}{n}
\DeclareSymbolFontAlphabet{\mathcal}{usualmathcal}

The last two lines are to use the default mathcal font, instead of the one with 
bitstream-charter, which is harder to read [1].

[1] - http://www.latex-community.org/forum/viewtopic.php?f=48&t=6989
[2] - http://www.youthedesigner.com/2012/08/12/how-to-explain-raster-vs-vector-to-your-clients/
