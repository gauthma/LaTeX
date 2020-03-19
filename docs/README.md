My LaTeX templates 
===

These are the templates I use for most of my interactions with LaTeX. The example *LaTeX* files are processed using *XeLaTeX*, except for `cv`, which uses *LuaLaTeX*, to simplify usign pretty fonts.

Bear in mind that PDF is a [vector format][2], so including raster images might lead to poor results. You can ameliorate the problem by trial and error, tweaking scale factors, image width, etc.

All of these templates depend on a... *sizable* number of packages. However, all of these should be available in the TeXLive package (in Archlinux, at least, they are). If such is not the case, the reader can always install them on a local TeX tree (see the [TeX Trickery](#tex-trickery) section).

Usage 
---

In the first command below, `your_document_dir` must not exist; it should be the name of the new folder which will contain your document.

```bash
$ git clone https://github.com/gauthma/LaTeX.git your_document_dir
$ cd your_document_dir
$ sh setup.sh [bare, cv, essay, llncs, presentation, report, standalone]
```

In the last command, if you tab-complete (as the argument has the same name of the `\*.tex` file, minus extension), either the final dot or the whole extension will also be "completed"; this is ok, the script will filter it (i.e. work correctly even with the ending dot and/or extension).

The `setup.sh` script will patch `CompileTeX.sh` and set `name` to the *main file*'s name. It will also **remove the .git folder**, in addition to any unneeded files, depending on the value of its argument. E.g. if argument is `cv`, then it will remove `report.*`, `essay.*`, etc.

**Warning**: the script requires **GNU sed** to edit the `CompileTeX.sh`; if you don't have it, then comment that line and edit the `CompileTeX.sh` manually.

Do work with LaTeX skeletons provided, compile using adequate `CompileTeX.sh` target and enjoy profit!! `CompileTeX.sh` offers the following options:

- `no argument`: run `LaTeX` compiling command once, without debug output. 

- `bib`: check the document for `\cite` commands. If there are any, then build the bibliography, and then do two normal `LaTeX` compile runs.

- `debug`: run `LaTeX` compiling command once, *with* debug output. 

- `full`: run `LaTeX` command, then run compile script with `bib` option (see above), then run `LaTeX` command once more. This is to put properly all references, TOC, etc.

- `final`: `clean`s everything up, and them makes a `full` build. If you need the final PDF document to have a different name, then you can use the `endname` variable, which the last command in this function sets as its name.

- `clean`: removes everything in the `build/` directory.

- `get_compiler_pid`: used in the `vim` code that builds the `LaTeX` command on writing the `.tex` file (see [myvim](https://github.com/gauthma/myvim)).

- `killall_tex`: used to kill a running compile process (only used from within `vim`).

**NOTA BENE:** for the `report` class, both normal (no argument) and `full` compiling also trigger the compilation of the **unabridged copy**; see below.

The files in the `includes/` directory are files that are supposed to be *included* in another file, and *not* compiled on their own. Next follows a brief description of available types.

### Bare

For simple notes; it consists of the article class, with nothing other than a numberless section.

### CV

The template on which my CV is based.

### llncs

Like an article, using Springer's `llncs` style (including bibliography), which is assumed installed. Useful because it is designed to run with `pdflatex` and `bibtex`, which is what is expected when submitting papers to conferences or journals (you usually have to submit the `.tex` sources and check the PDF that the submission site generates)---and they almost always assume those sources compile with `pdflatex`.

If you think the bibliography style looks ugly with some sentences that don't end up a dot (I do), you can add that dot, like so: in the style file, by default `splncs03.bst`, look for this piece of code:

~~~ {.text .numberLines}
FUNCTION {fin.entry}
{ duplicate$ empty$
    'pop$
    'write$
  if$
  newline$
}
~~~

Replace it with the below code, recompile your (Bib/La)TeX, and now you should have proper(ly ended) sentences in your bibliography.

~~~ {.text .numberLines}
FUNCTION {fin.entry}
{
  add.period$
  duplicate$ empty$
    'pop$
    'write$
  if$
  newline$
}
~~~

### Presentation

This skeleton (`presentation.tex`) depends on the `beamer` class (it should be a part of `TeX-live`). Also, when displaying presentations, bold is often more emphasizing than italics. Thus, the `\emph` command is redefined to put the text in bold; for italics there is the `\iemph` command.

### Report

For my longer notes, typically about some subject I am studying. As this can get rather large, there are two copies: one is the working copy, which might contain only some sections and/or chapters, and an unabridged copy, kept in a separated folder, by default named `_UNABRIDGED`. Whenever the working copy is compiled, so is the unabridged one---but if compiling on the command line, a big warning is given, and the process goes to background (and output is suppressed)---so that you can ignore the rest of the compilation and get back to work on your document. If compiling the working document fails, the unabridged copy is not built, as there is no point in doing so.

### Standalone

I use this as a playground for graphics packages, like `xy` or `TikZ`. The PDF produced will be a "full-scale" picture. To include it say, on a presentation, do `\centering{\graphicbox{figures/standalone}}`.

Tweakings
---

### The xcolor package

The `documentclass` line contains one option, `dvipsnames*`, that belongs to the `xcolor` package, but setting it only when loading `xcolor` might cause conflicts with other packages that also automagically load that package (namely `tikz`). Having that option given to `documentclass` avoids the possibility of any such conflict. (What this particular option does, incidently, is to load a set colours larger then the basic set, which contains the colour MidnightBlue, used for hyperrefs. The starred version loads colour on demand, i.e. required a `\providecolors` command.)

ArchLinux (AL) packages 
---

The Charis SIL font can be found in an AUR package, but seems not be working. So for now the best approach seems to be to get the font's sources from [here](http://software.sil.org/charis/download/) and install them as described in the [TeX Trickery](#tex-trickery) section.

LaTeX Trickery
---

```tex
\usepackage[bitstream-charter]{mathdesign}
\DeclareSymbolFont{usualmathcal}{OMS}{cmsy}{m}{n}
\DeclareSymbolFontAlphabet{\mathcal}{usualmathcal} 
```

The last two lines are to use the default `mathcal` font, instead of the one with `bitstream-charter`, which is [harder to read][1].

TeX Trickery
---

For installing custom fonts, styles, etc., the easiest way is to replicate in your home directory the TeX Directory Structure (details [here][3] and [here][4]). The first thing to do is to discover where is your TeX home:

```bash
$ kpsewhich -var-value=TEXMFHOME
```

In my case it is in `/home/user/.texmf`[^1]. Create that folder if it does not exist. The exact location of things depends on what that thing is concretely (fonts, styles, bib styles, etc.). For our purposes, the projector class goes in `/home/user/.texmf/tex/latex/` and the Charis SIL font (which consist of a bunch of `\*.ttf` files) goes in `/home/user/.texmf/fonts/truetype/` (create the sub-folders as needed).

`XeLaTeX` has a peculiarity regarding fonts, however: if installed per user, it expects them to be in the `~/.fonts` directory. Simple solution, though, just create a sym link:

~~~ bash
ln -s ~/.texmf/fonts ~/.fonts
~~~

More generally, the first thing to do, to discover where whatever you want to install should be installed, is using a tool named `kpsewhich`, which should get installed when you install LaTeX. It can be used to do a lot of things (`$ kpsewhich --help`), but the one we’re interested in here, location of styles, uses the `--show-path NAME` option. The list of allowed names is part of the output of the `--help-formats` option. So for instance, to discover where to place BiBTeX style files (`*.bst`), run:

~~~ bash
kpsewhich --show-path bst
~~~

This will output a list of locations where BiBTeX style files are searched for. So if you have a file called `mystyle.bst`, create a folder named "mystyle" in the appropriate location (I use `/home/user/.texmf/bibtex/bst/`), and put `mystyle.bst` inside the folder you just created. Then run `$ texhash .` (don't forget the dot!) from the "appropriate location" folder you used. And you're done!

----

[^1]: The default for me was `/home/user/texmf`. But if you don't want yet another directory littering your \$HOME, you can change it like described [here][6]. In my case it amounted to (replace `~/.texmf` with whatever location you like):

```bash
$ mv ~/texmf ~/.texmf
$ mkdir -p ~/.texmf/web2c
$ cp /usr/share/texmf-dist/web2c/texmf.cnf .texmf/web2c/
# change the TEXMFHOME line to look like this: "TEXMFHOME = ~/.texmf", 
$ vim .texmf/web2c/texmf.cnf
$ echo -e "TEXMFCNF=$HOME/.texmf/web2c\nexport TEXMFCNF" >> ~/.bashrc
$ source ~/.bashrc
```

[1]: http://www.latex-community.org/forum/viewtopic.php?f=48&t=6989   
[2]: http://www.youthedesigner.com/2012/08/12/how-to-explain-raster-vs-vector-to-your-clients/   
[3]: http://en.wikipedia.org/wiki/TeX_Directory_Structure  
[4]: http://tex.stackexchange.com/questions/1137/where-do-i-place-my-own-sty-files-to-make-them-available-to-all-my-tex-files  
[6]: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=privinst
