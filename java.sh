bash <<'EOF'
set -e

echo "=============================================="
echo "   Arena Burp Suite Auto Setup (Intel Mac)"
echo "=============================================="
echo ""

# ==================================================
# 1. DOWNLOAD DIRECTORY
# ==================================================

BASE_DIR="$HOME/Downloads"
ARENA_DIR="$BASE_DIR/Arena"
DESKTOP_DIR="$HOME/Desktop"
VENV_DIR="$ARENA_DIR/.gdown-venv"

mkdir -p "$ARENA_DIR"

echo "[✓] Arena folder:"
echo "$ARENA_DIR"
echo ""

# ==================================================
# 2. CHECK HOMEBREW (Intel Mac Path: /usr/local)
# ==================================================

echo "[*] Checking Homebrew..."

if command -v brew >/dev/null 2>&1; then

    echo "[✓] Homebrew is already installed."

else

    echo "[!] Homebrew not found."
    echo "[*] Installing Homebrew for Intel Mac..."
    echo ""

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x "/usr/local/bin/brew" ]; then

        eval "$(/usr/local/bin/brew shellenv)"
        export PATH="/usr/local/bin:$PATH"

        if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi

    elif [ -x "/opt/homebrew/bin/brew" ]; then

        eval "$(/opt/homebrew/bin/brew shellenv)"
        export PATH="/opt/homebrew/bin:$PATH"

        if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi

    else

        echo "[✗] Homebrew installation failed."
        exit 1

    fi

    echo "[✓] Homebrew installed successfully."

fi

echo ""

# ==================================================
# 3. CHECK JAVA 17 (Intel Mac Symlink Fix)
# ==================================================

echo "[*] Checking Java 17..."

if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then

    echo "[✓] Java 17 is already installed."

else

    echo "[!] Java 17 not found."
    echo "[*] Installing Java 17..."
    echo ""

    brew install openjdk@17

    if [ -x "/usr/local/opt/openjdk@17/bin/java" ]; then

        sudo ln -sfn \
        "/usr/local/opt/openjdk@17/libexec/openjdk.jdk" \
        "/Library/Java/JavaVirtualMachines/openjdk-17.jdk"

    elif [ -x "/opt/homebrew/opt/openjdk@17/bin/java" ]; then

        sudo ln -sfn \
        "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk" \
        "/Library/Java/JavaVirtualMachines/openjdk-17.jdk"

    fi

    echo "[✓] Java 17 installed successfully."

fi

export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"

echo ""
echo "Java:"
java -version
echo ""

# ==================================================
# 4. CHECK PYTHON 3
# ==================================================

echo "[*] Checking Python 3..."

if command -v python3 >/dev/null 2>&1; then

    echo "[✓] Python 3 is already installed."

