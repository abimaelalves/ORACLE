# $Header: rman_full_bkp.sh
# *====================================================================================+
# |  Author - DBACLASS ADMIN TEAM
# |                                                       |
# +====================================================================================+
# |
# | DESCRIPTION
# |     Take rman full backup(incremental level 0 )
# | PLATFORM
# |     Linux/Solaris/HP-UX

# +===========================================================================+
#!/bin/bash
RMANBACKUP_MOUNTPOINT1=/u01/app/oracle/rman_bkp/backups
PARALLELISM=4
MAXPIECESIZE=3g
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/db_1
export ORACLE_SID=TURBDEV
export PATH=$ORACLE_HOME/bin:$PATH

fullBackup () {
rman log=/u01/app/oracle/rman_bkp/logs/RMANFULL.log << EOF
connect target /
set echo on;
configure backup optimization on;
configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to '$RMANBACKUP_MOUNTPOINT1/%F';
configure maxsetsize to unlimited;
configure device type disk parallelism $PARALLELISM;
run{
allocate channel c1 device type disk;
allocate channel c2 device type disk;
backup as compressed backupset archivelog all tag 'ARCH_FULL' format '/u01/app/oracle/rman_bkp/backups/ARCH_FULL-%T-%I-%d-%s.bkp';
backup as compressed backupset full database tag 'Full_Banco' format '/u01/app/oracle/rman_bkp/backups/Full_banco-%T-%I-%d-%s.bkp';
backup as compressed backupset archivelog all tag 'ARCH_FULL' format '/u01/app/oracle/rman_bkp/backups/ARCH_FULL-%T-%I-%d-%s.bkp';
backup current controlfile tag 'CTF_FULL' format '/u01/app/oracle/rman_bkp/backups/CTF_FULL-%T-%I-%d-%s.bkp';
backup as compressed backupset spfile tag 'SPF_FULL' format '/u01/app/oracle/rman_bkp/backups/SPF_FULL-%T-%I-%d-%s.bkp';
backup as compressed backupset archivelog all tag 'ARCH_FULL' format '/u01/app/oracle/rman_bkp/backups/ARCH_FULL-%T-%I-%d-%s.bkp';
}
configure backup optimization clear;
configure controlfile autobackup clear;
sql 'alter system archive log current';
exit
EOF
}


find $RMANBACKUP_MOUNTPOINT1 -ctime +0 -exec rm -rf "{}" \; # removendo backup com mais de 1 dia, mantendo apenas o atual backup

# Main

fullBackup
