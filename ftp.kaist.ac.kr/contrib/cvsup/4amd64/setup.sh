# install cvsup in a separate place
# I had to write this to run cvsup/cvsupd in an AMD64 machine.
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2006-04-15

root=${1:-/cvsup}
set -e

if [ -d $root ]; then
    echo "$root already exists!!"
    exit 255
fi

cd "`dirname "$0"`"
./download-debs.sh
for deb in *.deb; do
    sudo dpkg -x $deb $root
done
sudo rm -f *.deb

cd "$root/usr/lib"
for l in ../X11R6/lib/*; do
    sudo ln -sfn $l
done

for f in /etc/{passwd,shadow,group,gshadow}; do
    sudo sh -c "cp -pf $f $root$f && egrep '^(root|cvsupd|mirror)' $f >$root$f"
done

sudo mkdir -p $root/dev
for f in /etc/{hosts,sudoers,resolv.conf} /dev/null; do
    sudo rsync -a $f $root$f
done

sudo mkdir -p $root/mirror
sudo mount --bind -o noatime /mirror $root/mirror
