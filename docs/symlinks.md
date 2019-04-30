# Symlinks

In case you accidentally delete one or more of the symlinks required for this setup to work, here are the commands to re-create them (used in `setup.sh`). The final dot (`.`) is the folder where the `build` directory is.

~~~ {.shell .numberLines}
ln -sr build/"${doctype}.pdf" .
ln -sr build/"${doctype}.synctex.gz" .
~~~
