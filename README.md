# HomeLab 

This repo contains the code to provision infrastructure for a home lab using Proxmox for virtual machines Terraform for bootstrapping a K8s cluster to deploy all applications using the GitOps approach with Flux.

This home lab is an excellent platform for learning Kubernetes and DevOps tools like a proper production environment.
> Note: The VMs are using iscsi storage from an external NAS

## Hardware
- One PC with 16GB of RAM and Proxmox 7 installed 
- One external NAS or use the local storage of the PC
- And Ubuntu cloud-init image 

## Requierents
- Terraform v1.1.6
- Create a Terraform user in Proxmox with appropriate permission to create/update/delete VM and storage volumes
- Generate access token to allow terraform to access the API
- export PM_API_TOKEN_SECRET=<VALUE>
- EXPORT PM_API_TOKEN_ID=<VALUE>
