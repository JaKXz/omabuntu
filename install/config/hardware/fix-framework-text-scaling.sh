COMPUTER_MAKER=$(sudo dmidecode -s system-manufacturer)
HAS_FRAMEWORK_PANEL=false

for modes_file in /sys/class/drm/card*-eDP-*/modes; do
  [[ -f $modes_file ]] || continue
  if grep -qx "2256x1504" "$modes_file"; then
    HAS_FRAMEWORK_PANEL=true
    break
  fi
done

if [[ $HAS_FRAMEWORK_PANEL != true && ${XDG_SESSION_TYPE:-} != "wayland" ]] && command -v xrandr >/dev/null 2>&1; then
  if [[ $(xrandr | awk '/\*\+/{print $1; exit}') == "2256x1504" ]]; then
    HAS_FRAMEWORK_PANEL=true
  fi
fi

if [[ $COMPUTER_MAKER == "Framework" && $HAS_FRAMEWORK_PANEL == true ]]; then
  gsettings set org.gnome.desktop.interface text-scaling-factor 0.8
  gsettings set org.gnome.desktop.interface cursor-size 16
  if [[ -f $HOME/.config/alacritty/alacritty.toml ]]; then
    sed -i "s/size = 9/size = 7/g" "$HOME/.config/alacritty/alacritty.toml"
  fi
fi
