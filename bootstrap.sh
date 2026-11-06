#!/bin/bash
apt-get update -y
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker acumenadmin

sleep 10
for i in 1 2; do
  mkdir -p /data${i}
done

DISKS=($(lsblk -dn -o NAME,SIZE | awk '$2=="10G" {print "/dev/"$1}'))
for idx in "${!DISKS[@]}"; do
  DISK="${DISKS[$idx]}"
  MNT="/data$((idx+1))"
  if ! blkid "$DISK"; then
    mkfs.ext4 -F "$DISK"
  fi
  mount "$DISK" "$MNT"
  chown -R acumenadmin:acumenadmin "$MNT"
done

docker rm -f minio-cluster minio-eval 2>/dev/null || true
docker run -d -p 9000:9000 -p 9001:9001 --restart=always \
  -e "MINIO_ROOT_USER=acumenadmin" \
  -e "MINIO_ROOT_PASSWORD=AcumenStorage2026!" \
  -v /data1:/data1 \
  -v /data2:/data2 \
  --name minio-cluster \
  pgsty/silo:RELEASE.2026-10-26T00-00-00Z server http://10.0.2.{4...5}:9000/data{1...2} --console-address ":9001"
