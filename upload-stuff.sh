#!/bin/bash
#
# upload-stuff.sh: Easily upload files to a SFTP server using scp(1).
#

set -euo pipefail

# Configuration:

DST_HOST="host.example.net"
DST_PATH="my/upload/directory/"
URL_PREFIX="https://example.net/my/uploaded/files/"

SHORT_RANDOM_LEN=4
ALL_RANDOM_LEN=16

# Read in local configuration file, if available:
CONFIG_FILE="${HOME}/.config/upload-stuff.conf"
if [[ -r "${CONFIG_FILE}" ]]; then
	. "${CONFIG_FILE}"
fi

# Initialization:

DO_COPY=1
DO_DRY_RUN=
DO_OPEN=
DO_RANDOM=

function Usage() {
	cat <<-EOF

	Usage: $0 [-C] [-o] [-R|-r] [-x] <file> [<file> [...]]

	 -C, --no-copy     Do not copy the URL into the clipboard.
	 -o, --open        Open each URL after uploading the file.
	 -R, --all-random  Generate an all-random file name but keep the extension.
	 -r, --random      Add a random suffix to the file name, before the extension.
	 -x, --dry-run     Do not upload the file(s), only show what would be done.
	     --help        Show this usage information and exit.

	EOF
}

# Parse command line:

while [[ $# -gt 0 ]]; do
	case "$1" in
	-C|--no-copy)
		DO_COPY=
		;;
	-o|--open)
		DO_OPEN=1
		;;
	-r|--random)
		DO_RANDOM=1
		;;
	-R|--all-random)
		DO_RANDOM=2
		;;
	-x|--dry-run)
		DO_DRY_RUN=1
		;;
	--)
		shift
		break
		;;
	--help)
		Usage; exit 0
		;;
	-*)
		Usage; exit 1
		;;
	*)
		break
	esac
	shift
done

[[ $# -ge 1 ]] || Usage

# Iterate over all file names given:

for file in "$@"; do
	filename=$(basename "${file}" | tr -cd '[:print:]' | tr " '\"%#/\\" '_' | tr -ds '»«„“‘’:' '_-')
	if [[ -n "${DO_RANDOM}" ]]; then
		base="${filename%.*}"
		ext="${filename##*.}"
		if [[ "${ext}" != "${filename}" ]]; then
			# File name has an extension. Add the "." back in.
			ext=".${ext}"
		else
			# File name does not have an extension at all!
			ext=""
		fi
		if command -v pwgen >/dev/null; then
			[[ ${DO_RANDOM} -eq 1 ]] \
				&& filename="${base}-$(pwgen -A ${SHORT_RANDOM_LEN} 1)${ext}" \
				|| filename="$(pwgen -A ${ALL_RANDOM_LEN} 1)${ext}"
		else
			echo "No command found to add random characters to file name! Aborting!" >&2
			exit 1
		fi
	fi
	url="${URL_PREFIX}${filename}"
	printf "»%s«\n" "${file}"
	if [[ -z "${DO_DRY_RUN}" ]]; then
		if ! scp -Cq "${file}" "${DST_HOST}:${DST_PATH}${filename}"; then
			exit 1
		fi
		printf " → %s\n" "${url}"
		if [[ -n "${DO_OPEN}" ]]; then
			if command -v xdg-open >/dev/null; then
				xdg-open "${url}"
			elif command -v open >/dev/null; then
				open "${url}"
			else
				echo "No command found to open the URL! Ignored." >&2
			fi
		fi
	else
		printf " ⇢ %s\n" "${url}"
	fi
done

if [[ -n "${DO_COPY}" ]]; then
	if command -v pbcopy >/dev/null; then
		printf "%s" "${url}" | pbcopy
	else
		echo "No command found to copy URL to clipboard! Ignored." >&2
	fi
fi

exit 0
