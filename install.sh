#!/bin/bash

set -e

# Function to prompt for PWA URL
prompt_pwa_url() {
    read -p "Enter the PWA URL for your kiosk: " pwa_url
    echo "PWA_URL=$pwa_url" > /home/pi/.env
    echo "PWA URL saved to /home/pi/.env"
}

# Update and upgrade system
echo "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y ansible git

# Prompt for PWA URL
prompt_pwa_url

# Create ansible-pull script
echo "Creating ansible-pull script..."
cat << EOF | sudo tee /usr/local/bin/update-kiosk.sh
#!/bin/bash
source /home/pi/.env
ansible-pull -U https://github.com/yourusername/raspi-kiosk-playbook.git raspi-kiosk-playbook.yml -e "pwa_url=\$PWA_URL"
EOF

sudo chmod +x /usr/local/bin/update-kiosk.sh

# Set up cron job
echo "Setting up cron job..."
(crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/update-kiosk.sh") | crontab -

# Run ansible-pull for the first time
echo "Running ansible-pull for the first time..."
sudo /usr/local/bin/update-kiosk.sh

echo "Setup complete! The system will reboot in 10 seconds. Press Ctrl+C to cancel."
sleep 10
sudo reboot
