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
  rm -rf .gitignore

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


# Deal with inputs/ folder.
  if [[ "${doctype}" == "standalone"  ]] ; then
    rm -rf inputs/
  elif [[ "${doctype}" == "llncs" || "${doctype}" == "presentation" ]] ; then
    rm -f inputs/fonts.tex
  fi

  if [[ -f  "inputs/${doctype}_fonts.tex" ]] ; then
    mv "inputs/${doctype}_fonts.tex" "inputs/fonts.tex"
  fi
  if [[ -f  "inputs/${doctype}_preamble.tex" ]] ; then
    mv "inputs/${doctype}_preamble.tex" "inputs/preamble.tex"
  fi
  if [[ -f  "inputs/${doctype}_style.tex" ]] ; then
    mv "inputs/${doctype}_style.tex" "inputs/style.tex"
  fi

# Remove unneeded files from inputs/ folder.
  rm -f inputs/*_fonts.tex inputs/*_preamble.tex inputs/*_style.tex

# Done dealing with inputs/ folder. Now remove unneeded files from the build/
# dir.
  rm -rf $(ls  build/* | grep -v "${doctype}.pdf")

# Choose proper compilation script.
  if [[ "${doctype}" == "cv" || "${doctype}" == "bare" || \
     "${doctype}" == "presentation" || "${doctype}" == "standalone" ]] ; then
    mv compileTeX.minimum.sh CompileTeX.sh
  elif [[ "${doctype}" == "essay" || "${doctype}" == "llncs" ]] ; then
    mv compileTeX.medium.sh CompileTeX.sh
  else # Reports.
    mv compileTeX.reports.sh CompileTeX.sh
  fi

  rm compileTeX.*

# Setup compile script. Requires GNU sed.
  sed -i "/^name=/c\name=\"$doctype\"" CompileTeX.sh
# llncs requires pdflatex, not xelatex.
  if [[ "${doctype}" == "llncs" ]] ; then
    sed -i "/^texcmd=/c\texcmd=\"pdflatex\"" CompileTeX.sh
  fi

# The actual pdf is in the build directory; instead of moving it, we symlink it
# up.
  ln -sr "${build_dir_regular}/${doctype}.pdf" .

# Miscellaneous actions required for specific types.
  if [[ "${doctype}" == "cv" || "${doctype}" == "bare" || \
    "${doctype}" == "presentation" || "${doctype}" == "standalone" ]] ; then
    rm -rf sources.bib
  elif [[ "${doctype}" == "essay" || "${doctype}" == "llncs" || \
    "${doctype}" == "reports" ]] ; then
# The compiler needs to find the sources file in the build dir, so symlink.
# And the PDF viewer needs to find the .synctex file in the top dir, so also symlink.
    ln -sr "sources.bib" "${build_dir_regular}"/
    ln -sr "${build_dir_regular}/${doctype}.synctex.gz" .
  fi

# For reports, additional actions are required, namely set up the directory for
# unabridged copy.
  if [[ "${doctype}" == "report" ]] ; then

    mkdir "${build_dir_unabridged}"
    cp "${build_dir_regular}/${doctype}.pdf" "${build_dir_unabridged}/${name_unabridged}.pdf"

    ln -sr "${build_dir_unabridged}/${name_unabridged}.pdf" "Unabridged.pdf"
    ln -sr "${build_dir_unabridged}/${name_unabridged}.synctex.gz" .
    ln -sr "sources.bib" "${build_dir_unabridged}"/
  fi

# Finally delete the docs/ folder, and this script (no use for either of them
# after everything is set up).
  rm -rf docs
  rm -- "$0"
fi
