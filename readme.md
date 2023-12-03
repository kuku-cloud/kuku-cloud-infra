# How to use
Place the Script: Put this script in the same directory as your docker-compose.yml.

Script Permissions: Give the script execution permission with `chmod +x init.sh`

Run the Script: Execute this script in your terminal.

# Note
Wait Time: The sleep 30 command in the script is to wait for the K3s container to start. You might need to adjust this time based on your system.

Kubeconfig Address Replacement: The sed command in the script is used to replace the server address in the kubeconfig file. Ensure this address matches your Docker container's address.

Environment Variable Persistence: The KUBECONFIG environment variable set by this script is only valid in the current terminal session. You might need to add it to your .bashrc, .zshrc, or other shell configuration files to keep it effective in new terminal sessions.

Error Checking: This script does basic error checking, but you may need more complex error handling logic to deal with all possible exceptions.

This script provides a starting point for automating the setup of your K3s cluster. Depending on your specific needs and environment, you may need to adjust and refine it.
