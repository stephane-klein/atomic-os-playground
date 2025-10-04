#!/usr/bin/env bash
set -e

# Use this script to generate ./OSTreeTutorial.md:
#
# $ ./OSTreeTutorial.sh > OSTreeTutorial.md 2>&1

stty cols 80
cd "$(dirname "$0")/"

ssh -p 2222 -o StrictHostKeyChecking=no stephane@127.0.0.1 << 'EOF'

## Clean up the environment if an OSTree test environment already exists
sudo umount ostree-test/mnt &> /dev/null
rm ostree-test -rf || true > /dev/null

cat << 'EOF2'
# OSTree and composefs tutorial

## Initialising the OSTree repository

Create a test directory:

```
$ mkdir -p ~/ostree-test
$ cd ~/ostree-test
```

Initialize an OSTree repository (archive mode for serving):

```
$ ostree init --repo=./repo --mode=archive
```

Verify the repository structure:

```
$ ls -la repo/
EOF2
mkdir -p ~/ostree-test
cd ~/ostree-test
ostree init --repo=./repo --mode=archive
ls -la repo/

cat << 'EOF2'
```

## Create content and create a commit

Create some test content:

```
$ mkdir -p files/usr/bin
$ mkdir -p files/etc
$ echo "Hello OSTree" > files/etc/hello.txt
$ echo '#!/bin/bash\necho "OSTree test app"' > files/usr/bin/testapp
$ chmod +x files/usr/bin/testapp
```

Create a commit in OSTree:

```
$ ostree commit --repo=./repo \
  --branch=testbranch \
  --subject="First commit" \
  --body="Testing OSTree with some files" \
  files/
EOF2

mkdir -p files/usr/bin
mkdir -p files/etc
echo "Hello OSTree" > files/etc/hello.txt
echo '#!/bin/bash\necho "OSTree test app"' > files/usr/bin/testapp
chmod +x files/usr/bin/testapp

ostree commit --repo=./repo \
  --branch=testbranch \
  --subject="First commit" \
  --body="Testing OSTree with some files" \
  files/

cat << 'EOF2'
```

## List commits

```
$ ostree log --repo=./repo testbranch
EOF2

ostree log --repo=./repo testbranch

cat << 'EOF2'
```
## Explore the content

Show the commit hash:

```
$ ostree refs --repo=./repo
EOF2

ostree refs --repo=./repo

cat << 'EOF2'
```

List files in the commit:

```
$ ostree ls --repo=./repo testbranch
EOF2

ostree ls --repo=./repo testbranch

cat << 'EOF2'
```

Show detailed tree:

```
$ ostree ls -R --repo=./repo testbranch
EOF2

ostree ls -R --repo=./repo testbranch

cat << 'EOF2'
```

Check out the content

```
$ ostree checkout --repo=./repo testbranch checkout1/
EOF2

ostree checkout --repo=./repo testbranch checkout1/

cat << 'EOF2'
```

Verify the content:

```
$ ls -R checkout1/
EOF2

ls -R checkout1/

cat << 'EOF2'
$ cat checkout1/etc/hello.txt
EOF2

cat checkout1/etc/hello.txt

cat << 'EOF2'
```

## Make a second commit (delta)

Modify content:

```
$ echo "Updated content" >> files/etc/hello.txt
$ echo "New file" > files/etc/newfile.txt
```

Create second commit:

```
$ ostree commit --repo=./repo \
  --branch=testbranch \
  --subject="Second commit" \
  --body="Added and modified files" \
  files/
EOF2

echo "Updated content" >> files/etc/hello.txt
echo "New file" > files/etc/newfile.txt

ostree commit --repo=./repo \
  --branch=testbranch \
  --subject="Second commit" \
  --body="Added and modified files" \
  files/

cat << 'EOF2'
```

