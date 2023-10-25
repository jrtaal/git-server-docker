# git-server
A lightweight Git Server Docker image built with Alpine Linux.

!["image git server docker" "git server docker"](https://raw.githubusercontent.com/cedricfarinazzo/git-server-docker/master/git-server-docker.jpg)

This image supports both read-write and read-only access. The `git` user has readonly access and the `gitrw` has readwrite access to the same repos.

The repos should be stored under /home/git/repo.

## Basic Usage

This GIT server allows to sets of keys, readonly keys and readwrite keys.

- readonly keys are stored in `/git-server/ro-keys` and are assigned to the `git` users.
- readwrite keys are stored in `/git-server/rw-keys` and are assigned to the `gitrw` users.


How to run the container in port 2222 with three volumes: two keys volumes for public keys and a repos volume for git repositories:

	$ docker run -d -p 2222:22 \
	    -v ./ro-keys:/git-server/ro-keys \
	    -v ./rw-keys:/git-server/rw-keys \
		-v ./repo:/home/git/repo jrtaal/git-server-docker

### How to use an existing public key:

Copy them to ro-keys folder: 
- From host: `$ cp ~/.ssh/id_rsa.pub ~/git-server/ro-keys`

Or, for a readwrite key: Copy them to rw-keys folder:
- From host: `$ cp ~/.ssh/id_rsa.pub ~/git-server/rw-keys`


You need restart the container when keys are updated:

	$ docker restart <container-id>
	
How to check that container works (you must to have a key):

	$ ssh git@<ip-docker-server> -p 2222
	...
	Welcome to git-server-docker!
	You've successfully authenticated, but I do not
	provide interactive shell access.
	...

How to create a new repo:

	$ cd myrepo
	$ git init --shared=true
	$ git add .
	$ git commit -m "my first commit"
	$ cd ..
	$ git clone --bare myrepo myrepo.git

How to upload a repo:

From host:

	$ mv myrepo.git ~/home/git/repo

From remote:

	$ scp -r myrepo.git user@host:~/home/git/repo

How clone a repository:

	$ git clone ssh://git@<ip-docker-server>:2222/home/git/repo/myrepo.git

### Pushing

Pushing can only be done using a readwrite key:

First add a new git remote using the readwrite key

    $ git remote add rw ssh://gitrw@<ip-docker-server>:2222/home/git/repo/myrepo.git
	$ git push rw <branch>


### Arguments

* **Expose ports**: 22
* **Volumes**:
  * `/git-server/ro-keys`: Volume to store the readonly public keys
  * `/git-server/rw-keys`: Volume to store the readwrite public keys
  * `/home/git/repo`: Volume to store the repositories

### SSH Keys

How generate a pair keys on a client machine:

	$ ssh-keygen -t rsa -f <name>

This generates a private-public key pair. The private part needs to be used on the client (git) side. The public part (*.pub) has to be installed in the proper directory on the git-sever (ro-keys or rw-keys), see above.

### Build Image

How to make the image:

	$ docker build -t git-server .

### Docker-Compose

You can edit docker-compose.yml and run this container with docker-compose:

	$ docker-compose up -d



# Attribution
This project was forked from github.com/jkarlosb/git-server-docker

I added support for readwrite and readonly keys.