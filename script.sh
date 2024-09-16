#!/bin/bash
# Bash script for updating and monitoring Pacman package manager process.
check_updates() {
	# It first checks for updates, then monitors the Pacman process for any errors or completion.
	# Checks if the file /var/lib/pacman/db.lck exists and removes it if it does.
    if [ -f /var/lib/pacman/db.lck ]; then
		rm /var/lib/pacman/db.lck
	fi
    # Checks if the file /opt/pacman_output.log exists and removes it if it does.
	if [ -f /opt/pacman_output.log ]; then
		rm /opt/pacman_output.log
	fi
    # Checks if there are any signature files present in the /var/lib/pacman/sync directory. 
    # If there are any signature files, it removes all files from the directory.
    dirSync="/var/lib/pacman/sync"
    if ls "$dirSync"/*.sig 1> /dev/null 2>&1; then
        rm -f /var/lib/pacman/sync/*
    fi
	echo "Updating the replica"
	pacman -Sy > /dev/null
	echo "Updated replica"
    updates_count=$(pacman -Qu | wc -l)
    if [ $updates_count -gt 0 ]; then
        echo "There are $updates_count updates available."
        return 0  # Updates available
    else
        echo "No updates available at this time."
        return 1
    fi
}
# The script includes functions to check for updates and monitor the Pacman process.
monitor_pacman() {
    while true
    do
        if pgrep -x "pacman" > /dev/null
        then
            echo "Process is running."
        else
            echo "The pacman process is not running. Starting the process..."
            # Execute pacman in the background and redirect the output to a file
            pacman -Syu --noconfirm > pacman_output.log 2>&1 &
            # Wait for a period of time to check if the process times out.
            sleep 30
            # Check if the process is running
            if pgrep -x "pacman" > /dev/null
            then
                echo "Process is running."
            else
                # Check the output of pacman to determine if there was an error
                if grep -q "error" pacman_output.log
                then
                    echo "The pacman process has ended with an error. Restarting the process..."
                    pacman -Syu --noconfirm > pacman_output.log 2>&1 &
                else
                    echo "The pacman process has finished successfully."
                    rm pacman_output.log
                    break  # Exit the loop
                fi
            fi
        fi
        # Wait before the next verification.
        sleep 60  # Wait for 1 minute before the next verification
    done
    # Handles errors and cache cleanup if needed.
    #/var/cache/pacman/pkg/
    if [ -n "$(ls -A /var/cache/pacman/pkg/)" ]; then
        echo "Deleting Pacman cache files..."
        pacman -Sc --noconfirm > /dev/null
        return 1
    fi
}
# If updates are available, it initiates the process and checks for its status.
if check_updates; then
    monitor_pacman
fi