# -*- mode: ruby -*-
# vi: set ft=ruby :

vms = {
  'k8s-control-plane' => { 'memory' => '2048', 'cpus' => '2', 'ip' => '201', 'box' => 'debian/bookworm64', 'provision' => 'exec-control-plane.sh' },
  'k8s-worker01' => { 'memory' => '1024', 'cpus' => '1', 'ip' => '202', 'box' => 'debian/bookworm64', 'provision' => 'exec-worker.sh' },
  'k8s-worker02' => { 'memory' => '1024', 'cpus' => '1', 'ip' => '203', 'box' => 'debian/bookworm64', 'provision' => 'exec-worker.sh' }
}

Vagrant.configure('2') do |config|
    vms.each do |name, conf|
      config.vm.define "#{name}" do |my|
        my.vm.box = conf['box']
        my.vm.hostname = "#{name}.myhome.local"
        my.vm.network 'public_network', bridge: "enp8s0", ip: "192.168.3.#{conf['ip']}"
        my.vm.provision 'shell', path: "Provision/#{conf['provision']}"
        my.vm.provider 'virtualbox' do |vb|
          vb.memory = conf['memory']
          vb.cpus = conf['cpus']
          vb.customize ["modifyvm", :id, "--vram", "12"]
        end
      end  
  end
end