Check the log (you'll see 2 commits):

```
$ ostree log --repo=./repo testbranch
EOF2

ostree log --repo=./repo testbranch

cat << 'EOF2'
```

Check differences between commits:

```
$ COMMIT1=$(ostree log --repo=./repo testbranch | grep ^commit | tail -1 | cut -d' ' -f2)
$ COMMIT2=$(ostree log --repo=./repo testbranch | grep ^commit | head -1 | cut -d' ' -f2)
$
$ ostree diff --repo=./repo $COMMIT1 $COMMIT2
EOF2

COMMIT1=$(ostree log --repo=./repo testbranch | grep ^commit | tail -1 | cut -d' ' -f2)
COMMIT2=$(ostree log --repo=./repo testbranch | grep ^commit | head -1 | cut -d' ' -f2)

ostree diff --repo=./repo $COMMIT1 $COMMIT2


cat << 'EOF2'
```

## Objects inspection

```
$ ostree summary --repo=./repo -u
EOF2

ostree summary --repo=./repo -u

cat << 'EOF2'
```

Show repository statistics:

```
$ ostree summary --repo=./repo --view
EOF2

ostree summary --repo=./repo --view

cat << 'EOF2'
```

List all objects:

```
$ ostree refs --repo=./repo --list
EOF2

ostree refs --repo=./repo --list

cat << 'EOF2'
```

Show object info.

```
$ ostree show --repo=./repo testbranch
EOF2

ostree show --repo=./repo testbranch

cat << 'EOF2'
```

Check repository integrity:

```
$ ostree fsck --repo=./repo
EOF2

ostree fsck --repo=./repo

cat << 'EOF2'
```

## composefs installation and verification

Check if composefs tools are available

```
$ which mkcomposefs
EOF2

which mkcomposefs

cat << 'EOF2'
$ which mount.composefs
EOF2

which mount.composefs

cat << 'EOF2'
```

Check kernel support:

```
$ cat /proc/filesystems | grep erofs
EOF2

cat /proc/filesystems | grep erofs

cat << 'EOF2'
$ cat /proc/filesystems | grep overlay
EOF2

cat /proc/filesystems | grep overlay

cat << 'EOF2'
```

## Create composefs image from OSTree

Create a composefs image from the OSTree commit:

```
$ ostree checkout --repo=./repo testbranch checkout-for-composefs/
EOF2

ostree checkout --repo=./repo testbranch checkout-for-composefs/

cat << 'EOF2'
```

Generate composefs image:

```
$ mkcomposefs --digest-store=./repo/objects checkout-for-composefs/ test.cfs
EOF2

mkcomposefs --digest-store=./repo/objects checkout-for-composefs/ test.cfs

cat << 'EOF2'
```

Check the generated image:

```
$ ls -lh test.cfs
EOF2

ls -lh test.cfs

cat << 'EOF2'
$ file test.cfs
EOF2

file test.cfs

cat << 'EOF2'
```

## Mount composefs image

Create mount point:

```
$ mkdir -p mnt
```

Mount the composefs image (requires root):

```
$ sudo mount -t composefs -o basedir=./repo/objects test.cfs mnt/
EOF2

mkdir -p mnt
sudo mount -t composefs -o basedir=./repo/objects test.cfs mnt/

cat << 'EOF2'
```

Verify mounted content:

```
$ ls -R mnt/
EOF2

ls -R mnt/

cat << 'EOF2'
$ cat mnt/etc/hello.txt
EOF2

cat mnt/etc/hello.txt

cat << 'EOF2'
```

Check mount details:

```sh
$ mount | grep composefs
EOF2

mount | grep composefs

cat << 'EOF2'
$ df -h mnt/
EOF2

df -h mnt/

cat << 'EOF2'
```

## Deduplication test

Add a large file multiple times:

```
$ dd if=/dev/urandom of=files/large1.bin bs=1M count=10
$ cp files/large1.bin files/large2.bin
$ cp files/large1.bin files/large3.bin
EOF2

dd if=/dev/urandom of=files/large1.bin bs=1M count=10
cp files/large1.bin files/large2.bin
cp files/large1.bin files/large3.bin

cat << 'EOF2'
```

Commit:

```
$ ostree commit --repo=./repo \
  --branch=testbranch \
  --subject="Testing deduplication" \
  files/
EOF2

ostree commit --repo=./repo \
  --branch=testbranch \
  --subject="Testing deduplication" \
  files/

cat << 'EOF2'
```

Checkout and create new composefs image:

```
$ ostree checkout --repo=./repo testbranch checkout-dedup/
EOF2

ostree checkout --repo=./repo testbranch checkout-dedup/

cat << 'EOF2'
```

```
$ mkcomposefs \
  --digest-store=./repo/objects \
  checkout-dedup/ \
  test-dedup.cfs
EOF2

mkcomposefs \
  --digest-store=./repo/objects \
  checkout-dedup/ \
  test-dedup.cfs

cat << 'EOF2'
```

Compare sizes:

```
$ du -sh checkout-dedup/
EOF2

du -sh checkout-dedup/

cat << 'EOF2'
$ ls -lh test-dedup.cfs
EOF2

ls -lh test-dedup.cfs

cat << 'EOF2'
```

Check object deduplication in OSTree:

```
$ ostree fsck --repo=./repo
EOF2

ostree fsck --repo=./repo

cat << 'EOF2'
```

EOF2

EOF
