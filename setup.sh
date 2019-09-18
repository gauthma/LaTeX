#!/bin/bash

build_dir="build"
unabridged_dir="_UNABRIDGED"

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
Usage: $ sh $0 [report, cv, letter, llncs, presentation, standalone]

To call script pwd must be same as script location.

EOF
}

# full dir path of script
fullpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# current dir
curr_dir="$(pwd)"

# make sure that pwd and script location are the same.
if [ "$fullpath" != "$curr_dir" ]; then
	usage
	exit 1
fi

case "$doctype" in
	report)
		;;
	cv)
		;;
	letter)
		;;
	llncs)
		;;
	presentation)
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
  $(ls  report.* \
        cv.* \
        letter.* docs/letter_logo* \
        llncs.* \
        presentation.* \
        standalone.* \
  | grep -v $doctype)

  rm -f "${doctype}.pdf" # If this exists, it's a symlink (actual pdf is in build/).

  rm -f \
  $(ls  includes/inc_report_preamble.tex \
        includes/inc_llncs_preamble.tex \
        includes/inc_presentation_preamble.tex \
  | grep -v $doctype)

  rm -rf $(ls  build/* | grep -v "${doctype}.pdf")

  # Setup the Makefile (requires GNU sed)
  # Begin with setting what type of document we want (report, presentation, ...)
  sed -i "/^name=/c\name=\"$doctype\"" CompileTeX.sh

  # For some documents, special actions are required.
  if [[ "${doctype}" == "llncs" ]] ; then
    sed -i "/^texcmd=/c\texcmd=pdflatex" CompileTeX.sh
  elif [[ "${doctype}" == "presentation" ]]; then
    sed -i "/^texcmd=/c\texcmd=pdflatex" CompileTeX.sh
  elif [[ "${doctype}" == "report" ]] ; then
    mkdir "${unabridged_dir}"
    cp -r ${build_dir} ${unabridged_dir}
    ln -sr "${unabridged_dir}/${build_dir}/${doctype}.pdf" "Unabridged.pdf"
  fi

  # For the types that DON'T come with references, comment the got_bib line
  # in CompileTeX.sh and delete the sources file. Otherwise, symlink bib file to
  # build dir (bibtex command has to be run inside this dir).
  if [[ "${doctype}" != "report" && "${doctype}" != "llncs" && "${doctype}" != "presentation" ]] ; then
    sed -i "/^got_bib=true/c\got_bib=false" CompileTeX.sh
    rm sources.bib
  else
    ln -sr sources.bib "${build_dir}"/
  fi

  # standalone doesn't need inc_* files, which we can delete.
  if [[ "${doctype}" == "standalone" ]] ; then
    rm -rf includes/
  fi

  # The actual pdf is in the build directory; instead of moving it, we symlink
  # it up. The same must also be done for the unabridged file (cf. Mafefile).
  ln -sr "${build_dir}/${doctype}.pdf" .

  # Finally delete this script (no use for it after everything is set up).
  rm -- "$0"
fi
