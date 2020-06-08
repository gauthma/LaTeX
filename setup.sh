#!/bin/bash

build_dir="build"
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
Usage: $ sh $0 [report, cv, essay, llncs, presentation, standalone]

To call script pwd must be same as script location.

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

  rm -f "${doctype}.pdf" # If this exists, it's a symlink (actual pdf is in build/).

  rm -f \
  $(ls  includes/essay_preamble.tex \
        includes/llncs_preamble.tex \
        includes/presentation_preamble.tex \
        includes/report_preamble.tex \
  | grep -v $doctype)

  rm -rf $(ls  build/* | grep -v "${doctype}.pdf")

# The actual pdf is in the build directory; instead of moving it, we symlink it
# up.
  ln -sr "${build_dir}/${doctype}.pdf" .

# Setup CompileTeX.sh (requires GNU sed) Begin with setting what type of
# document we want (report, presentation, ...)
  sed -i "/^name=/c\name=\"$doctype\"" CompileTeX.sh

# For some documents, special actions are required.
  if [[ "${doctype}" == "cv" ]] ; then
    sed -i "/^texcmd=/c\texcmd=\"lualatex\"" CompileTeX.sh
  elif [[ "${doctype}" == "llncs" || "${doctype}" == "bare" ]] ; then
    sed -i "/^texcmd=/c\texcmd=\"pdflatex\"" CompileTeX.sh
  elif [[ "${doctype}" == "report" ]] ; then
# If document type is report, then first set $got_unabridged variable to true.
    sed -i "/^got_unabridged=\"false\"/c\got_unabridged=\"true\"" CompileTeX.sh

# Next set up the directory where we will build the unabridged copy.
    mkdir "${build_dir_unabridged}"

    cp "${build_dir}/${doctype}.pdf" "${build_dir_unabridged}/${name_unabridged}.pdf"
    ln -sr "${build_dir_unabridged}/${name_unabridged}.pdf" "Unabridged.pdf"

    ln -sr "sources.bib" "${build_dir_unabridged}"/
  fi

# For the types that DON'T happen to a) have no includes, we delete the include
# folder); and b) do not require SyncTeX, we remove it.
#
# Otherwise, symlink bib file to build dir (bibtex command has to be run inside
# this dir).
  if [[ "${doctype}" != "essay" && "${doctype}" != "llncs" \
    && "${doctype}" != "presentation" && "${doctype}" != "report" ]] ; then

    rm -rf includes/

# Remove the --synctex=1 option from $texcmdopts variable. And delete all lines
# that dealt with .synctex.gz files (usually symlinks from the buildir to the
# top dir).
    sed -i "/^texcmdopts=\"/ s/ --synctex=1\"$/\"/" CompileTeX.sh
    sed -i "/\.synctex\./d" CompileTeX.sh
  fi

# The compiler need to find the sources file in the build dir, so symlink.
  ln -sr sources.bib "${build_dir}"/

# Finally delete this script (no use for it after everything is set up).
  rm -- "$0"
fi
