#! /usr/bin/bash

#dnf update -y 
dnf install -y mdadm vim parted mc

wipefs --all --force /dev/sd{b,c,d,e}
mdadm --zero-superblock --force /dev/sd{b,c,d,e}

# Create RAID10: 
mdadm --create --verbose /dev/md10 -l 10 -n 4 /dev/sd{b,c,d,e}

# Save mdadm.conf:
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# Create GPT on RAID:
parted -s /dev/md10 mklabel gpt
# Create partitions:
parted /dev/md10 mkpart primary ext4 0% 20%
parted /dev/md10 mkpart primary ext4 20% 40%
parted /dev/md10 mkpart primary ext4 40% 60%
parted /dev/md10 mkpart primary ext4 60% 80%
parted /dev/md10 mkpart primary ext4 80% 100%

# Make FS on partiotions:
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md10p$i; done

# Mount partitions & write it in /etc/fstab:
mkdir -p /mnt/raid10/part{1,2,3,4,5}
for i in $(seq 1 5)
do
  mount /dev/md10p$i /mnt/raid10/part$i
  echo "/dev/md10p$i /mnt/raid10/part$i ext4 defaults 0 0" >> /etc/fstab
done
