[all]
%{ for host in bast_host ~}
${host.name} ansible_host=${host.default_ipv4_address} ansible_user=akopalev
%{ endfor ~}
%{ for host in backend_hosts ~}
${host.name} ansible_host=${host.default_ipv4_address} ansible_user=akopalev
%{ endfor ~}
%{ for host in db_hosts ~}
${host.name} ansible_host=${host.default_ipv4_address} ansible_user=akopalev
%{ endfor ~}

[bast_host]
%{ for host in bast_host ~}
${host.name} ansible_host=${host.default_ipv4_address} ansible_user=akopalev
%{ endfor ~}

[backend_hosts]
%{ for host in backend_hosts ~}
${host.name} ansible_host=${host.default_ipv4_address} ansible_user=akopalev
%{ endfor ~}
[backend_hosts:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q bastion_ask"'

[db_hosts]
%{ for host in db_hosts ~}
${host.name} ansible_host=${host.default_ipv4_address} ansible_user=akopalev
%{ endfor ~}
[db_hosts:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q bastion_ask"'