else

    echo "[!] Python 3 not found."
    echo "[*] Installing Python 3..."

    brew install python

    if [ -x "/usr/local/bin/python3" ]; then
        export PATH="/usr/local/bin:$PATH"
    elif [ -x "/opt/homebrew/bin/python3" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
    fi

    echo "[✓] Python 3 installed successfully."

fi

echo ""
python3 --version
echo ""

# ==================================================
# 5. CREATE PYTHON VIRTUAL ENVIRONMENT
# ==================================================

echo "[*] Preparing gdown environment..."

if [ ! -d "$VENV_DIR" ]; then

    python3 -m venv "$VENV_DIR"
    echo "[✓] Python virtual environment created."

else

    echo "[✓] Python virtual environment already exists."

fi

"$VENV_DIR/bin/python" -m pip install --upgrade pip --quiet

# ==================================================
# 6. INSTALL GDOWN
# ==================================================

if "$VENV_DIR/bin/python" -c "import gdown" >/dev/null 2>&1; then

    echo "[✓] gdown is already installed."

else

    echo "[*] Installing gdown..."
    "$VENV_DIR/bin/python" -m pip install gdown

    echo "[✓] gdown installed successfully."

fi

echo ""

# ==================================================
# 7. DOWNLOAD FILE 1 - LODER.JAR
# ==================================================

echo "=============================================="
echo "         Downloading Required Files"
echo "=============================================="
echo ""

echo "[1/3] Downloading Loder.jar..."

"$VENV_DIR/bin/gdown" \
"1wa1dJXukn7ruH10VA8x-icqMyc1DUPgv" \
-O "$ARENA_DIR/Loder.jar"

if [ ! -f "$ARENA_DIR/Loder.jar" ]; then

    echo "[✗] Failed to download Loder.jar."
    exit 1

fi

echo "[✓] Loder.jar downloaded."
echo ""

# ==================================================
# 8. DOWNLOAD FILE 2
# ==================================================

echo "[2/3] Downloading second file..."

"$VENV_DIR/bin/gdown" \
"1bW7DAirK6aGDwa5ejShDbss0OMpm1p-l" \
--output "$ARENA_DIR"

echo "[✓] Second file downloaded."
echo ""

# ==================================================
# 9. DOWNLOAD FILE 3
# ==================================================

echo "[3/3] Downloading third file..."

"$VENV_DIR/bin/gdown" \
"1lqHu6NF1ePIAbl6pG-QU2rw8w0VsZGSy" \
--output "$ARENA_DIR"

echo "[✓] Third file downloaded."
echo ""

# ==================================================
# 10. CREATE LOCAL LAUNCHER
# ==================================================

echo "[*] Creating Arena launcher..."

cat > "$ARENA_DIR/Run-Loder.command" <<'LAUNCHER'
#!/bin/bash

cd "$(dirname "$0")"

export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"

echo "=============================================="
echo "                  Burp Suite"
echo "=============================================="
echo ""

if [ ! -f "Loder.jar" ]; then

    echo "[✗] Loder.jar not found."
    echo ""
    read -p "Press Enter to exit..."
    exit 1

fi

echo "[✓] Java 17 detected."
echo "[*] Starting Loder..."
echo ""

java -jar "Loder.jar"

echo ""
read -p "Press Enter to exit..."
LAUNCHER

chmod +x "$ARENA_DIR/Run-Loder.command"

# ==================================================
# 11. CREATE DESKTOP LAUNCHER
# ==================================================

echo "[*] Creating Desktop launcher..."

cat > "$DESKTOP_DIR/Burp Suite.command" <<LAUNCHER
#!/bin/bash

ARENA_DIR="$ARENA_DIR"

cd "\$ARENA_DIR"

export JAVA_HOME=\$(/usr/libexec/java_home -v 17)
export PATH="\$JAVA_HOME/bin:\$PATH"

echo "=============================================="
echo "                  Burp Suite"
echo "=============================================="
echo ""

if [ ! -f "\$ARENA_DIR/Loder.jar" ]; then

    echo "[✗] Loder.jar not found."
    echo ""
    read -p "Press Enter to exit..."
    exit 1

fi

echo "[✓] Java 17 detected."
echo "[*] Starting Loder..."
echo ""

java -jar "\$ARENA_DIR/Loder.jar"

echo ""
read -p "Press Enter to exit..."
LAUNCHER

chmod +x "$DESKTOP_DIR/Burp Suite.command"

# ==================================================
# 12. FINAL
# ==================================================

echo ""
echo "=============================================="
echo "            SETUP COMPLETED"
echo "=============================================="
echo ""
echo "[✓] Homebrew"
echo "[✓] Java 17"
echo "[✓] Python 3"
echo "[✓] gdown"
echo "[✓] Arena folder"
echo "[✓] Required drive files"
echo "[✓] Cyber-71 & Loder"
echo "[✓] Local launcher"
echo "[✓] Desktop launcher"
echo ""
echo "Arena:"
echo "$ARENA_DIR"
echo ""
echo "Desktop:"
echo "$DESKTOP_DIR/Burp Suite.command"
echo ""
echo "Double-click 'Burp Suite.command' from Desktop"
echo "to launch Loder.jar."
echo ""

read -p "Press Enter to exit..."
EOF