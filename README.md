jc_crontab
==========

Sanger Journal Club the Ghost of Sergei Crontab

Once upon a time, long before my time, there was a Sanger PhD student called Sergei. As the story goes, Sergei was not good at attending the Jornal Club. In fact he never went at all. 
This annoyed the Journal Club Leaders, Annabel and Christina. Using their power as Leader, they tasked Sergei with not only attending the Journal Club, but making sure all the PhD's attended.

Sergei moaned and sulked for weeks until a bright idea hit him. Using all his resources he whipped up some magic, and the cron was born and he could never forget Jornal Club again.

Now at this time, the cron was a once-a-week generic message. 
Since then, new functions were requested and the script evolved over time.

Cronmasters changed and the years went by. But no-one forgot Journal Club ever again.

Usage
----------

The current scripts for this are in /nfs/users/nfs_r/rg12/jc_crontab/ and hosted on github at git@github.com:RGunning/jc_crontab.git

The main script send_jc_email.pl is all you really need. [WORKING ON INSTALL SCRIPT]
The old version also included some helper files (jc_dates, jc_email, jc_friday). The jc_dates files was more or less copied from here every quarter http://scratchy.internal.sanger.ac.uk/wiki/index.php/PhDJournalClub.

The crontab sends out messages on Fridays and Mondays. I have the crontab set on farm3-head3 now as follows:

    0 16 * * 5 /nfs/users/nfs_r/rg12/jc_crontab/send_jc_email.pl
    0 15 * * 1 /nfs/users/nfs_r/rg12/jc_crontab/send_jc_email.pl

Passing on
---------

When it is time to pass on the script, you should find a suitable apprentice receptive of the cron.

They should ideally 
1) know how cron works, 
2) maintain the legacy perl or update the code to fit the required spec, and 
3) be willing to swear a solemn oath that you won't correct the grammar or remove references to our dear past cron masters, Sergei, Lars and Dan and will furthermore require your successors to similarly keep the faith. 

A first or second year would be best. This their opportunity for university honor and acclaim.


