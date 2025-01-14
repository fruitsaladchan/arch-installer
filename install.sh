#!/bin/bash
clear

echo -ne "

 ▄▄▄       ██▀███   ▄████▄   ██░ ██                                        
▒████▄    ▓██ ▒ ██▒▒██▀ ▀█  ▓██░ ██▒                                       
▒██  ▀█▄  ▓██ ░▄█ ▒▒▓█    ▄ ▒██▀▀██░                                       
░██▄▄▄▄██ ▒██▀▀█▄  ▒▓▓▄ ▄██▒░▓█ ░██                                        
 ▓█   ▓██▒░██▓ ▒██▒▒ ▓███▀ ░░▓█▒░██▓                                       
 ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ░▒ ▒  ░ ▒ ░░▒░▒                                       
  ▒   ▒▒ ░  ░▒ ░ ▒░  ░  ▒    ▒ ░▒░ ░                                       
  ░   ▒     ░░   ░ ░         ░  ░░ ░                                       
      ░  ░   ░     ░ ░       ░  ░  ░                                       
                   ░                                                       
 ██▓ ███▄    █   ██████ ▄▄▄█████▓ ▄▄▄       ██▓     ██▓    ▓█████  ██▀███  
▓██▒ ██ ▀█   █ ▒██    ▒ ▓  ██▒ ▓▒▒████▄    ▓██▒    ▓██▒    ▓█   ▀ ▓██ ▒ ██▒
▒██▒▓██  ▀█ ██▒░ ▓██▄   ▒ ▓██░ ▒░▒██  ▀█▄  ▒██░    ▒██░    ▒███   ▓██ ░▄█ ▒
░██░▓██▒  ▐▌██▒  ▒   ██▒░ ▓██▓ ░ ░██▄▄▄▄██ ▒██░    ▒██░    ▒▓█  ▄ ▒██▀▀█▄  
░██░▒██░   ▓██░▒██████▒▒  ▒██▒ ░  ▓█   ▓██▒░██████▒░██████▒░▒████▒░██▓ ▒██▒
░▓  ░ ▒░   ▒ ▒ ▒ ▒▓▒ ▒ ░  ▒ ░░    ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░░░ ▒░ ░░ ▒▓ ░▒▓░
 ▒ ░░ ░░   ░ ▒░░ ░▒  ░ ░    ░      ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░ ░ ░  ░  ░▒ ░ ▒░
 ▒ ░   ░   ░ ░ ░  ░  ░    ░        ░   ▒     ░ ░     ░ ░      ░     ░░   ░ 
 ░           ░       ░                 ░  ░    ░  ░    ░  ░   ░  ░   ░     

           ╔════════════════════════════════════════════════════╗
           ║              Version 1.0 - By fruitsaladchan       ║
           ╚════════════════════════════════════════════════════╝


Checking Arch Linux ISO.....
"
sleep 1
echo -ne "
checking distro....
"
echo -ne "
checking pacman ....
"
if [ ! -f /usr/bin/pacstrap ]; then
  echo "script must be run from an arch ISO environment."
  exit 1
fi

root_check() {
  if [[ "$(id -u)" != "0" ]]; then
    echo -ne "ERROR! This script must be run under the 'root' user!\n"
    exit 0
  fi
}

arch_check() {
  if [[ ! -e /etc/arch-release ]]; then
    echo -ne "ERROR! This script is for Arch Linux!\n"
    exit 0
  fi
}

pacman_check() {
  if [[ -f /var/lib/pacman/db.lck ]]; then
    echo "ERROR! Pacman is blocked."
    exit 0
  fi
}

background_checks() {
  root_check
  arch_check
  pacman_check
}

