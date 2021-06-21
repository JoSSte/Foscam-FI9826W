# Editing Foscam Images

I have an aging foscam camera which I want to see if I can add functionality to, such as sftp support, and some triggers/rest functions

## Findings

System firmware         `WT8Nk*v2`  
Application firmware    `WWT8Nk*v2`  

Decrypted with: `openssl enc -d -aes-128-cbc -in imagename.bin -out decrypted.tgz -md md5 -k 'WWT8Nk*v2'`  

## Resources
* Decrypting Foscam FW image https://github.com/mcw0/PoC/blob/master/decrypt-foscam.py
* https://wiki.emacinc.com/wiki/Mounting_JFFS2_Images_on_a_Linux_PC
* Repacking jffs2 file system https://www.linuxsat-support.com/thread/86199-some-scripts-for-extracting-and-re-packing-e2jffs2-img-files/



## Status 
At this time, this epoonly contains files copied from other places to open the image. Altering and repacking

## Steps to editing an image
1. Decrypt firmware `python decrypt-foscam.py --infile image.bin`
1. Unpack unencrypted file `tar -zxf decrypted.bin`
1. Create dir for mounting `sudo mkdir /mnt/jffs2`
1. Mount jffs2 image to inspect contents and verify that contents are apropriate `sudo ./mount.sh decrypted/mtd.jffs2 /mnt/jffs2`

*These steps are hypothetical*  

5. Extract all files from image `...`
1. Add new files `unpack_2jffs2.sh ...`
1. Update jffs2 image  `repack_e2jffs2.sh ...`
1. Add md5sum to `fwupgrade.md5`
1. Ensure that `FWUpgradeConfig.xml` is correct
1. Repack tar.gz `tar ...`
1. Reencrypt `openssl ...`
1. Upload to camera and see if it works

