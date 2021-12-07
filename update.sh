rm Packages.bz2
dpkg-scanpackages -m ./pkgs /dev/null >Packages
bzip2 Packages
