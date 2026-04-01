1. The player will take the public snapshot ID (snap-0ee74f7d82b77d8ec) and use the AWS CLI or console to search for it.

2. Create a new EBS volume from the snapshot in their own AWS account.

3. Launch an EC2 instance in the same Availability Zone.

4. They will attach the newly created volume to their instance.

5. They will SSH into their instance and mount the volume to a directory.

- Mount the Volume and Find the Flag:
Since the snapshot was taken from a root volume, the volume already has a fully functional Linux filesystem on it.

    - Action: They SSH into their recovery EC2 instance and mount the attached volume.

    - Check the name of the volumes attached - run `lsblk` inside EC2 terminal

    - Create Mount Point: `sudo mkdir /mnt/secret_data`

    - Mount: `sudo mount /dev/xvdf1 /mnt/secret_data`
    Use partition name not the disk.

    - Change Directory: `cd /mnt/secret_data`

    - Search (Knowing your hint): Since they know it was a root volume, they will look in system folders where you placed the flag, such as the one we defined: `cat /mnt/secret_data/var/log/flag.txt`