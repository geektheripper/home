#!/usr/bin/env bash

set -e

rm -rf linux-files
mkdir -p linux-files
trap "rm -r linux-files" EXIT

# Build pre.sh
echo "#!/usr/bin/env bash" >linux-files/pre.sh

append-pre() { cat pre/linux/$1 | grep -v '#!/usr/bin/env bash' >>linux-files/pre.sh; }

append-pre "base/*"
append-pre "cmd/*"

# Copy bin
cp -r bin linux-files/

super-cp
