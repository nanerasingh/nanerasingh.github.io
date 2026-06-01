#!/bin/bash
# Regenerate repo index files for both Cydia and Sileo support
dpkg-scanpackages -m pkgs /dev/null > Packages
bzip2 -kf Packages
xz -kf Packages
gzip -kf Packages
