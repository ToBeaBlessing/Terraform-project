#!/bin/bash
# 1. Improved Logging - Ensures the log file exists and has correct permissions
LOG_FILE="/var/log/user-data.log"
touch $LOG_FILE
chmod 666 $LOG_FILE
exec > >(tee -a $LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1

echo "--- Starting User Data Script: $(date) ---"

# 2. Update and Install with explicit 'yes' and error checking
echo "Installing dependencies..."
sudo dnf update -y
sudo dnf install git python3-pip -y

# 3. Setup Working Directory
cd /home/ec2-user

# 4. Clone Repository (Checks if directory exists first)
if [ -d "python-mysql-db-proj-1" ]; then
    echo "Directory already exists, pulling latest changes..."
    cd python-mysql-db-proj-1
    git pull
else
    echo "Cloning repository..."
    git clone https://github.com/ToBeaBlessing/python-mysql-db-proj-1.git
    cd python-mysql-db-proj-1
fi

# 5. Install Python dependencies
echo "Installing requirements..."
pip3 install --upgrade pip
pip3 install -r requirements.txt

# 6. DATABASE CONFIGURATION (Crucial Step)
# Injecting the RDS endpoint directly into the shell session
# Replace these values or use Terraform to template them
export DB_HOST="mydb.cxe8mesgwpvq.eu-central-1.rds.amazonaws.com"
export DB_USER="dbuser"
export DB_PASS="dbpassword"
export DB_NAME="devprojdb"

# 7. Start Application
echo "Starting the application..."
# Kill any existing process on port 5000 to prevent 'Address already in use' errors
sudo pkill -f app.py || true

# nohup ensures the app keeps running after the shell exits
# 'python3 -u' ensures logs are unbuffered (sent to app.log immediately)
nohup python3 -u app.py > app.log 2>&1 &

echo "--- User Data Script Finished: $(date) ---"