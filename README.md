# isard-scripts
Template generation scripts for IsardVDI

## How to use it
Deploy the app cloning the repo:
`git clone https://github.com/FherStk/isard-scripts.git`

Then, install the app with **sudo** (it will be installed at /etc/isard-scripts):
```
cd isard-scripts
sudo ./install.sh
```

The installation prompt will be displayed on first boot (won't be disabled if the promt is cancelled), so the user will be able to choose which template must be deployed. The prompt can be forced by running `sudo ./run.sh`.