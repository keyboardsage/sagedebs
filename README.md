# sagedebs
Personal APT Repo  
  
I am not a fan of having loose files running around my system.  
So this is an APT repo for storing deb files not already in my APT repo.  

# How to use
1. Make sure you have *git* and *dpkg-dev* installed
2. Clone or download this repo (`git clone https://github.com/keyboardsage/sagedebs`)
3. Execute ./sagerepo.sh (`sudo ./sagerepo.sh`)
4. Now you can install apps contained in the repo (ex: `sudo apt-get install synergy`)
5. Repeat the process periodically (weekly, monthly...whatever), since new debs get added
