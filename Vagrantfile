# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['ANSIBLE_CALLBACK_RESULT_FORMAT'] = 'yaml'

PROJECT = PRJ = :psql

DEFAULT_MACHINE = {
  :domain => 'internal',
  :box => 'bento/ubuntu-24.04/202502.21.0',
  :cpus => 1,
  :memory => 1024,
  :disks => {},
  :networks => {},
  :intnets => {},
  :forwarded_ports => [],
  :modifyvm => []
}

GROUPS = {
  :backend => {
    :"#{PRJ}-backend-01" => {
      :memory => 2048,
      :networks => { :private_network => { :ip => '192.168.56.21' } },
    },
    :"#{PRJ}-backend-02" => {
      :memory => 2048,
      :networks => { :private_network => { :ip => '192.168.56.22' } },
    },
    :"#{PRJ}-backend-03" => {
      :memory => 2048,
      :networks => { :private_network => { :ip => '192.168.56.23' } },
    },
  }
}
MACHINES = GROUPS.values.each_with_object({}) { |m, o| o.merge!(m) }
ANSIBLE_GROUPS = GROUPS.to_h{ |k, v| [k, v.keys()] }
ANSIBLE_HOSTVARS = MACHINES.each_with_object({}) {
  |kv, obj| obj[kv[0]] = {
    'ip_address' => kv[1][:networks][:private_network][:ip],
  }
}

def provisioned?(host_name)
  return File.exist?('.vagrant/machines/' + host_name.to_s +
    '/virtualbox/action_provision')
end

Vagrant.configure('2') do |config|
  MACHINES.each do |host_name, host_config|
    host_config = DEFAULT_MACHINE.merge(host_config)
    config.vm.define host_name do |host|
      host.vm.box = host_config[:box]
      if not provisioned?(host_name)
        host.vm.host_name = host_name.to_s + '.' + host_config[:domain].to_s
      end

      host.vm.provider :virtualbox do |vb|
        vb.cpus = host_config[:cpus]
        vb.memory = host_config[:memory]

        if !host_config[:modifyvm].empty?
          vb.customize ['modifyvm', :id] + host_config[:modifyvm]
        end
      end

      host_config[:disks].each do |name, size|
        host.vm.disk :disk, name: name.to_s, size: size
      end

      host_config[:intnets].each do |name, intnet|
        intnet[:virtualbox__intnet] = name.to_s
        host.vm.network(:private_network, **intnet)
      end
      host_config[:networks].each do |network_type, network_args|
        host.vm.network(network_type, **network_args)
      end
      host_config[:forwarded_ports].each do |forwarded_port|
        host.vm.network(:forwarded_port, **forwarded_port)
      end

      if MACHINES.keys.last == host_name
        host.vm.provision :ansible do |ansible|
          ansible.playbook = 'provision.yml'
          ansible.groups = ANSIBLE_GROUPS
          ansible.host_vars = ANSIBLE_HOSTVARS
          ansible.limit = 'all'
          ansible.compatibility_mode = '2.0'
          ansible.raw_arguments = ['--diff']
          ansible.tags = 'all'
        end
      end

      host.vm.synced_folder '.', '/vagrant', disabled: true
    end
  end
end
