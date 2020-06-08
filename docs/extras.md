LaTeX extras 
===

Minted
---

To use the `minted` package, is troublesome because of the double build directories. The solution is the following. Load the package with this option: `outputdir=build`. This means that doing the main compile, the package will temporarily create the file `build/report.pyg`.

So far so good. The problem is that when doing the unabridged build, so far as `minted` knows, its ouput dir is still `build/`, so it will expect a file `build/Unabridged.pyg`. The solution is to add this line to the `compile()` method, *before invoking the compiler*:

~~~ {.tex .numberLines}
ln -srf "$build_dir_unabridged"/"$name_unabridged".pyg "$build_dir_regular"
~~~
