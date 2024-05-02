VM_BOX_NAME = "generic/centos7"

SERVER_NAME = "kthierryS" 
AGENT_NAME = "kthierrySW" 

SERVER_IP = "192.168.56.110"
AGENT_IP = "192.168.56.111"

SYNCED_FOLDER = "shared"
K3S_TOKEN = "/var/lib/rancher/k3s/server/node-token"

SERVER_SCRIPT_PATH = "./scripts/provision_S.sh"
AGENT_SCRIPT_PATH = "./scripts/provision_SW.sh"

SERVER_ENV = {"SERVER_IP"=>SERVER_IP, "K3S_TOKEN"=>K3S_TOKEN, "SYNCED_FOLDER"=>SYNCED_FOLDER}
AGENT_ENV = {"AGENT_IP"=>AGENT_IP, "SERVER_IP"=>SERVER_IP, "SYNCED_FOLDER"=>SYNCED_FOLDER}