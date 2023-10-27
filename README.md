# MyFlec
```
         _nnnn_
        dGGGGMMb
       @p~qp~~qMb
       M|@||@) M|
       @,----.JM|
      JS^\__/  qKL
     dZP        qKRb
    dZP          qKKb
   fZP            SMMb
   HZM            MMMM
   FqM            MMMM
 __| ".        |\dS"qML
 |    `.       | `' \Zq
_)      \.___.,|     .'
\____   )MMMMMP|   .'
     `-'       `--'
```
My Favorite Linux Environment Configuration

For my Vim setup see [MyVim](https://github.com/log0u7/myvim).

# Installation

```bash
git clone https://github.com/log0u7/myflec
rsync -av --progress --exclude-from 'myflec/myflec.exclude.lst' myflec/ ~/
cat myflec/profile >> ~/.bashrc
. .bashrc
```
# Keep track
You may want to use git to keep track and of your own setup and backup it.

**! Use only private repository and/or dont track any unciphered secrets !*

- Copy `.gitignore` to your home, so git ignore all files except :

	```bash
	cp myflec/.gitignore ~/
	```
	_Note : You may want to remove exceptions from `.gitignore`_

- Initialize git repository :
	
	```bash
	git init
	git remote add origin your_repository_url
	git add *
	git commit -m "Initial sync to your_repository_url"
	git push -u origin main
	```
