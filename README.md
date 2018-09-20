# Run a Wordpress server on Vagrant / AWS / GCP 

install a churchinfo server with ubuntu 16.04, MySQL, apache2, php 5.6. 
make an aws s3 bucket as churchinfo media repository.

## Run on Vagrant
-. prep.
```
    - install vagrant
        https://www.vagrantup.com/downloads.html
    - install virtualbox
        https://www.virtualbox.org/

```
-. set up on vagrant
```
    git clone https://github.com/doohee323/tz-churchinfo
    cd tz-churchinfo
	vagrant destroy -f && vagrant up
	vagrant ssh
	cf. all scripts
		/tz-churchinfo/scripts/churchinfo.sh
```

-. set up on aws
```
	bash aws.sh
	cf. all scripts
		/tz-churchinfo/scripts/run_aws.sh
		/tz-churchinfo/scripts/churchinfo.sh
	cf. access to terminal after opening firewal for the ec2 instance
		cd ~/.ssh
		chmod 600 $PEM.pem
		ssh -i $PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS
```

## Run on GCP
-. prep.
```
	* connect to gcp instance with ssh
	# make gcp instanace with Ubuntu Server 16.04 LTS
	# make and register your public key in gcp metadata ssh

	e.g.
		sudo rm -Rf ~/.ssh/newnation*
		ssh-keygen -t rsa -C ubuntu@gmail.com -P "" -f ~/.ssh/newnation -q 
		chmod 400 ~/.ssh/newnation
		cat ~/.ssh/newnation.pub
		ssh -i ~/.ssh/newnation ubuntu@35.237.190.176 
	 
	export PRIKEY=newnation
	export GCP_IP_ADDRESS=35.237.190.176 
```

-. set up on GCP
```
	bash gcp.sh
	cf. all scripts
		/tz-churchinfo/scripts/run_gcp.sh
		/tz-churchinfo/scripts/churchinfo.sh
	cf. access to terminal after opening firewal for the gcp instance
		cd ~/.ssh
		chmod 600 $PEM
		ssh -i $PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS
```

-. configure a churchinfo server
```
	<for Vagrant>
		- http://192.168.82.170 
	<for AWS>
		- http://$AWS_EC2_IP_ADDRESS
		
	- id / password = admin/admin123
```

-. access to mysql
```
	<for Vagrant>
		mysql -h 192.168.82.170 -P 3306 -u root -p
	<for AWS>
		mysql -h $AWS_EC2_IP_ADDRESS -P 3306 -u root -p 
```

-. working directory
```
	/vagrant/churchinfo 
	1 minuite after changing any resources under /vagrant/churchinfo, /var/www/html will be synced.
	
	
	Test account:
		Admin / churchinfoadmin	
```



