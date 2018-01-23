#!/usr/bin/env bash
set -euo pipefail

if ! [ -e index.php -a -e menu.php ]; then
	echo >&2 "LTB Self Service Password not found in $PWD - copying now..."
	if [ "$(ls -A)" ]; then
		echo >&2 "WARNING: $PWD is not empty - press Ctrl+C now if this is an error!"
		( set -x; ls -A; sleep 10 )
	fi
	tar cf - --one-file-system -C /usr/src/ltb-project-self-service-password-${LTB_PHP_SLFSRV_VERSION} . | tar xf -
	echo >&2 "Complete! LTB Self Service Password ${LTB_PHP_SLFSRV_VERSION} has been successfully copied to $PWD"
fi

exec "$@"
