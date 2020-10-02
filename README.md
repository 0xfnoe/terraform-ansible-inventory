# Ansible config from terraform

This lifehack allows to use terraform output as ansible config

# Usage

```bash
cd terraform
terraform init
terraform apply -auto-approve
cd ..
ansible-playbook main.yml
```

# Details

Here is how it looks like:  
```console
$ terraform output -json ansible_inventory
{"myhosts":["1.2.3.4"]}
```