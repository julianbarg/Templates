#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

INITIALS="JB"
LETTER_TEMPLATE="$HOME/Templates/letter.docx"
TARGET_DIR="$HOME/out"

DATE=$(date +%F)

help () {
  echo "Usage: ./compile.sh [FILENAME] [OPTION]"
  echo "Options:"
  echo "  --pdf     Convert the output to PDF."
}

OUTPUT_PDF=false

while (( "$#" )); do
  case "$1" in
    -h|--help)
      help
      exit 0
      ;;
    --pdf)
      OUTPUT_PDF=true
      ;;
    *)
      LETTER=$1
      ;;
  esac
  shift
done

# Ensure that a filename was provided and that it exists
if [ -z "${LETTER:-}" ] || [ ! -f "${LETTER}" ]; then
  echo "Error: Missing or non-existing filename argument"
  help
  exit 1
fi

LETTER_NAME=$( basename ${LETTER}.md )
TARGET="${TARGET_DIR}/${LETTER_NAME}_${INITIALS}_${DATE}.docx"

# Check if language is German
if [[ $( yq '.language == "de"' dkb.md -f=extract ) == true ]]; then
  LETTER_TEMPLATE="$HOME/Templates/letter_de.docx"
fi

# Convert the file to docx format
pandoc \
  --reference-doc ${LETTER_TEMPLATE} \
  -f markdown+emoji+raw_html \
  ${LETTER} \
  -o ${TARGET}

# Open the target file in default application
# Optionally, convert the file to pdf format before opening
if [[ ${OUTPUT_PDF} == false ]]; then
  xdg-open "$TARGET" &
else
  PDF_FILE="${TARGET%.*}.pdf"
  libreoffice --convert-to pdf --outdir ${TARGET_DIR} ${TARGET}
  xdg-open "$PDF_FILE" &
fi
