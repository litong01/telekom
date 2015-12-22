VBoxManage snapshot h1-90 restore "Snapshot 2"
VBoxManage snapshot h2-88 restore "Snapshot 2"
VBoxManage snapshot h2-93 restore "Snapshot 2"

vboxmanage startvm h1-90 --type headless
vboxmanage startvm h2-88 --type headless
vboxmanage startvm h2-93 --type headless
