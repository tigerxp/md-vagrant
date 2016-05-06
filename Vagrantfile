VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "debian/contrib-jessie64"
	config.vm.synced_folder ".", "/vagrant", :mount_options => ['dmode=777', 'fmode=666']
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, '--audio', 'alsa', '--audiocontroller', 'ac97']
    end
	config.vm.provision :shell, :path => "provision/os_setup.sh", keep_color: true
	config.vm.provision :shell, :path => "provision/app_setup.sh", keep_color: true
	config.vm.network :forwarded_port, host: 8888, guest: 80, auto_correct: true
	config.vm.network :forwarded_port, host: 8889, guest: 3306, auto_correct: true
end
