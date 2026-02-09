#!/bin/bash
# 1. Start Logging (Everything will now go to /var/log/user-data.log)
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- Starting User Data Script ---"

# 2. Use DNF (Amazon Linux package manager) instead of apt
sudo dnf update -y
sudo dnf install git python3-pip -y

# 3. Use the correct home directory for ec2-user
cd /home/ec2-user

# 4. Clone your repository
echo "Cloning repository..."
git clone https://github.com/ToBeaBlessing/python-mysql-db-proj-1.git
cd python-mysql-db-proj-1

# 5. Install Python dependencies
echo "Installing requirements..."
pip3 install -r requirements.txt

# 6. Run the application
# We use nohup and redirection to ensure the app stays running after the script ends
echo "Waiting for 30 seconds before running the app.py"
sleep 30

# IMPORTANT: Ensure your app.py has app.run(host='0.0.0.0') 
# otherwise the Load Balancer cannot reach it!
nohup python3 app.py > app.log 2>&1 &

echo "--- User Data Script Finished ---"