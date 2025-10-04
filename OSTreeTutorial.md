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
total 4
drwxr-xr-x. 7 stephane stephane 89 Oct  4 21:38 .
drwxr-xr-x. 3 stephane stephane 18 Oct  4 21:38 ..
-rw-r--r--. 1 stephane stephane 38 Oct  4 21:38 config
drwxr-xr-x. 2 stephane stephane  6 Oct  4 21:38 extensions
drwxr-xr-x. 2 stephane stephane  6 Oct  4 21:38 objects
drwxr-xr-x. 5 stephane stephane 49 Oct  4 21:38 refs
drwxr-xr-x. 2 stephane stephane  6 Oct  4 21:38 state
drwxr-xr-x. 3 stephane stephane 19 Oct  4 21:38 tmp
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
905c1f0fc84e59bae4b6fc765ac1632613409cb1ededb99ef1af72ed1b097b82
```

## List commits

```
$ ostree log --repo=./repo testbranch
commit 905c1f0fc84e59bae4b6fc765ac1632613409cb1ededb99ef1af72ed1b097b82
ContentChecksum:  37d9c37d98e36a207f3be37cb22b5a7dbf0b3021b657280242b01c8dda14584d
Date:  2025-10-04 21:38:41 +0000

    First commit

    Testing OSTree with some files

```
## Explore the content

Show the commit hash:

```
$ ostree refs --repo=./repo
testbranch
```

List files in the commit:

```
$ ostree ls --repo=./repo testbranch
d00755 1001 1001      0 /
d00755 1001 1001      0 /etc
d00755 1001 1001      0 /usr
```

Show detailed tree:

```
$ ostree ls -R --repo=./repo testbranch
d00755 1001 1001      0 /
d00755 1001 1001      0 /etc
-00644 1001 1001     13 /etc/hello.txt
d00755 1001 1001      0 /usr
d00755 1001 1001      0 /usr/bin
-00755 1001 1001     36 /usr/bin/testapp
```

Check out the content

```
$ ostree checkout --repo=./repo testbranch checkout1/
```

Verify the content:

```
$ ls -R checkout1/
checkout1/:
etc
usr

checkout1/etc:
hello.txt

checkout1/usr:
bin

checkout1/usr/bin:
testapp
$ cat checkout1/etc/hello.txt
Hello OSTree
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
cce909f35225904d357f5c8a153f9111e9cf65e60e1fa4013975d0ac3962f9a0
```

Check the log (you'll see 2 commits):

```
$ ostree log --repo=./repo testbranch
commit cce909f35225904d357f5c8a153f9111e9cf65e60e1fa4013975d0ac3962f9a0
Parent:  905c1f0fc84e59bae4b6fc765ac1632613409cb1ededb99ef1af72ed1b097b82
ContentChecksum:  65d148bab9cc99763bdd15d43d9693bcf02ad22a7434d31fb52da6d6dd84957f
Date:  2025-10-04 21:38:41 +0000

    Second commit

    Added and modified files

commit 905c1f0fc84e59bae4b6fc765ac1632613409cb1ededb99ef1af72ed1b097b82
ContentChecksum:  37d9c37d98e36a207f3be37cb22b5a7dbf0b3021b657280242b01c8dda14584d
Date:  2025-10-04 21:38:41 +0000

    First commit

    Testing OSTree with some files

```

Check differences between commits:

```
$ COMMIT1=$(ostree log --repo=./repo testbranch | grep ^commit | tail -1 | cut -d' ' -f2)
$ COMMIT2=$(ostree log --repo=./repo testbranch | grep ^commit | head -1 | cut -d' ' -f2)
$
$ ostree diff --repo=./repo $COMMIT1 $COMMIT2
M    /etc/hello.txt
A    /etc/newfile.txt
```

## Objects inspection

```
$ ostree summary --repo=./repo -u
```

Show repository statistics:

```
$ ostree summary --repo=./repo --view
* testbranch
    Latest Commit (190 bytes):
      cce909f35225904d357f5c8a153f9111e9cf65e60e1fa4013975d0ac3962f9a0
    Timestamp (ostree.commit.timestamp): 2025-10-04T21:38:41+00

