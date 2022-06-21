# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "debian/bullseye64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "private_network", ip: "192.168.200.110"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y vim git
    mkdir -p /srv/git
    git init --bare /srv/git/nft-firewall.git
    git clone https://github.com/aborrero/nftables-managed-with-git
    cp nftables-managed-with-git/git_hooks/* /srv/git/nft-firewall.git/hooks/
    mkdir -p /etc/nftables.d
    cp nftables-managed-with-git/sudo_policy/nft-git /etc/sudoers.d/
    sed -i 's/user1, user2/vagrant/' /etc/sudoers.d/nft-git
    cp -r nftables-managed-with-git/nft_ruleset ~vagrant/fw
    chown vagrant. /srv/git/nft-firewall.git /etc/nftables.d ~vagrant/fw -R
    mkdir -p /etc/systemd/system/nftables.service.d/
    cp /vagrant/nftables-override.conf /etc/systemd/system/nftables.service.d/override.conf
    systemctl daemon-reload
  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-UNPRIVILEGED
    git config --global user.email 'icaro@devops-sama.com.br'
    git config --global user.name 'Icaro'
    cd fw; \
      git init; \
      git add .; \
      git commit -m 'Initial Commit'; \
      git remote add origin /srv/git/nft-firewall.git; \
      git push -u origin master
  UNPRIVILEGED

  config.vm.provision "shell", inline: <<-SYSTEMD
    systemctl enable nftables --now
  SYSTEMD

  config.push.define "local-exec" do |push|
    push.inline = <<-SCRIPT
      mkdir -p local
      vagrant ssh-config > local/ssh-config
      cd local; \
      export GIT_SSH_COMMAND="ssh -F ssh-config"; \
      git clone ssh://default/srv/git/nft-firewall.git gitfw; \
      cp fw_model/* gitfw/; cd gitfw; \
      export GIT_SSH_COMMAND="ssh -F ../ssh-config"; \
      git add .; \
      git commit -m 'feat: basic firewall' \
        -m 'features:' \
        -m '- blackhole: drop all' \
        -m '- filter local (with clients) and public services'; \
      git push
    SCRIPT
  end
end

