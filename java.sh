#!/bin/bash
set -e

echo "=============================================="
echo "   Arena Burp Suite Auto Setup (Intel Mac)"
echo "=============================================="
echo ""

# ==================================================
# 1. DIRECTORY SETUP
# ==================================================
BASE_DIR="$HOME/Downloads"
ARENA_DIR="$BASE_DIR/Arena"
DESKTOP_DIR="$HOME/Desktop"
VENV_DIR="$ARENA_DIR/.gdown-venv"

mkdir -p "$ARENA_DIR"

echo "[✓] Target Directory: $ARENA_DIR"
echo ""

# ==================================================
# 2. CHECK JAVA 17
# ==================================================
echo "[*] Checking Java Environment..."

if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
    export JAVA_HOME=$(/usr/libexec/java_home -v 17)
    echo "[✓] Java 17 detected at: $JAVA_HOME"
else
    echo "[!] Warning: Java 17 default path not found, using system default Java."
    export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || echo "")
fi

export PATH="$JAVA_HOME/bin:$PATH"
echo ""

# ==================================================
# 3. PYTHON & GDOWN SETUP (NO SUDO NEEDED)
# ==================================================
echo "[*] Setting up Python Environment for downloads..."

if ! command -v python3 >/dev/null 2>&1; then
    echo "[✗] Python 3 missing! Please install Python 3 first."
    exit 1
fi

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/python" -m pip install --upgrade pip --quiet
"$VENV_DIR/bin/python" -m pip install gdown --quiet

echo "[✓] Python download tool (gdown) ready."
echo ""

# ==================================================
# 4. DOWNLOADING FILES FROM GOOGLE DRIVE
# ==================================================
echo "=============================================="
echo "         Downloading Required Files"
echo "=============================================="
echo ""

echo "[1/3] Downloading Loder.jar..."
"$VENV_DIR/bin/gdown" "1wa1dJXukn7ruH10VA8x-icqMyc1DUPgv" -O "$ARENA_DIR/Loder.jar" --quiet

if [ ! -f "$ARENA_DIR/Loder.jar" ]; then
    echo "[✗] Failed to download Loder.jar."
    exit 1
fi
echo "[✓] Loder.jar downloaded."

echo "[2/3] Downloading second file..."
"$VENV_DIR/bin/gdown" "1bW7DAirK6aGDwa5ejShDbss0OMpm1p-l" --output "$ARENA_DIR" --quiet
echo "[✓] Second file downloaded."

echo "[3/3] Downloading third file..."
"$VENV_DIR/bin/gdown" "1lqHu6NF1ePIAbl6pG-QU2rw8w0VsZGSy" --output "$ARENA_DIR" --quiet
echo "[✓] Third file downloaded."
echo ""

# ==================================================
# 5. CREATE LAUNCHERS
# ==================================================
echo "[*] Creating Desktop Launcher..."

cat > "$DESKTOP_DIR/Burp Suite.command" <<LAUNCHER
#!/bin/bash

ARENA_DIR="$ARENA_DIR"
cd "\$ARENA_DIR"

if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
    export JAVA_HOME=\$(/usr/libexec/java_home -v 17)
    export PATH="\$JAVA_HOME/bin:\$PATH"
fi

echo "=============================================="
echo "               Burp Suite"
echo "=============================================="
echo ""

if [ ! -f "\$ARENA_DIR/Loder.jar" ]; then
    echo "[✗] Loder.jar not found in \$ARENA_DIR"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "[*] Launching Loder.jar..."
java -jar "\$ARENA_DIR/Loder.jar"

echo ""
read -p "Press Enter to exit..."
LAUNCHER

chmod +x "$DESKTOP_DIR/Burp Suite.command"

# ==================================================
# 6. COMPLETION
# ==================================================
echo "=============================================="
echo "            SETUP COMPLETED!"
echo "=============================================="
echo ""
echo "[✓] All files downloaded to: $ARENA_DIR"
echo "[✓] Desktop shortcut created: Burp Suite.command"
echo ""
echo "Double-click 'Burp Suite.command' on your Desktop to run."
echo ""
