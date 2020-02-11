-----------this is docker impl of the cloud image for photogrammetry---------

current docker images:  mattrayner/test ---------------dep mattrayner/lamp:latest-1604
			mattrayner/lamp:latest-1604

-----------------2/9/2020-------------------

(A) the docker image photo gallery works now.
there is no save image data now. to put some data @ /home/cc/photogrammetry:
	docker run --rm -p "3000:80" -v ${PWD}/app:/app -v ${PWD}/app2:/app2 -it mattrayner/test bash
	if need additional data on website:
		su -l cc
		cd ~/photogrammetry
		tar xvf /app/xxx.tar  
		   this untar a project tar into /home/cc/photogrammetry/
		exit (to root)
	./run3.sh
		this run the apache2
see "access url" 2/7/2020

(B) to run opendronemap (at docker image): 
	to keep the docker image small and easy to build, OpenDroneMap code and data are not part
		of the docker image, it must be mounted to /app2 when start container.
	start main container as above, then open a shell
	docker exec -it  ecstatic_goldstine bash
	su -l cc; cd /app2/OpenDroneMap;
		app2 is external folder /media/student/data3/vrx/docker/docker-lamp/app2 mounted when container start
		install required package (included in docker image so not required now. see section below)
		set environment variable (not required so far)
	./run.sh --rerun opensfm clover-hill-complex
	./run.sh --rerun-all projname
	ln -s /app2/clover-hill-complex clover-hill-complex 
		this link a proj fold from /app2 to /home/cc/photogrammetry/clover-hill-complex

------------------------ image gallery website trouble shooting --------------------
/var/www/html:
	photodata -> /home/cc/public_html/photodata ------------ drwxrwxr-x , thumbnail etc, generated/
	photogrammetry -> /home/cc/photogrammetry/           ----drwxrwxr-x , raw photo
/usr/lib/cgi-bin
	cgi-user1-photo ----- cgi scripts

------------------------ rebuild opendronemap steps -------------------------------------

app2 link to /media/student/data3/vrx/docker/docker-lamp/app2
app2/OpenDroneMap
vi /app2/OpenDroneMap/SuperBuild/src/mvstexturing/libs/tex/generate_texture_views.cpp
	line 154, change image_undistort_bundler to image_undistort_k2k4
	cd SuperBuild/build; rm -rf *; cmake ..; make
	cd OpenDroneMap/build; rm -rf *; cmake ..; make

------------------opendronemap set environment variable--------------------------------
add to /home/cc/.bashrc
    export PYTHONPATH=$PYTHONPATH:/your/path/OpenDroneMap/SuperBuild/install/lib/python2.7/dist-packages
    export PYTHONPATH=$PYTHONPATH:/your/path/OpenDroneMap/SuperBuild/src/opensfm
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/your/path/OpenDroneMap/SuperBuild/install/lib
--------------------opendronemap installed package in docker image---------------------------------------------------------
	based on configure.sh
	pip install exifread xmltodict
	apt-get install -y  libboost-date-time-dev libboost-python-dev libboost-filesystem-dev \
                         libboost-iostreams-dev \
                         libboost-regex-dev \
                         libboost-python-dev \
                         libboost-date-time-dev \
                         libboost-thread-dev \
--------------------opendronemap----------------------------------------------------------
install required package:
sudo apt-get install -y -qq python-empy \
                         python-nose \
                         python-pyside

sudo apt-get install -y  python-pyexiv2 \
                         python-scipy \
                         jhead \
                         liblas-bin
--------------------------------------------------------------------------------------
setup opendronemap:
	Run `bash configure.sh install`


-----------------2/7/2020-------------------


docker build -t=mattrayner/lamp:latest-1604 -f ./1604/Dockerfile .
docker build -t=mattrayner/test -f ./1604_bld2/Dockerfile .

docker run --rm -p "3000:80" -v ${PWD}/app:/app mattrayner/test 
docker run --rm -p "3000:80" -it mattrayner/test bash


access url:
	http://172.17.0.2/cgi-bin/cgi-user1-photo/protected/manage.cgi?mode=manage
	ok. setup the ip address at the "Setup and Configuration", default is 172.17.0.2

http://129.114.32.39/cgi-bin/cgi-user1-photo/simple.pl, 
	this require mysql setup and running, webapp.session not exist, 

setup mysql user:
	goto http://172.17.0.2/phpmyadmin
	login: admin, passwd randomly generated and displayed when run.sh
	create database webapp
	create user webadmin, nopasswd
mysqldump -u webadmin -p webapp >~/webapp-dump.mysql
apt install -y libjpeg-progs

/var/log/apache2# more error.log

copy apache2.conf
copy /sites-available/000-default.conf
sudo a2enmod cgi.load
sudo a2enmod cgid.load
sudo service apache2 reload
chown -R www-data:www-data /usr/lib/cgi-bin

RUN chmod -R 777 /home/cc/photo
RUN chmod -R 777 /home/cc/photogrammetry
RUN chmod -R 777 /home/cc/public_html
ln -s /home/cc/public_html/photodata /var/www/photodata
ln -s /home/cc/photogrammetry /var/www/photogrammetry

http://172.17.0.2/photodata


apt pkg 
apt install libcgi-application-perl bash-completion
apt-config dump | grep "Dir::Cache"
/etc/apt/apt.conf.d/
Dir::Cache::pkgcache "";
sudo vi /etc/apt/apt.conf.d/docker-clean
/var/cache/apt/pkgcache.bin

-------------opendronemap ----------
build not yet succ.