select_option() {
  local options=("$@")
  local num_options=${#options[@]}
  local selected=0
  local last_selected=-1

  while true; do
    if [ $last_selected -ne -1 ]; then
      echo -ne "\033[${num_options}A"
    fi

    if [ $last_selected -eq -1 ]; then
      echo "
            "
    fi
    for i in "${!options[@]}"; do
      if [ "$i" -eq $selected ]; then
        echo "> ${options[$i]}"
      else
        echo "  ${options[$i]}"
      fi
    done

    last_selected=$selected

    read -rsn1 key
    case $key in
      $'\x1b') # ESC sequence
        read -rsn2 -t 0.1 key
        case $key in
          '[A') # Up arrow
            ((selected--))
            if [ $selected -lt 0 ]; then
              selected=$((num_options - 1))
            fi
            ;;
          '[B') # Down arrow
            ((selected++))
            if [ $selected -ge $num_options ]; then
              selected=0
            fi
            ;;
        esac
        ;;
      'k') # Vim up (k)
        ((selected--))
        if [ $selected -lt 0 ]; then
          selected=$((num_options - 1))
        fi
        ;;
      'j') # Vim down (j)
        ((selected++))
        if [ $selected -ge $num_options ]; then
          selected=0
        fi
        ;;
      '') # Enter key
        break
        ;;
    esac
  done

  return $selected
}

logo() {
  echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                  System Settings                   ║
           ╚════════════════════════════════════════════════════╝
"
}
filesystem() {
  echo -ne "
    Select your file system (boot and root)
    "
  options=("btrfs" "ext4" "luks" "exit")
  select_option "${options[@]}"

  case $? in
    0) export FS=btrfs ;;
    1) export FS=ext4 ;;
    2)
      set_password "LUKS_PASSWORD"
      export FS=luks
      ;;
    3) exit ;;
    *)
      echo "Wrong option please select again"
      filesystem
      ;;
  esac
}
timezone() {
  time_zone="$(curl --fail https://ipapi.co/timezone)"
  echo -ne "
    System detected your timezone to be '$time_zone' \n"
  echo -ne "Is this correct?
    "
  options=("Yes" "No")
  select_option "${options[@]}"

  case ${options[$?]} in
    y | Y | yes | yEs | yeS | YEs | yES | Yes | YES)
      echo "${time_zone} set as timezone"
      export TIMEZONE=$time_zone
      ;;
    n | N | no | nO | NO | No)
      echo "Please enter your timezone e.g. Europe/London :"
      read -r new_timezone
      echo "${new_timezone} set as timezone"
      export TIMEZONE=$new_timezone
      ;;
    *)
      echo "Wrong option. Try again"
      timezone
      ;;
  esac
}
keymap() {
  echo -ne "
    Please select key board layout from this list"
  options=(us by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru se sg ua uk)

  select_option "${options[@]}"
  keymap=${options[$?]}

  echo -ne "Your key boards layout: ${keymap} \n"
  export KEYMAP=$keymap
}

drivessd() {
  echo -ne "
    Is this an ssd? yes/no:
    "

  options=("Yes" "No")
  select_option "${options[@]}"

  case ${options[$?]} in
    y | Y | yes | Yes | YES)
      export MOUNT_OPTIONS="noatime,compress=zstd,ssd,commit=120"
      ;;
    n | N | no | NO | No)
      export MOUNT_OPTIONS="noatime,compress=zstd,commit=120"
      ;;
    *)
      echo "Wrong option. Try again"
      drivessd
      ;;
  esac
}

diskpart() {
  echo -ne "

           ╔════════════════════════════════════════════════════╗
           ║  WARNING!!!                                        ║ 
           ║  this will format and wipe all data on the drive   ║
           ╚════════════════════════════════════════════════════╝

"

  PS3='
    Select the disk to install on: '
  options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))

  select_option "${options[@]}"
  disk=${options[$?]%|*}

  echo -e "\n${disk%|*} selected \n"
  export DISK=${disk%|*}

  drivessd
}

