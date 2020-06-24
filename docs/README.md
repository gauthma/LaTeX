LaTeX, made simple (or at least, simpler...) 
===

Short intro
---

In my interactions with LaTeX, I use a set of templates (some of which have an accompanying preamble in the `includes/` folder), together with a script for compilation, `CompileTeX.sh`, which the `setup.sh` script will tailor to the specific template chosen. In fact, usage is as simple as:

```bash
$ git clone https://github.com/notnotrandom/LaTeX.git your_document_dir
$ cd your_document_dir
$ sh setup.sh [bare, cv, essay, llncs, presentation, report, standalone]
```

where `your_document_dir` should be the name of the (new) folder which will contain your LaTeX project. PDF samples of the templates can be seen in the `build/` directory. Sounds simple, right?

Well, it gets even better. In the last command (`sh setup.sh ...`), if you tab-complete (as the argument has the same name of the `\*.tex` template file, minus extension), either the final dot or the whole extension will also be "completed"; this is ok, the script will filter it (i.e. work correctly even with the ending dot and/or extension). So just type the first characters of the name of the template you want, hit <Tab>, and the setup script will take care of the rest.

Speaking of which, the `setup.sh` script will also patch `CompileTeX.sh`---running this latter script is how you compile the templates---and set all the required options for the chosen template (see XXX for further details about these options). It will also **remove the .git folder**, in addition to any unneeded files, depending on the value of its argument (i.e. the chosen template). E.g. if argument is `cv`, then it will remove `report.*`, `essay.*`, etc.

And to top it all, if you are working on a large document, and just `\including` the specific part you are writing, then `CompileTeX.sh` can also be configured to build *two* copies: one abridged, which is supposed to build quickly, and another, *unabridged* one (more on this below), comprising the full document. It will take longer to compile, but it will also leave you with a handy reference copy, should you need to check something that is not in the part you are currently writing.

So all that is left is to do work with LaTeX skeletons provided, compile using `CompileTeX.sh`, and enjoy profit!! If you're interested, read on!

The templates
---

These are the templates I use for most of (there are PDF examples for each in the `build/` directory):

- `bare.tex`: A very simple template, that I use for what one might dub "quick notes".

- `cv.tex`: The template I use for my Curriculum Vitæ.

- `essay.tex`: Writing is often a good way to vent complaints. I write them with this template and then dump them on my website. `\input`s preamble `includes/essay_preamble.tex`.

- `llncs.tex`: Springer's template for writing papers, with a few tweaks of my own (for more on these, see below section "Further Reading"). `\input`s preamble `includes/llncs_preamble.tex`.

- `presentation.tex`: This uses the `beamer` class, tweaked to my liking. Because in what slide making (and presentation giving) is concerned, the simpler the better. `\input`s preamble `includes/presentation_preamble.tex`.

- `report.tex`: I use this template as a sort of "offline wiki". For notes about research. `\input`s preamble `includes/report_preamble.tex`.

- `standalone.tex`: This I use when I need to try out some sketch, in `TikZ` or `xy-pic`, or something like that. Instead of experimenting in the document where I need to place the picture, I try it out in this standalone template. If nothing else, it compiles a lot faster! The PDF produced will be a "full-scale" picture. To include it say, on a presentation, do `\centering{\graphicbox{standalone}}`.

**Note:** the files in the `includes/` directory are files that are supposed to `\input`ed into another file, and *not* compiled on their own.

The example *LaTeX* files are processed using `XeLaTeX`, except for `cv`, which uses `LuaLaTeX`, to simplify using pretty fonts, and `llncs` which requires `PdfLaTeX`---but `setup.sh` takes care of this for you!

For the simpler types---`bare`, `cv`, and `standalone`---there is much simpler compile script, `CompileTeX.bare.minimum.sh`, which `setup.sh` will, for the mentioned templates, rename to `CompileTeX.sh`, that just does a simple compile run---which is all that is required.

Of the non-simple templates (plus `cv`), they all use a... *sizable* number of packages. However, all of these should be available in the TeXLive package (in Archlinux, at least, they are). If such is not the case, the reader can always install them on a local TeX tree. Also, I use a custom font, `Charis SIL`, which requires manual installation (see below). If you do *not* wish to use them, just comment out the lines in the preamble concerning the `fontspec` package, and any related lines (that should be just above, or just below).

Fonts
---

sdf

Unabridged copy
---

When reading PDFs in front of a computer screen, it is exceedingly useful to have two copies of the document being read. In this way, one can quickly cross-reference different parts of the document---and this is all the more useful, the larger the document happens to be. With LaTeX, however, there is an extra nuance: the larger the document, the longer it will take **to compile**. So here's how I tackle the problem.

For the not so simple types, the "non-bare" `CompileTeX.sh` script can do two kinds of builds: a "regular" build, and an "unabridged" build. The idea is that if the document is large, it can be divided into several partial documents, which are then `\include`d in the main file. This makes it possible to build only a part of the document, using `\includeonly`. `CompileTeX.sh` will then also produce an unabridged copy, as if there was no `\includeonly`. This is done by copying the main `.tex`file into a new file called `Unabridged.tex`, and inserting in this latter file's preamble the line:

~~~ {.tex .numberLines}
\let\include\input
~~~

