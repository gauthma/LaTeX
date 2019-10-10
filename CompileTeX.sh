#!/bin/bash

# Much like targets in a Makefile, this scripts provides functions to do a
# simple build, a full build, etc, for a LaTeX project.

# $name is one of: report, presentation, letter, llncs, cv, or standalone.
name="report"

# The final name of the .pdf file (without extension). Defaults to original
# name with ".FINAL" appended. In my setup, works "out of the box" with spaces,
# foreign chars, ...
finalname="${name}.FINAL"

build_dir="build"
docs_dir="docs"
unabridged_dir="_UNABRIDGED"

texcmd="xelatex"
texcmdopts="-halt-on-error --interaction=batchmode --shell-escape --output-directory=${build_dir}"
debug_texcmdopts="--interaction=errorstopmode --shell-escape --output-directory=${build_dir}"
bibcmd="bibtex"

# IMPORTANT: to disable bibliography, set this to false.
got_bib=true

# Can be useful when showing bib entries in say, a presentation.
function bibliography() {
  if [[ "$got_bib" = true ]] ; then
    cd "${build_dir}" && pwd && ${bibcmd} ${name} && cd ..
  else
    echo "The \$got_bib var is set to false, so I assume there is no bibliography to build."
  fi
}

# Please do note that this WIPES OUT THE PDF!
# And the ENTIRE unabridged_dir!
function clean() {
  echo "rm -rf ${build_dir}/*"
  rm -rf "${build_dir}"/*
  if [[ "${name}" == "report" ]]; then
    echo "rm -rf ${unabridged_dir}/*"
    rm -rf "${unabridged_dir}"/*
  fi
  echo "ln -sr sources.bib ${build_dir}"
  ln -sr sources.bib ${build_dir}
}

# A normal (single) LaTeX compile run.
function debugbuild() {
  ${texcmd} ${debug_texcmdopts} ${name}
  return $?
}

function finalfullrun() {
  normalfullrun
  cp "${unabridged_dir}"/"${build_dir}"/"${name}.pdf" "${finalname}.pdf"
}

# A full LaTeX build run: run once, then run bib (if it is set), then run three
# more times (usually two a are enough, but in some thorny cases three are
# required, so...). If using bib is not set, just run twice.
function fullrun() {
  clean
  ${texcmd} ${texcmdopts} ${name}
  if [[ "$got_bib" = true ]] ; then
    cd "${build_dir}" && ${bibcmd} ${name} && cd ..
    ${texcmd} ${texcmdopts} ${name}
    ${texcmd} ${texcmdopts} ${name}
  fi
  ${texcmd} ${texcmdopts} ${name}
  return $?
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

# Do a normal run. If we are dealing with a report, also do a single run build
# on the unabridged copy.
#
# First do a simple run. Then, if it was successful, and if we are dealing with
# report, copy the files to $unabridged_dir. Lastly, do the normal run in the
# $unabridged_dir.
function normalbuild() {
  run # run() returns the $? of the LaTeX command. See Note (1).
  if [[ $? -ne 0 ]]; then
    echo "Compile of *.tex file was not successful!"
    exit 1
  fi

  # If run was successful, and we are dealing with report, then update
  # unabridged copy.
  if [[ "${name}" == "report" ]]; then
    update_unabridged_tex_files

    echo -e "\n************************************************************"
    echo -e "* Now continuing with unabridged (normal, non-full) build..."
    echo -e "************************************************************\n"

    cd "${unabridged_dir}" && run && cd ..
  fi
}

function normalfullrun() {
  fullrun # run() returns the $? of the LaTeX command. See Note (1).
  if [[ $? -ne 0 ]]; then
    echo "Compile of *.tex file was not successful!"
    exit 1
  fi

  # If run was successful (LaTeX compiler should halt on errors), and we are
  # dealing with report, then update unabridged copy.
  if [[ "${name}" == "report" ]]; then
    update_unabridged_tex_files

    echo -e "\n************************************************************"
    echo -e "* Now continuing with unabridged (normal, non-full) build..."
    echo -e "************************************************************\n"

    cd "${unabridged_dir}" && fullrun && cd ..
  fi
}

# A normal (single) LaTeX compile run.
function run() {
  ${texcmd} ${texcmdopts} ${name}
  return $?
}

# Copy all stuff (except $docs_dir and the $unabridged_dir itself) into
# $unabridged_dir, and comment all \includeonly lines, to produce an unabridged
# copy. After copying, remove Unabridged.pdf symlink inside $unabridged_dir, as
# it is not needed.
function update_unabridged_tex_files() {
  cp -r $(ls | grep -v "${unabridged_dir}\|${docs_dir}") "${unabridged_dir}"
  rm "${unabridged_dir}"/Unabridged.pdf
  sed -e '/^\s*\\includeonly/ s/^/% /' -i "${unabridged_dir}"/"${name}.tex"
}


# Check that we are in the dir containing the main file.
if ! [[ -f "${name}.tex" ]]; then
  echo "Could not find main file ${name}.tex. Exiting..."
  exit 1
fi

# If no arguments given, do a normal build;
# - argument is debug: do debug build;
# - argument is get_compiler_pid: run that function;
# - argument is killall_tex: run that function.
if [[ $# -eq 0 ]] ; then
  normalbuild
elif [[ $# -eq 1 && "$1" == "bib" ]] ; then
  bibliography
elif [[ $# -eq 1 && "$1" == "clean" ]] ; then
  clean
elif [[ $# -eq 1 && "$1" == "debug" ]] ; then
  debugbuild
elif [[ $# -eq 1 && "$1" == "final" ]] ; then
  finalfullrun
elif [[ $# -eq 1 && "$1" == "full" ]] ; then
  normalfullrun
elif [[ $# -eq 1 && "$1" == "get_compiler_pid" ]] ; then
  get_compiler_pid
elif [[ $# -eq 1 && "$1" == "killall_tex" ]] ; then
  killall_tex
fi

#####
# Notes:
# - (1) After an unsuccessful compilation, and after fixing the mistake that
#   caused it, a normal run, in batchmode with halt on errors, will still lead
#   to a natbib error. It goes away after doing another normal run. But perhaps
#   the best strategy is to do debug mode in case of errors...
