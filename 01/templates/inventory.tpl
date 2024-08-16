[all]
%{ for host in backend_hosts ~}
${host.name} ansible_host=${host.default_ipv4_address} ansible_user=akopalev
%{ endfor ~}

[backend_hosts]
%{ for host in backend_hosts ~}
${host.name}
%{ endfor ~}
