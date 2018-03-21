# GitAutomation

Usage of Script must be done according to below points:

1) Usage --->   sh copyToGit.sh <xml_file_containing_parameters> <input_file_containing_filenames>
2) sample xml_file and input file are attached.
3) First the script validates at required parameters have been passed.
4) Then it checks whether user has permission to access github via ssh.
5) If ssh Login gives 'Permission Denied' then it is required to setup ssh key with your github account and then run again.
   It's a one time activity. To setup ssh key follow the below links : 
   https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
   https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/
   
6) After authentication , all the variables are assigned getting the values from xml file
7) Then it is checked if the url set under config is the same as the one passed in XML file( only SSH url , not https ).
8) Then existence of the branh specified in xml_file is checked. If yes, it is checked out.
9) Then all the entries in input_file.txt are copied to the Target dir with the same directory structure as the source.
10) All the files are added , commited( user is prompted for commit message )
11) All the changes are pushed to the repository.

The above development was done on Cloudera VM and thus further testing is required on paypal environment.
We might need to change some of the parameters.

Example xml_file: 

<parameters>
<name>HOME_DIR</name>
<value>/home/Lenovo/Source/swift</value>
<name>TARGET_DIR</name>
<value>/home/Lenovo/Target/swift</value>
<name>REPO</name>
<value>git@github.com:teamclairvoyant/GitAutomation.git</value>
<name>BRANCH</name>
<value>master</value>
</parameters>

Example input_file:

bin/in/daily.txt
bin/auto.txt
etc/hadoop/conf.txt

Whatever structure is given in input file same is copied from Source to the Target and then checked into the Git repo.
