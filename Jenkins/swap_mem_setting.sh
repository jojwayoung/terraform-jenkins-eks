#!/bin/bash

# 1. 스왑 파일 생성 (2GB: 128MB x 16)
sudo dd if=/dev/zero of=/swapfile bs=128M count=16 # 2GB
#sudo dd if=/dev/zero of=/swapfile bs=128M count=8 # 1GB

# 2. 스왑 파일 권한 설정
sudo chmod 600 /swapfile

# 3. 스왑 영역 설정
sudo mkswap /swapfile

# 4. 스왑 활성화
sudo swapon /swapfile

# 5. 재부팅 시 자동 활성화 설정 (/etc/fstab 등록)
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# 6. 결과 확인
free -h
