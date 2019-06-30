set -e

# define output zip
function_output_file=/opt/app/build/clamscan_function.zip

# update yum and install depedencies
yum update -y
yum install -y cpio yum-utils zip
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# make a tmp directory and download releavant rpms
pushd /tmp
yumdownloader -x \*i686 --archlist=x86_64 \
    clamav \
    clamav-lib \
    clamav-update \
    json-c \
    pcre2 \
    libtool-ltdl \
    openssl-libs

# convert relevant rpms to cpios
rpm2cpio clamav-0*.rpm | cpio -idmv
rpm2cpio clamav-lib*.rpm | cpio -idmv
rpm2cpio clamav-update*.rpm | cpio -idmv
rpm2cpio json-c*.rpm | cpio -idmv
rpm2cpio pcre*.rpm | cpio -idmv
rpm2cpio libtool-ltdl*.rpm | cpio -idmv
rpm2cpio openssl-libs*.rpm | cpio -idmv
popd

# make bin directory and copy relevant binaries into it
mkdir -p bin
rm -rf /tmp/usr/lib64/openssl
cp /tmp/usr/bin/clamscan /tmp/usr/bin/freshclam /tmp/usr/lib64/* bin/.
echo "DatabaseMirror database.clamav.net" > bin/freshclam.conf

# create a build directory and zip up new bin folder containing clamav and python
# google cloud function files
mkdir -p build
zip -r9 $function_output_file bin/.
cd ./functions/clamscan
zip -r9 $function_output_file ./main.py ./clamscan.py
cd ../../requirements
zip -r9 $function_output_file ./requirements.txt
cd ..

# remove the local bin folder
rm -rf ./bin
