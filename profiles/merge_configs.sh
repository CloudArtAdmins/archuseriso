src=$1
dir=$2
rsync -avP $src $dir --exclude={airootfs/root/customize_airootfs.sh,packages.x86_64,profiledef.sh} $@
