#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	echo "Usage: ${0}"
	echo "Writes an ERD of the schema in graphml to erd.graphml."
	echo "Requires environment vars VALAR_USER and VALAR_PASSWORD"
	exit 0
fi

if (( $# > 0 )); then
	(>&2 echo "Usage: ${0}")
	exit 1
fi

mv mysql-connector-java-5.1.40-bin.jar ~/.groovy/lib
rm mysql-connector-java-5.1.40.zip
rm -r mysql-connector-java-5.1.40

groovy erd.groovy > erd.graphml