userinfo() {
  echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                    User Config                     ║
           ╚════════════════════════════════════════════════════╝
"
  while true; do
    read -r -p "
    Please enter username: " username
    if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then
      break
    fi
    echo "    Incorrect username."
  done
  export USERNAME=$username

  while true; do
    echo -ne "\n"
    read -rs -p "    Please enter password: " PASSWORD1
    echo -ne "\n"
    read -rs -p "    Please re-enter password: " PASSWORD2
    echo -ne "\n"
    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
      break
    else
      echo -ne "    ERROR! Passwords do not match. \n"
    fi
  done
  export PASSWORD=$PASSWORD1

  while true; do
    echo -ne "\n"
    read -r -p "    Enter hostname: " name_of_machine
    if [[ "${name_of_machine,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]; then
      break
    fi
    read -r -p "    Hostname doesn't seem correct. Force save it? (y/n) " force
    if [[ "${force,,}" = "y" ]]; then
      break
    fi
  done
  export NAME_OF_MACHINE=$name_of_machine
}

swapsize() {
  echo -ne "

           ╔════════════════════════════════════════════════════╗
           ║                      Swap Config                   ║
           ╚════════════════════════════════════════════════════╝

"
  echo -ne "
    Do you want to create a swap partition?
    "
  options=("Yes" "No")
  select_option "${options[@]}"

  case ${options[$?]} in
    Yes)
      echo -ne "\n    Enter swap size in GB (e.g. 4): "
      read -r swap_size
      if [[ $swap_size =~ ^[0-9]+$ ]]; then
        export SWAP_SIZE=$swap_size
        export CREATE_SWAP=true
      else
        echo "    Invalid input. Skipping swap partition creation."
        export CREATE_SWAP=false
      fi
      ;;
    No)
      export CREATE_SWAP=false
      ;;
    *)
      echo "    Wrong option. Try again"
      swapsize
      ;;
  esac
}

desktop_env() {
  echo -ne "

           ╔════════════════════════════════════════════════════╗
           ║                Desktop Environment                 ║
           ╚════════════════════════════════════════════════════╝
"
  echo -ne "
    Select your desktop environment / window manager:
    "
  options=("KDE Plasma" "GNOME" "XFCE" "i3" "Hyprland" "None")
  select_option "${options[@]}"

  case ${options[$?]} in
    "KDE Plasma")
      export DE="kde"
      export DE_PACKAGES="plasma-meta konsole dolphin ark spectacle gwenview okular plasma-wayland-session"
      ;;
    "GNOME")
      export DE="gnome"
      export DE_PACKAGES="gnome gnome-tweaks gnome-terminal"
      ;;
    "XFCE")
      export DE="xfce"
      export DE_PACKAGES="xfce4 xfce4-goodies"
      ;;
    "i3")
      export DE="i3"
      export DE_PACKAGES="i3-wm i3blocks i3lock i3status dmenu rxvt-unicode"
      ;;
    "Hyprland")
      export DE="hyprland"
      export DE_PACKAGES="hyprland waybar wofi kitty"
      ;;
    "None")
      export DE="none"
      export DE_PACKAGES=""
      ;;
    *)
      echo "    Wrong option. Try again"
      desktop_env
      ;;
  esac
}

display_manager() {
  if [[ "${DE}" != "none" ]]; then
    echo -ne "

           ╔════════════════════════════════════════════════════╗
           ║                   Display Manager                  ║
           ╚════════════════════════════════════════════════════╝

"
    echo -ne "
    Select your display manager:
    "
    options=("GDM" "SDDM" "LightDM" "None")
    select_option "${options[@]}"

    case ${options[$?]} in
      "GDM")
        export DM="gdm"
        export DM_PACKAGES="gdm"
        ;;
      "SDDM")
        export DM="sddm"
        export DM_PACKAGES="sddm"
        ;;
      "LightDM")
        export DM="lightdm"
        export DM_PACKAGES="lightdm lightdm-gtk-greeter"
        ;;
      "None")
        export DM=""
        export DM_PACKAGES=""
        ;;
      *)
        echo "    Wrong option. Try again"
        display_manager
        ;;
    esac
  else
    export DM=""
    export DM_PACKAGES=""
  fi
}

# Main installation sequence
background_checks
userinfo
clear
swapsize
clear
desktop_env
clear
display_manager
clear
diskpart
clear
filesystem
clear
timezone
clear
keymap

iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -Sy
pacman -S --noconfirm archlinux-keyring
pacman -S --noconfirm --needed pacman-contrib terminus-font
setfont ter-v18b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║               Setting up $iso mirrors              ║
           ╚════════════════════════════════════════════════════╝

"
reflector -a 48 -c "$iso" -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
if [ ! -d "/mnt" ]; then
  mkdir /mnt
fi
echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║              Installing Prerequisites              ║
           ╚════════════════════════════════════════════════════╝

