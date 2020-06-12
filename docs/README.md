My LaTeX setup 
===

These are the templates I use for most of my interactions with LaTeX:

- `bare.tex`: A very simple template, that I use for what one might dub "quick notes".

- `cv.tex`: The template I use for my Curriculum Vitæ.

- `essay.tex`: Writing is often a good way to vent complaints. I write them with this template and then dump them on my website.

- `llncs.tex`: Springer's template for writing papers, with a few tweaks of my own.

- `presentation.tex`: This uses the `beamer` class, tweaked to my liking. Because in what slide making (and presentation giving) is concerned, the simpler the better.

- `report.tex`: I use this template as a sort of "offline wiki". For notes about research.

- `standalone.tex`: This I use when I need to try out some sketch, in `TikZ` or `xy-pic`, or something like that. Instead of experimenting in the document where I need to place the picture, I try it out in this standalone template. If nothing else, it compiles a lot faster!

The example *LaTeX* files are processed using `XeLaTeX`, except for `cv`, which uses `LuaLaTeX`, to simplify usign pretty fonts, and `llncs` which requires `PdfLaTeX`.

Bear in mind that PDF is a [vector format][2], so including raster images might lead to poor results. You can ameliorate the problem by trial and error, tweaking scale factors, image width, etc.

All of these templates depend on a... *sizable* number of packages. However, all of these should be available in the TeXLive package (in Archlinux, at least, they are). If such is not the case, the reader can always install them on a local TeX tree (see the [TeX Trickery](#tex-trickery) section).

Usage 
---

In the first command below, `your_document_dir` must not exist; it should be the name of the new folder which will contain your document.

```bash
$ git clone https://github.com/notnotrandom/LaTeX.git your_document_dir
$ cd your_document_dir
$ sh setup.sh [bare, cv, essay, llncs, presentation, report, standalone]
```

In the last command, if you tab-complete (as the argument has the same name of the `\*.tex` file, minus extension), either the final dot or the whole extension will also be "completed"; this is ok, the script will filter it (i.e. work correctly even with the ending dot and/or extension).

The `setup.sh` script will patch `CompileTeX.sh`---running this script is how you compile the templates---and set all the required options for the chosen template. It will also **remove the .git folder**, in addition to any unneeded files, depending on the value of its argument (i.e. the chosen template). E.g. if argument is `cv`, then it will remove `report.*`, `essay.*`, etc.

**Warning**: the script requires **GNU sed** to edit the `CompileTeX.sh`! If you don't have it, then comment that line and edit the `CompileTeX.sh` manually (check `setup.sh` to see where `sed` was used).

Do work with LaTeX skeletons provided, compile using adequate `CompileTeX.sh` target and enjoy profit!!

Unabridged copy
---

When reading PDFs in front of a computer screen, it is exceedingly useful to have two copies of the document being read. In this way, one can quickly cross-reference different parts of the document---and this is all the more useful, the larger the document happens to be. With LaTeX, however, there is an extra nuance: the larger the document, the **longer it will take** to compile. So here's how I tackle the problem.

First, for the simpler types---`bare`, `cv`, and `standalone`---there is `CompileTeX.bare.minimum.sh`, which `setup.sh` will rename to `CompileTeX.sh`, that just does a simple compile run. Here, there is nothing particularly complicated.

For the not so simple types (everything else), the `CompileTeX.sh` script will do two kinds of builds: a "regular" build, and an "unabridged" build. The idea is that if the document is large, it can be divided into several partial documents, which are then `\include`'d in the main file. This makes it possible to build only a part of the document, using `\includeonly`. `CompileTeX.sh` will then also produce an unabridged copy, as if there was no `\includeonly`. This is done by copying the main `.tex`file into a new file called `Unabridged.tex`, and inserting in this latter file's preamble the line:

~~~ {.tex .numberLines}
\let\include\input
~~~

This done because `\include` always starts in a page, because it is supposed to be primarily used with chapters (which usually starts in a new page). But, as this is not the case with `\input`, with the above `\let` we can include, say, `\section`'s, and while the regular copy will, in this case, have extraneous `\newpage`'s, the unabridged one, will not.

Anyway, `Unabridged.tex` is then compiled into a different directory---so that the auxiliary files of both versions don't mingle.

There is an important catch, however: when compiling a document with `include`'s, the compiler will generate one `.aux` file per `\include`. This is used to keep references and chapter/section numbers correct, when compiling a reduced version with `\includeonly`.

LaTeX compiling
---

Compiling LaTeX files is not a simple matter. Here I will just describe the command line options of the script `CompileTeX.sh`. Before that though, some remarks are in order.

Note: there exists a variable, `do_bib`, which can be used---set it to `false`---to cause the script to ignore any `\cite` or `\nocite` commands, and never run the bibliography command. It is set to `true` by default.

- no argument: run `LaTeX` compiling command once, without debug output. 

- `debug`: run `LaTeX` compiling command once, *with* debug output. 

- `big`: A full LaTeX build run: clean and run once, then run bib (if `got_bib` is `true`), then run three more times (usually two are enough, but in some thorny cases three are required, so...). If using bib is not set, just run three times.

- `final`: `clean`s everything up, and them makes a `full` build. If you need the final PDF document to have a different name, then you can use the `endname` variable, which the last command in this function sets as its name.

- `clean`: removes everything in the `build/` directory. And rebuilds its structure. By default this means create a link to the biliography file inside the the `build` directory (this is always done, regardless of the value of `got_bib`). However, more actions may be required; see the "TeX Trickeyy" section below.

- `get_compiler_pid`: used in the `vim` code that builds the `LaTeX` command on writing the `.tex` file (see [myvim](https://github.com/gauthma/myvim)).

- `killall_tex`: used to kill a running compile process (only used from within `vim`).

**NOTA BENE:** for the `report` class, both normal (no argument) and `full` compiling also trigger the compilation of the **unabridged copy**; see below.

The files in the `includes/` directory are files that are supposed to be *included* in another file, and *not* compiled on their own. Next follows a brief description of available types.
