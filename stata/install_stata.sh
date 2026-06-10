#!/bin/bash
# Stata 19 Linux Installation for Workbench
# Reference: https://www.stata.com/support/faqs/unix/install-download-on-linux/
#
# Usage: sudo bash ~/repos/workbench-examples/stata/install_stata.sh
# After install completes, run: sudo bash ~/repos/workbench-examples/stata/run_stinit.sh

set -e

TARFILE="/home/jupyter/workspace/uploads/stata/StataNow19Linux64.tar.gz"
TMPDIR="/tmp/statafiles"
INSTALLDIR="/home/jupyter/workspace/uploads/stata/stata19"

if [ ! -f "$TARFILE" ]; then
    echo "ERROR: $TARFILE not found"
    exit 1
fi

echo "=== Step 1: Extract to temp directory ==="
umask 0002
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
cd "$TMPDIR"
tar -zxf "$TARFILE"
echo "Extracted to $TMPDIR"

echo "=== Step 2: Install to local temp directory (GCS mount blocks chmod) ==="
LOCALINSTALL="/tmp/stata19_install"
rm -rf "$LOCALINSTALL"
mkdir -p "$LOCALINSTALL"
cd "$LOCALINSTALL"
echo "Temp install directory: $LOCALINSTALL"

echo "=== Step 3: Run Stata installer ==="
echo "The installer will prompt you interactively."
echo "  - Confirm the install directory when asked."
echo "  - Answer 'y' to proceed."
echo ""
"$TMPDIR/install"

echo ""
echo "=== Step 4: Copy to persistent workspace storage ==="
echo "This may take 10-15 minutes due to the large number of files."
rm -rf "$INSTALLDIR"
mkdir -p "$INSTALLDIR"
(cd "$LOCALINSTALL" && tar cf - .) | (cd "$INSTALLDIR" && tar xf -)
echo "Copied to $INSTALLDIR"

echo ""
echo "=== Step 5: Verify installation ==="
VERIFY_OK=true
for d in ado/base utilities/pystata; do
    if [ -d "$INSTALLDIR/$d" ]; then
        echo "  $d: OK"
    else
        echo "  $d: MISSING"
        VERIFY_OK=false
    fi
done
if [ "$VERIFY_OK" = false ]; then
    echo "WARNING: Some directories are missing. The copy to GCS may have"
    echo "failed to preserve directory structure. Check the installation."
fi

echo ""
echo "=== Installation complete ==="
echo "Next step: initialize the license:"
echo "  sudo bash ~/repos/workbench-examples/stata/run_stinit.sh"
