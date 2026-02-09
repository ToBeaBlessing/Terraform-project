#!/bin/bash
# 1. Improved Logging
LOG_FILE="/var/log/user-data.log"
touch $LOG_FILE
chmod 644 $LOG_FILE
exec > >(tee -a $LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1

echo "--- Starting User Data Script: $(date) ---"

# 2. Update and Install
echo "Installing dependencies..."
sudo dnf update -y
sudo dnf install git python3-pip -y

# 3. Setup Working Directory
cd /home/ec2-user

# 4. Clone Repository
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

# 6. DATABASE CONFIGURATION - Write to file for persistence
echo "Configuring database connection..."
cat > /home/ec2-user/python-mysql-db-proj-1/.env <<EOF
DB_HOST=mydb.cxe8mesgwpvq.eu-central-1.rds.amazonaws.com
DB_USER=dbuser
DB_PASS=dbpassword
DB_NAME=devprojdb
EOF

# Set ownership
chown -R ec2-user:ec2-user /home/ec2-user/python-mysql-db-proj-1

# 7. Start Application
echo "Starting the application..."
# Kill any existing process on port 5000
sudo pkill -f app.py || true
sleep 2

# Start app as ec2-user with environment variables
cd /home/ec2-user/python-mysql-db-proj-1
sudo -u ec2-user bash -c "
    export DB_HOST=mydb.cxe8mesgwpvq.eu-central-1.rds.amazonaws.com
    export DB_USER=dbuser
    export DB_PASS=dbpassword
    export DB_NAME=devprojdb
    cd /home/ec2-user/python-mysql-db-proj-1
    nohup python3 -u app.py > app.log 2>&1 &
"

# 8. Verify app started
echo "Verifying application..."
sleep 5
if pgrep -f app.py > /dev/null; then
    echo "✓ Application started successfully on port 5000"
    echo "✓ App running as: $(ps aux | grep app.py | grep -v grep)"
else
    echo "✗ Application failed to start"
    echo "--- Checking app.log for errors ---"
    cat /home/ec2-user/python-mysql-db-proj-1/app.log || echo "No log file found"
fi

echo "--- User Data Script Finished: $(date) ---"