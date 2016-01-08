VBoxManage snapshot h2-90 restore "Snapshot 1"
VBoxManage snapshot h2-88 restore "Snapshot 1"
VBoxManage snapshot h2-93 restore "Snapshot 1"

vboxmanage startvm h2-90 --type headless
vboxmanage startvm h2-88 --type headless
vboxmanage startvm h2-93 --type headless
