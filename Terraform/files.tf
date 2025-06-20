resource "local_file" "inventory" {
  content = <<-EOF
[bastion]
${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

[webservers]
%{for vm in yandex_compute_instance.web~}
${vm.network_interface[0].ip_address}
%{endfor~}

EOF

  filename = "../Ansible/hosts.ini"

}

resource "local_file" "ssh_config" {
  content = <<-EOF
Host bastion
  HostName ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

%{for vm in yandex_compute_instance.web~}
Host ${vm.network_interface[0].ip_address}
  HostName ${vm.network_interface[0].ip_address}
  ProxyJump bastion

%{endfor~}
EOF

  filename = "../Ansible/ssh_config"

}