#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# To silence a warning
export PNG_SKIP_SETJMP_CHECK=1

INITIALS="JB"
PPT_TEMPLATE="$HOME/Templates/ivey_ppt.pptx"
BIBLIOGRAPHY_PATH="$HOME/bibliography.bib"
CSL_PATH="$HOME/Templates/presentation.csl"
TARGET_DIR="$HOME/out"

DATE=$(date +%F)
DIRECTORY="$(readlink -f ${0%/*})"
PROJ="$(basename ${DIRECTORY})"
TARGET="${TARGET_DIR}/${PROJ}_${INITIALS}_${DATE}.pptx"

help () {
  echo "Usage: ./compile.sh [OPTION]"
  echo "Options:"
  echo "  -p, --ppt     Convert the output to PPT."
  echo "  --pdf     Convert the output to PDF."
}

OUTPUT_FORMAT=""

while (( "$#" )); do
  case "$1" in
    -h|--help)
      help
      exit 0
      ;;
    -p|--ppt)
      OUTPUT_FORMAT="ppt"
      ;;
    --pdf)
      OUTPUT_FORMAT="pdf"
      ;;
    *) 
      echo "Error: Invalid argument"
      help
      exit 1
      ;;
  esac
  shift
done

if [[ -z "${OUTPUT_FORMAT}" ]]; then
  help
  exit 0
fi

cd "${0%/*}"  

pandoc \
  --reference-doc ${PPT_TEMPLATE} \
  --citeproc --bibliography ${BIBLIOGRAPHY_PATH} \
  --csl ${CSL_PATH} \
  -f markdown+emoji+raw_html \
  --slide-level=2 \
  ./slides.md \
  -o ${TARGET}

if [[ ${OUTPUT_FORMAT} == "ppt" ]]; then
  xdg-open "$TARGET" &
elif [[ ${OUTPUT_FORMAT} == "pdf" ]]; then
  PDF_FILE="${TARGET%.*}.pdf"
  libreoffice --convert-to pdf --outdir ${TARGET_DIR} ${TARGET}
  xdg-open "$PDF_FILE" &
fi
