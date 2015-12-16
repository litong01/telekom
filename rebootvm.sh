VBoxManage snapshot h1 restore "Snapshot 1"
VBoxManage snapshot h2 restore "Snapshot 1"

vboxmanage startvm h1 --type headless
vboxmanage startvm h2 --type headless
