# -*- mode: ruby -*-
# vi: set ft=ruby :

ipaddress = "192.168.178.10"
domain = "unlp.edu"

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = "mail.#{domain}"

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "postgrado_ubuntu-12.04"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://vagrantbox.unlp.edu.ar/ubuntu-12.04.2-cespi-amd64.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: ipaddress

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # config.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []
  #

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :locales => {
        :available => [ "es_ES.UTF-8 UTF-8", "es_AR.UTF-8 UTF-8", "es_ES.ISO-8859-1 ISO-8859-1"]
      },
      :authorization => {
        :sudo => {
          :groups => ['sudo'],
          :passwordless => true
        }
      },
      :resolver => {
        :nameservers => [ "127.0.0.1" ],
        "search" => domain,
        "options" => {
          "timeout" => 2, "rotate" => nil
        }
      },
      :postfix => {
          :mail_relay_networks => nil, #"10.3.3.0/24",
          :mail_type => "master",
          :extradomains => "mail.#{domain}",
          :mydomain => domain,
          :myorigin => domain,
          :myhostname => domain,
          :use_procmail => true
      },
      :distribuidos => {
        :my_ipaddress => ipaddress,
        :slave_zones => { 
          'acme.com' => {
            :masters => "192.168.178.100"
          }
        },
        :zones => {
          domain => {
            :ns => %w( ns.acme.com. ),
            :mx => [{ :priority => 1, :host => 'mail'}],
            :records => [
              {:name => 'mail', :type => 'A', :ip => ipaddress }
            ]
          }
        }
      }
    }

    chef.run_list = [
        "recipe[apt]",
        "recipe[locales]",
        "recipe[sudo]",
        "recipe[unlp.edu::default]",
        "recipe[postfix::server]",
        "recipe[resolver]"
    ]
  end
end
