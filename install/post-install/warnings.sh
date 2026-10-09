# Warn when the current session is X11; the Ubuntu 26.04 desktop session is Wayland-only.
if [[ ${XDG_SESSION_TYPE:-} == "x11" ]]; then
  echo -e "\e[33m\nWarning: You are currently using an X11 session. $OMAKUB_BRAND is optimized for Wayland.\e[0m"
  echo -e "\e[33mIf your desktop provides a Wayland session, select it at the login screen.\e[0m"
  echo
fi