"
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc
echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                  Formatting Disk                   ║
           ╚════════════════════════════════════════════════════╝

"
umount -A --recursive /mnt
sgdisk -Z "${DISK}"
sgdisk -a 2048 -o "${DISK}"

sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' "${DISK}"
sgdisk -n 2::+1GiB --typecode=2:ef00 --change-name=2:'EFIBOOT' "${DISK}"

if [[ "${CREATE_SWAP}" == "true" ]]; then
  sgdisk -n 3::+"${SWAP_SIZE}"GiB --typecode=3:8200 --change-name=3:'SWAP' "${DISK}"
  sgdisk -n 4::-0 --typecode=4:8300 --change-name=4:'ROOT' "${DISK}"
else
  sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' "${DISK}"
fi

if [[ ! -d "/sys/firmware/efi" ]]; then
  sgdisk -A 1:set:2 "${DISK}"
fi
partprobe "${DISK}"

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                 Creating Filesystem                ║
           ╚════════════════════════════════════════════════════╝

"
createsubvolumes() {
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
}

mountallsubvol() {
  mount -o "${MOUNT_OPTIONS}",subvol=@home "${partition3}" /mnt/home
}

subvolumesetup() {
  createsubvolumes
  umount /mnt
  mount -o "${MOUNT_OPTIONS}",subvol=@ "${partition3}" /mnt
  mkdir -p /mnt/home
  mountallsubvol
}

if [[ "${DISK}" =~ "nvme" ]]; then
  partition2=${DISK}p2
  if [[ "${CREATE_SWAP}" == "true" ]]; then
    partition3=${DISK}p3
    partition4=${DISK}p4
    root_partition=$partition4
  else
    partition3=${DISK}p3
    root_partition=$partition3
  fi
else
  partition2=${DISK}2
  if [[ "${CREATE_SWAP}" == "true" ]]; then
    partition3=${DISK}3
    partition4=${DISK}4
    root_partition=$partition4
  else
    partition3=${DISK}3
    root_partition=$partition3
  fi
fi

if [[ "${FS}" == "btrfs" ]]; then
  mkfs.vfat -F32 -n "EFIBOOT" "${partition2}"
  if [[ "${CREATE_SWAP}" == "true" ]]; then
    mkswap "${partition3}"
    swapon "${partition3}"
  fi
  mkfs.btrfs -f "${root_partition}"
  mount -t btrfs "${root_partition}" /mnt
  subvolumesetup
elif [[ "${FS}" == "ext4" ]]; then
  mkfs.vfat -F32 -n "EFIBOOT" "${partition2}"
  if [[ "${CREATE_SWAP}" == "true" ]]; then
    mkswap "${partition3}"
    swapon "${partition3}"
  fi
  mkfs.ext4 "${root_partition}"
  mount -t ext4 "${root_partition}" /mnt
elif [[ "${FS}" == "luks" ]]; then
  mkfs.vfat -F32 "${partition2}"
  if [[ "${CREATE_SWAP}" == "true" ]]; then
    mkswap "${partition3}"
    swapon "${partition3}"
  fi
  echo -n "${LUKS_PASSWORD}" | cryptsetup -y -v luksFormat "${root_partition}" -
  echo -n "${LUKS_PASSWORD}" | cryptsetup open "${root_partition}" ROOT -
  mkfs.btrfs "${root_partition}"
  mount -t btrfs "${root_partition}" /mnt
  subvolumesetup
  ENCRYPTED_PARTITION_UUID=$(blkid -s UUID -o value "${root_partition}")
fi

BOOT_UUID=$(blkid -s UUID -o value "${partition2}")

sync
if ! mountpoint -q /mnt; then
  echo "ERROR! Failed to mount ${root_partition} to /mnt after multiple attempts."
  exit 1
fi
mkdir -p /mnt/boot/efi
mount -t vfat -U "${BOOT_UUID}" /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
  echo "Drive is not mounted can not continue"
  echo "Rebooting in 3 Seconds ..." && sleep 1
  echo "Rebooting in 2 Seconds ..." && sleep 1
  echo "Rebooting in 1 Second ..." && sleep 1
  reboot now
fi

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║               Install on main drive                ║
           ╚════════════════════════════════════════════════════╝

