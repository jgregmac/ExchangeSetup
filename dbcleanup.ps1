#
"---------------------------------------"
"Creating database copies for DAG1-DB172"

Add-MailboxDatabaseCopy -Identity DAG1-DB172 -MailboxServer msx-tp02 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB172 -MailboxServer msx-mh04 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB172 -MailboxServer msx-mh02 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB173"

Add-MailboxDatabaseCopy -Identity DAG1-DB173 -MailboxServer msx-tp03 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB173 -MailboxServer msx-mh05 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB173 -MailboxServer msx-mh03 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB174"

Add-MailboxDatabaseCopy -Identity DAG1-DB174 -MailboxServer msx-tp04 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB174 -MailboxServer msx-mh06 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB174 -MailboxServer msx-mh04 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB175"

Add-MailboxDatabaseCopy -Identity DAG1-DB175 -MailboxServer msx-mh06 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB175 -MailboxServer msx-tp01 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB175 -MailboxServer msx-tp06 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB176"

Add-MailboxDatabaseCopy -Identity DAG1-DB176 -MailboxServer msx-mh01 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB176 -MailboxServer msx-tp02 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB176 -MailboxServer msx-tp01 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB177"

Add-MailboxDatabaseCopy -Identity DAG1-DB177 -MailboxServer msx-mh02 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB177 -MailboxServer msx-tp03 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB177 -MailboxServer msx-tp02 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB178"

Add-MailboxDatabaseCopy -Identity DAG1-DB178 -MailboxServer msx-mh03 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB178 -MailboxServer msx-tp04 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB178 -MailboxServer msx-tp03 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB179"

Add-MailboxDatabaseCopy -Identity DAG1-DB179 -MailboxServer msx-mh04 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB179 -MailboxServer msx-tp05 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB179 -MailboxServer msx-tp04 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB180"

Add-MailboxDatabaseCopy -Identity DAG1-DB180 -MailboxServer msx-mh05 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB180 -MailboxServer msx-tp06 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB180 -MailboxServer msx-tp05 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB181"

Add-MailboxDatabaseCopy -Identity DAG1-DB181 -MailboxServer msx-tp02 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB181 -MailboxServer msx-mh01 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB181 -MailboxServer msx-mh02 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB182"

Add-MailboxDatabaseCopy -Identity DAG1-DB182 -MailboxServer msx-tp03 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB182 -MailboxServer msx-mh02 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB182 -MailboxServer msx-mh03 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

#
"---------------------------------------"
"Creating database copies for DAG1-DB183"

Add-MailboxDatabaseCopy -Identity DAG1-DB183 -MailboxServer msx-tp04 -ActivationPreference 2 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB183 -MailboxServer msx-mh03 -ActivationPreference 3 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  0.00:00:00  -TruncationLagTime  0.00:00:00

Add-MailboxDatabaseCopy -Identity DAG1-DB183 -MailboxServer msx-mh04 -ActivationPreference 4 -DomainController cdc-tp01.campus.ad.uvm.edu -ReplayLagTime  14.0:00:00  -TruncationLagTime  0.0:00:00