This is done because `\include` always starts a new page, as it is supposed to be primarily used with chapters (which usually start in a new page). But, as this is not the case with `\input`, with the above `\let` we can include, say, `\section`s---and while the regular copy will, in the case of `\section`s, have extraneous `\newpage`s, the unabridged one will not.

**Note:** if `\include`'ng sections of a document with chapters, the chapter declarations **must be in the mainfile**. Otherwise the numbering of the sections will change; see below.

Anyway, `Unabridged.tex` is then compiled into a different directory---so that the auxiliary files of both versions don't mingle. But you don't have to worry about this: there will be a symlink in the root folder, named `Unabridged.pdf`, and pointing to the unabridged PDF document proper.

There is an important catch, however: when compiling a document with `include`'s, the compiler will generate some auxiliary files per `\include` (stored in the build directory). This is used to keep references and chapter/section numbers correct, when compiling a reduced version with `\includeonly`. If those auxiliary files are not there---e.g. after using the `clean` options to clean the build dir---compiling a mainfile with an `\includeonly` will yield an error. This is the reason for the `rebuild_build_files` option to the compile script. I detail all those options below.

By default, only the `report` type has enabled the building of an unabridged copy. For the other non-simple types, set variable `do_unabridged` to `true` in `CompileTeX.sh` (see below), and then use the `clean` option to setup the build directory for the unabridged copy.

LaTeX compiling
---

Compiling LaTeX files is not a simple matter. Here I will just describe the variables you can set in, and the command line options of, the script `CompileTeX.sh` (obviously, the non-bare version). First, the variables. We have already encountered `do_unabridged` (see above). There are also:

- `do_bib`: if `true` (the default), when doing a big build (see below), also build the bibliography.

- `do_idx`: if `true` (the default is `false`), when doing a big build, also build the index.

- `folders_to_be_rsyncd`: required if you store `\include`d `.tex` files in custom subdirectories. See the note on the structure of the build directory, below.

- `tmp_build_dir`: used for rebuilding auxiliary files; see option `rebuild_build_files` below. Ideally this should be a folder in a RAM-based `tmpfs` filesystem. In Archlinux, one such filesystem is mounted at `/run/user/$UID/` (that variable should contain your user id; usually starts at 1000).

There exists a `small_build()` function, which just runs the compiler once; and a `big_build()` function, which compile once, builds bibliography, etc., if set, and then compiles three more times. Both functions also do the same actions to the unabridged copy, if there exists one. See the comments in `CompileTeX.sh` for more details.

So `do_bib` can be used---if set to `false`---to cause the script to ignore any `\cite` or `\nocite` commands, and never run the bibliography command. It is set to `true` by default. Similarly, use the variable `do_idx` to enable or disable building the index.

Next, the command line arguments to `CompileTeX.sh`:

- no argument: run `small_build()`;

- `big`: A full LaTeX build run, i.e. `big_build()`.

- `clean`: removes everything in the build directories. And rebuilds its structure. By default this means create a link, inside the build directory, to the bibliography file  (this is always done, regardless of the value of `got_bib`). However, more actions may be required; see the remark on the structure of the build directory, below.

- `debug`: run `small_build()`, but *with* debug output. 

- `final`: `clean`s everything up, and them makes a `full` build. If you need the final PDF document to have a different name, then you can use the `endname` variable, which the last command in this function sets as its name;

- `get_compiler_pid`: in my `vim` setup, I have a map that builds the `LaTeX` command on writing the `.tex` file (see [myvim](https://github.com/gauthma/myvim)); it requires the pid of the compiler process to see if there is already a LaTeX compilation process going on. If you don't use `vim`, just ignore this.

- `killall_tex`: used to kill a running compile process (only used from within `vim`); if you don't use it, it's safe to ignore.

- `rebuild_build_files`: reconstructs the auxiliary files stored in both (regular and unabridged) build dirs.

- `symlinks`: reconstructs the symlinks needed in build directory(ies);

- `u2r`: replaces the regular, possibly abridged PDF file, with its unabridged counterpart. This is useful when one wants to read, more than to write, the document. As I usually have both version open in the PDF viewer, and it auto-updates, doing this leaves me with two open copies of the full document, which makes reading all that much easier.

**Structure of the build directory.** If you split your input, say, by placing all chapters inside a `chapters/` folder, then that folder needs to exist inside the build directory. More generally, the same hierarchy of inclusion of input files needs to be replicated inside the build directory. To accomplishing this, list those folders in the `folders_to_be_rsyncd` array. E.g. if you have two folders with `.tex` files in them, say `chapters` and `images`, that line should look something like:

~~~ {.shell .numberLines}
folders_to_be_rsyncd=( "chapters" "images" )
~~~

Add to the list any folders where you have placed the `.tex` files---**EXCEPT** files in the `\includes/` directory, as these are supposed to be `\input`ed (and hence, cause no problem).

**IMPORTANT:** the source folder(s)---`chapters` and `images` in the above example---**MUST NOT** end with a forward slash (/), because that tells `rsync` to copy folder *contents*, rather than the folder itself---which is not what we want.

Further reading
---

For more details on the things I describe here, see <https://randomwalk.eu/notes/TeX-Trickery.pdf>.
