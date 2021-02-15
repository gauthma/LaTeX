#! /bin/bash

# $name is one of: cv, bare, or standalone.
name="bare"

##### VARIABLES THAT THE USER CAN SET #####
# The final name of the .pdf file (without extension). Defaults to original
# name with ".FINAL" appended. In my setup, works "out of the box" with spaces,
# foreign chars, ...
finalname="${name}.FINAL"
##### END VARIABLES THAT THE USER CAN SET #####

# Build dir.
build_dir="build"

texcmd="xelatex"
texcmdopts="-halt-on-error --interaction=batchmode --shell-escape"
debug_texcmdopts="--interaction=errorstopmode --shell-escape --output-directory=${build_dir}"

function clean() {

  if [[ -d "$build_dir" ]]; then
    echo "Wiping contents of ${build_dir} (except PDF files)"
    cd "${build_dir}" && rm -rf $(ls | grep -v ".pdf") && cd ..
  else
    echo "Creating directory ${build_dir}"
    mkdir $build_dir
  fi

  # Rebuilding structure of build_dir. Begin with symlinks.
  symlinks_rebuild
}

# A normal LaTeX compile.
function compile() {
  ${texcmd} ${texcmdopts} --output-directory="$build_dir" "$1"
  if [[ $? -ne 0 ]]; then
    echo "Compile of ${name}.tex file was not successful!"
    exit 1
  fi
}

# A normal (single) LaTeX compile.
function debugbuild() {
  ${texcmd} ${debug_texcmdopts} ${name}
  return $?
}

function final_document() {
  # Just to be sure, compile twice, because things like page numbers require
  # it.
  compile "$name" && compile "$name"

  cp "${build_dir}"/"${name}.pdf" "${finalname}.pdf"
}

# Get the pid of the running $texcmd process (if any). This is needed to avoid
# starting (from within vim) a new compilation, if one is already running.
function get_compiler_pid() {
  pidof ${texcmd}
}

# Kill a running $texcmd process (useful when an error occurs, for example).
function killall_tex() {
  killall ${texcmd}
}

function symlinks_rebuild() {
  if [[ ! -d "$build_dir" ]]; then
    echo "Build dir does not exist! Run clean() to fix it."
    return 1
  fi

  rm -f "${name}.pdf"
  ln -sr "${build_dir}/${name}.pdf" .
}

#
# *** Main function ***
#
function main() {
# Check that we are in the dir containing the main file.
  if ! [[ -f "${name}.tex" ]]; then
    echo "Could not find main file ${name}.tex. Exiting..."
    exit 1
  fi

  # If no arguments given, do a normal build;
  # - argument is debug: do debug build;
  # - argument is get_compiler_pid: compile that function;
  # - argument is killall_tex: compile that function.
  if [[ $# -eq 0 ]] ; then
    compile "$name"
  elif [[ $# -eq 1 && "$1" == "clean" ]] ; then
    clean
  elif [[ $# -eq 1 && "$1" == "debug" ]] ; then
    debugbuild
  elif [[ $# -eq 1 && "$1" == "final" ]] ; then
    final_document
  elif [[ $# -eq 1 && "$1" == "get_compiler_pid" ]] ; then
    get_compiler_pid
  elif [[ $# -eq 1 && "$1" == "killall_tex" ]] ; then
    killall_tex
  elif [[ $# -eq 1 && "$1" == "symlinks" ]] ; then
    symlinks_rebuild
  else
    echo "Unknown option(s): $@"
    exit 1
  fi
}

main "$@"