Repository Mode (ostree.summary.mode): archive-z2
Last-Modified (ostree.summary.last-modified): 2025-10-04T21:38:41+00
Has Tombstone Commits (ostree.summary.tombstone-commits): No
ostree.summary.indexed-deltas: true
```

List all objects:

```
$ ostree refs --repo=./repo --list
testbranch
```

Show object info.

```
$ ostree show --repo=./repo testbranch
commit cce909f35225904d357f5c8a153f9111e9cf65e60e1fa4013975d0ac3962f9a0
Parent:  905c1f0fc84e59bae4b6fc765ac1632613409cb1ededb99ef1af72ed1b097b82
ContentChecksum:  65d148bab9cc99763bdd15d43d9693bcf02ad22a7434d31fb52da6d6dd84957f
Date:  2025-10-04 21:38:41 +0000

    Second commit

    Added and modified files

```

Check repository integrity:

```
$ ostree fsck --repo=./repo
Validating refs...
Validating refs in collections...
Enumerating commits...
Verifying content integrity of 2 commit objects...
fsck objects (1/13) 7%
fsck objects (13/13) 100%
object fsck of 2 commits completed successfully - no errors found.
```

## composefs installation and verification

Check if composefs tools are available

```
$ which mkcomposefs
/usr/bin/mkcomposefs
$ which mount.composefs
/usr/bin/mount.composefs
```

Check kernel support:

```
$ cat /proc/filesystems | grep erofs
        erofs
$ cat /proc/filesystems | grep overlay
nodev   overlay
```

## Create composefs image from OSTree

Create a composefs image from the OSTree commit:

```
$ ostree checkout --repo=./repo testbranch checkout-for-composefs/
```

Generate composefs image:

```
$ mkcomposefs --digest-store=./repo/objects checkout-for-composefs/ test.cfs
```

Check the generated image:

```
$ ls -lh test.cfs
-rw-r--r--. 1 stephane stephane 24K Oct  4 21:38 test.cfs
$ file test.cfs
test.cfs: EROFS filesystem, compat: MTIME, blocksize=12, exslots=0, uuid=00000000-0000-0000-0000-000000000000
```

## Mount composefs image

Create mount point:

```
$ mkdir -p mnt
```

Mount the composefs image (requires root):

```
$ sudo mount -t composefs -o basedir=./repo/objects test.cfs mnt/
```

Verify mounted content:

```
$ ls -R mnt/
mnt/:
etc
usr

mnt/etc:
hello.txt
newfile.txt

mnt/usr:
bin

mnt/usr/bin:
testapp
$ cat mnt/etc/hello.txt
Hello OSTree
Updated content
```

Check mount details:

```
$ mount | grep composefs
composefs on / type overlay (ro,relatime,seclabel,lowerdir+=/run/ostree/.private/cfsroot-lower,datadir+=/sysroot/ostree/repo/objects,redirect_dir=on,metacopy=on)
composefs on /var/home/stephane/ostree-test/mnt type overlay (ro,relatime,seclabel,lowerdir+=/tmp/.composefs.bLKVCe,datadir+=./repo/objects,redirect_dir=on,metacopy=on)
$ df -h mnt/
Filesystem      Size  Used Avail Use% Mounted on
composefs        24K   24K     0 100% /var/home/stephane/ostree-test/mnt
```

## Deduplication test

Add a large file multiple times:

```
$ dd if=/dev/urandom of=files/large1.bin bs=1M count=10
$ cp files/large1.bin files/large2.bin
$ cp files/large1.bin files/large3.bin
10+0 records in
10+0 records out
10485760 bytes (10 MB, 10 MiB) copied, 0.0283764 s, 370 MB/s
```

Commit:

```
$ ostree commit --repo=./repo \
  --branch=testbranch \
  --subject="Testing deduplication" \
  files/
22424f4c228a20d9b43151e55e043c5f6e1dd22bfb0319d2384755bfa2ed62ce
```

Checkout and create new composefs image:

```
$ ostree checkout --repo=./repo testbranch checkout-dedup/
```

```
$ mkcomposefs \
  --digest-store=./repo/objects \
  checkout-dedup/ \
  test-dedup.cfs
```

Compare sizes:

```
$ du -sh checkout-dedup/
31M     checkout-dedup/
$ ls -lh test-dedup.cfs
-rw-r--r--. 1 stephane stephane 24K Oct  4 21:38 test-dedup.cfs
```

Check object deduplication in OSTree:

```
$ ostree fsck --repo=./repo
Validating refs...
Validating refs in collections...
Enumerating commits...
Verifying content integrity of 3 commit objects...
fsck objects (1/16) 6%
fsck objects (16/16) 100%
object fsck of 3 commits completed successfully - no errors found.
```