"
if [[ ! -d "/sys/firmware/efi" ]]; then
  pacstrap /mnt base base-devel linux linux-firmware --noconfirm --needed
else
  pacstrap /mnt base base-devel linux linux-firmware efibootmgr --noconfirm --needed
fi
echo "keyserver hkp://keyserver.ubuntu.com" >>/mnt/etc/pacman.d/gnupg/gpg.conf
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

genfstab -U /mnt >>/mnt/etc/fstab
echo "
  Generated /etc/fstab:
"
cat /mnt/etc/fstab
echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                Bootloader install                  ║
           ╚════════════════════════════════════════════════════╝

"
if [[ ! -d "/sys/firmware/efi" ]]; then
  grub-install --boot-directory=/mnt/boot "${DISK}"
fi
echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                  Setting up swap                   ║
           ╚════════════════════════════════════════════════════╝

"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[ $TOTAL_MEM -lt 8000000 ]]; then
  mkdir -p /mnt/opt/swap
  if findmnt -n -o FSTYPE /mnt | grep -q btrfs; then
    chattr +C /mnt/opt/swap
  fi
  dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
  chmod 600 /mnt/opt/swap/swapfile
  chown root /mnt/opt/swap/swapfile
  mkswap /mnt/opt/swap/swapfile
  swapon /mnt/opt/swap/swapfile
  echo "/opt/swap/swapfile    none    swap    sw    0    0" >>/mnt/etc/fstab # Add swap to fstab, so it KEEPS working after installation.
fi

gpu_type=$(lspci | grep -E "VGA|3D|Display")

arch-chroot /mnt /bin/bash -c "KEYMAP='${KEYMAP}' /bin/bash" <<'EOF'

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                  Network Setup                     ║
           ╚════════════════════════════════════════════════════╝

"
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager
echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                  Setting up mirrors                ║
           ╚════════════════════════════════════════════════════╝

"
pacman -S --noconfirm --needed pacman-contrib curl
pacman -S --noconfirm --needed reflector rsync grub arch-install-scripts git ntp wget openssh
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                    Build Config                    ║
           ╚════════════════════════════════════════════════════╝

"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTAL_MEM -gt 8000000 ]]; then
    sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
    sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                    Language Setup                  ║
           ╚════════════════════════════════════════════════════╝

"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone ${TIMEZONE}
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Set keymaps
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
echo "XKBLAYOUT=${KEYMAP}" >> /etc/vconsole.conf
echo "Keymap set to: ${KEYMAP}"

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

#Set colors and enable the easter egg
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                    Cpu microcode                   ║
           ╚════════════════════════════════════════════════════╝

"
# determine processor type and install microcode
if grep -q "GenuineIntel" /proc/cpuinfo; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
else
    echo "Unable to determine CPU vendor. Skipping microcode installation."
fi

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                 Graphics drivers                   ║
           ╚════════════════════════════════════════════════════╝

"
# Graphics Drivers find and install
if echo "${gpu_type}" | grep -E "NVIDIA|GeForce"; then
    echo "Installing NVIDIA drivers: nvidia"
    pacman -S --noconfirm --needed nvidia
elif echo "${gpu_type}" | grep 'VGA' | grep -E "Radeon|AMD"; then
    echo "Installing AMD drivers: xf86-video-amdgpu"
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif echo "${gpu_type}" | grep -E "Integrated Graphics Controller"; then
    echo "Installing Intel drivers:"
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif echo "${gpu_type}" | grep -E "Intel Corporation UHD"; then
    echo "Installing Intel UHD drivers:"
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                    Adding User                     ║
           ╚════════════════════════════════════════════════════╝

"
groupadd libvirt
useradd -m -G wheel,libvirt -s /bin/bash $USERNAME
echo "$USERNAME created, home directory created, added to wheel and libvirt group, default shell set to /bin/bash"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "$USERNAME password set"
echo $NAME_OF_MACHINE > /etc/hostname

if [[ ${FS} == "luks" ]]; then
# Making sure to edit mkinitcpio conf if luks is selected
# add encrypt in mkinitcpio.conf before filesystems in hooks
    sed -i 's/filesystems/encrypt filesystems/g' /etc/mkinitcpio.conf
