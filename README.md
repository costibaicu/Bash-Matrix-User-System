# 📟 Matrix User Management System (Bash)

A shell script project developed for the **Operating Systems** course. This application simulates a user management system in a Linux environment, demonstrating core concepts of shell scripting, process management, and file handling.

## 📝 Overview

The script (`proiectso.sh`) provides a command-line interface (CLI) for registering users, logging in, and generating system activity reports. It uses local files (`.csv` and directories) to simulate a database and user home folders.

## 🛠️ Key Technical Features

* **Secure Authentication:** Passwords are hashed using `sha256sum` before storage; plain text passwords are never saved.
* **Database Management:** User data (Username, Email, Hash, UID, Last Login) is stored and manipulated in `users.csv` using `grep` and `sed`.
* **Process Management:** Activity reports are generated in the **background** (using `&`), allowing the user to continue using the menu while the calculation runs.
* **Notifications:** Integrates with `msmtp` to send simulated login email notifications.
* **Fun Elements:** Uses `cowsay` for interactive login/logout greetings.

## 📂 Project Structure

* `proiectso.sh`: The main executable script.
* `users.csv`: Automatically generated file acting as the user database.
* `user_homes/`: Directory created to store individual user data (reports, simulated IDs).

## 💻 Prerequisites

To run the script with full functionality, the following packages are recommended (but the script handles basic execution without them):

```bash
sudo apt update
sudo apt install msmtp cowsay coreutils
