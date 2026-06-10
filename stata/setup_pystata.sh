#!/bin/bash
# Set up Stata's Python integration (pystata) for Jupyter notebooks.
#
# Prerequisites: Stata must already be installed and licensed via
#   install_stata.sh and run_stinit.sh.
#
# Usage: bash ~/repos/workbench-examples/stata/setup_pystata.sh
#
# This script:
#   1. Copies the pystata Python package to the persistent GCS mount (one-time)
#   2. Installs the stata_setup pip package (needed after each app restart)

set -e

INSTALLDIR="/home/jupyter/workspace/uploads/stata/stata19"
PYSTATA_SRC="/tmp/stata19_install/utilities/pystata"

if [ ! -d "$INSTALLDIR" ]; then
    echo "ERROR: Stata installation not found at $INSTALLDIR"
    echo "Run install_stata.sh first."
    exit 1
fi

if [ ! -f "$INSTALLDIR/stata.lic" ]; then
    echo "WARNING: No license file found. Run run_stinit.sh if you haven't already."
fi

# Step 1: Ensure pystata package and ICU data exist on persistent storage
UTILS_SRC="/tmp/stata19_install/utilities"

if [ -d "$INSTALLDIR/utilities/pystata" ]; then
    echo "=== pystata package already exists ==="
else
    if [ ! -d "$UTILS_SRC/pystata" ]; then
        echo "ERROR: pystata not found on persistent storage or in $UTILS_SRC"
        echo "Re-run install_stata.sh to restore it."
        exit 1
    fi
    echo "=== Copying pystata package to persistent storage ==="
    mkdir -p "$INSTALLDIR/utilities"
    cp -r "$UTILS_SRC/pystata" "$INSTALLDIR/utilities/pystata"
    echo "Copied to $INSTALLDIR/utilities/pystata"
fi

if [ -f "$INSTALLDIR/utilities/icudt69l.dat" ]; then
    echo "=== ICU data file already exists ==="
elif [ -f "$UTILS_SRC/icudt69l.dat" ]; then
    echo "=== Copying ICU data file (Unicode support) ==="
    mkdir -p "$INSTALLDIR/utilities"
    cp "$UTILS_SRC/icudt69l.dat" "$INSTALLDIR/utilities/icudt69l.dat"
    echo "Copied icudt69l.dat"
else
    echo "=== ICU data file not available (Unicode warning may appear) ==="
fi

# Step 2: Install stata_setup pip package
if python3 -c "import stata_setup" 2>/dev/null; then
    echo "=== stata_setup pip package already installed ==="
else
    echo "=== Installing stata_setup pip package ==="
    pip install stata_setup
fi

echo ""
echo "=== Done! ==="
echo "In a Jupyter notebook:"
echo "  import stata_setup"
echo "  stata_setup.config(\"$INSTALLDIR\", \"mp\")"