# making mkinitcpio with linux kernel
    mkinitcpio -p linux-lts
fi

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                    Grub efi check                  ║
           ╚════════════════════════════════════════════════════╝

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                   Theme boot menu                  ║
           ╚════════════════════════════════════════════════════╝

"
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
sed -i 's/ quiet / /g; s/^GRUB_CMDLINE_LINUX_DEFAULT="quiet /GRUB_CMDLINE_LINUX_DEFAULT="/; s/ quiet"$/"/; s/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash loglevel=3/' /etc/default/grub

echo -e "Installing Grub theme..."
THEME_DIR="/usr/share/grub/themes/"
echo -e "Creating the theme directory..."
mkdir -pv "${THEME_DIR}"

cd "${THEME_DIR}" || exit
git clone https://github.com/13atm01/GRUB-Theme.git
mv GRUB-Theme/Touhou\ Project/Touhou-project/ .
rm -rf GRUB-Theme 

echo "Theme has been cloned to \${THEME_DIR}"
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting the theme as the default..."
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/Touhou-project/theme.txt\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                   Enabling service                 ║
           ╚════════════════════════════════════════════════════╝

"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable sshd
echo "  ssh enabled"

echo -ne "

           ╔════════════════════════════════════════════════════╗
           ║                      Cleaning                      ║
           ╚════════════════════════════════════════════════════╝

"
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║                Installing extra packages           ║
           ╚════════════════════════════════════════════════════╝

"
pacman -S --noconfirm --needed fd fzf ripgrep sd neovim eza bat net-tools fastfetch btop htop xdg-user-dirs bash-completion
echo "  installing usefull tools"
xdg-user-dirs-update
curl -o /home/$USERNAME/.bashrc https://raw.githubusercontent.com/fruitsaladchan/bashrc/refs/heads/main/.bashrc
chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc
chmod 644 /home/$USERNAME/.bashrc

# Create a temporary directory for building yay
echo "  Installing yay AUR helper..."
cd /home/$USERNAME
sudo -u $USERNAME git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
sudo -u $USERNAME makepkg -si --noconfirm
cd ..
rm -rf yay-bin
echo "  finished"

if [[ "${CREATE_SWAP}" == "true" ]]; then
    SWAP_UUID=$(blkid -s UUID -o value "${partition3}")
    echo "UUID=${SWAP_UUID} none swap sw 0 0" >> /mnt/etc/fstab
fi

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║           Installing Desktop environment           ║
           ╚════════════════════════════════════════════════════╝

"
if [[ "${DE}" != "none" ]]; then
    # Install X.org if needed
    if [[ "${DE}" != "hyprland" ]]; then
        pacman -S --noconfirm --needed xorg xorg-server
    fi
    
    # Install chosen DE/WM
    pacman -S --noconfirm --needed ${DE_PACKAGES}
    
    # Install display manager if selected
    if [[ -n "${DM}" ]]; then
        pacman -S --noconfirm --needed ${DM_PACKAGES}
        systemctl enable ${DM}.service
        echo "  Display Manager enabled"
    fi
    
    # Additional packages for proper DE functionality
    pacman -S --noconfirm --needed xdg-utils xdg-desktop-portal-gtk \
        pipewire pipewire-pulse wireplumber \
        network-manager-applet pavucontrol
fi

# If Hyprland was selected, install additional Wayland packages
if [[ "${DE}" == "hyprland" ]]; then
    pacman -S --noconfirm --needed \
        xdg-desktop-portal-hyprland \
        qt5-wayland qt6-wayland \
        polkit-kde-agent
fi

EOF
clear

echo -ne "
           ╔════════════════════════════════════════════════════╗
           ║              Installation completed!!              ║
           ╚════════════════════════════════════════════════════╝

The installation has completed successfully!

"
echo -ne "What do you want to do:
"
options=("Reboot" "Exit")
select_option "${options[@]}"

case ${options[$?]} in
  "Reboot")
    echo ""
    echo "Rebooting in:"
    for i in {5..1}; do
      echo "$i..."
      sleep 1
    done
    reboot
    ;;
  "Exit")
    echo ""
    echo "You can reboot when ready by typing 'reboot'"
    ;;
esac
