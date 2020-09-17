#!/bin/bash

build_dir_regular="build"
build_dir_unabridged="build_UNABRIDGED"
name_unabridged="Unabridged"

doctype="$1"

# If the argument is actually a *.tex filename, then remove the extension to
# get the type. Else, if it ends with a dot, just remove that dot.
if [[ "$doctype" == *.tex ]] ; then
  doctype="${doctype%????}" # Removes the .tex extension.
elif [[ "$doctype" =~ .+\.$ ]] ; then
  doctype="${doctype%?}" 
fi

function usage()
{
	cat <<EOF
Usage: $ sh $0 [bare, cv, essay, llncs, presentation, report, standalone]

Script location must be same as script location.

EOF
}

# Full dir path of script.
fullpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# current dir
curr_dir="$(pwd)"

# make sure that pwd and script location are the same.
if [ "$fullpath" != "$curr_dir" ]; then
	usage
	exit 1
fi

case "$doctype" in
	bare)
		;;
	cv)
		;;
	essay)
		;;
	llncs)
		;;
	presentation)
		;;
	report)
		;;
	standalone)
		;;
	-h)
		usage
		exit 0
		;;
	*)
		if [[ -z $doctype ]]; then
			usage
			exit 0
		else
			echo "Unknown type $doctype"
			exit 1
		fi
esac

echo "WARNING! WARNING! WARNING!"
echo "You are about to DELETE .git folder, data and build files (and THIS SCRIPT)!!"
read -p "Are you sure you want to continue? [type uppercase y]" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Y]$ ]]; then
  rm -rf .git

  rm -f \
  $(ls  cv.* \
        bare.* \
        essay.* \
        llncs.* \
        presentation.* \
        report.* \
        standalone.* \
  | grep -v $doctype)

  rm -f "${doctype}.pdf" # If this exists, it's a symlink (actual pdf is in build dir).

  rm -f \
  $(ls  inputs/essay_preamble.tex \
        inputs/llncs_preamble.tex \
        inputs/presentation_preamble.tex \
        inputs/report_preamble.tex \
  | grep -v $doctype)

  rm -rf $(ls  build/* | grep -v "${doctype}.pdf")

# The actual pdf is in the build directory; instead of moving it, we symlink it
# up.
  ln -sr "${build_dir_regular}/${doctype}.pdf" .

# Use the simple build script for the simpler templates.
  if [[ "${doctype}" == "cv" || "${doctype}" == "bare" || "${doctype}" == "standalone" ]] ; then
    mv CompileTeX.minimum.sh CompileTeX.sh
    rm CompileTeX.medium.sh CompileTeX.reports.sh
  elif [[ "${doctype}" == "essay" || "${doctype}" == "llncs" || "${doctype}" == "presentation" ]] ; then
    mv CompileTeX.medium.sh CompileTeX.sh
    rm CompileTeX.minimum.sh CompileTeX.reports.sh
    rm comp*

# The compiler needs to find the sources file in the build dir, so symlink.
    ln -sr sources.bib "${build_dir_regular}"/
  else
    mv CompileTeX.reports.sh CompileTeX.sh
    rm CompileTeX.minimum.sh CompileTeX.medium.sh

    ln -sr "${build_dir_regular}/${doctype}.synctex.gz" .

# The compiler again needs the sources file in the build dir, so symlink.
    ln -sr sources.bib "${build_dir_regular}"/
  fi

# Setup CompileTeX.sh (requires GNU sed) Begin with setting what type of
# document we want (report, presentation, ...)
  sed -i "/^name=/c\name=\"$doctype\"" CompileTeX.sh

# For some documents, special actions are required.
  if [[ "${doctype}" == "cv" ]] ; then
    sed -i "/^texcmd=/c\texcmd=\"lualatex\"" CompileTeX.sh
  elif [[ "${doctype}" == "llncs" ]] ; then
    sed -i "/^texcmd=/c\texcmd=\"pdflatex\"" CompileTeX.sh
  elif [[ "${doctype}" == "report" ]] ; then
# If document type is report, then set up the directory where we will build the
# unabridged copy.
    mkdir "${build_dir_unabridged}"

    cp "${build_dir_regular}/${doctype}.pdf" "${build_dir_unabridged}/${name_unabridged}.pdf"
    ln -sr "${build_dir_unabridged}/${name_unabridged}.pdf" "Unabridged.pdf"

    ln -sr "${build_dir_unabridged}/${name_unabridged}.synctex.gz" .

    ln -sr "sources.bib" "${build_dir_unabridged}"/
  fi

# For the types that have no specific inputs, we delete the inputs/ folder.
#
# Otherwise, symlink bib file to build dir (bibtex command has to be run inside
# this dir).
  if [[ "${doctype}" != "essay" && "${doctype}" != "llncs" \
    && "${doctype}" != "presentation" && "${doctype}" != "report" ]] ; then

    rm -rf inputs/
  fi

# Finally delete this script (no use for it after everything is set up).
  rm -- "$0"
fi
