# isard-scripts
Template generation scripts for IsardVDI

## How to install
The app can be installed within any IsardVDI machine running an Ubuntu Server 22.04 LTS:

1. Deploy the app cloning the repo: `git clone https://github.com/FherStk/isard-scripts.git`
2. Then, install the app with **sudo** (it will be installed at /etc/isard-scripts):
```
cd isard-scripts
sudo ./install.sh
history -c
```

3. The installation prompt will be displayed on first boot (won't be disabled if the promt is cancelled), so the user will be able to choose which template must be deployed. The prompt can be forced by running `sudo ./run.sh`.

## How to test a script in develop
Please, follow this steps in order to test any script during development:

1. Start a clean machine and login
2. Cancel the script startup execution
3. Go to the git folder: `cd ~/isard-scripts`
4. Update the repo: `sudo git pull`
5. Set the current git branch to the one where you're developing the script: `sudo git checkout <branch_name>`
6. Test the script with `sudo ./scripts/<script_name.sh>` or the launcher with `sudo ./run.sh`
7. When done, perform a pull request and every machine will be updated on startup.