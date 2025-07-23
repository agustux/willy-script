# willy-script
Auto installations for packages for willy's chromebook

**Usage**

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/agustux/willy-script/main/willy-script.sh)"
```
For reference if the speaker audio doesn't work try [this](https://github.com/WeirdTreeThing/chromebook-linux-audio) repo

To disable some startup processes: `sudo sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop`

Real-time CPU frequency reading: `watch -n1 "grep 'MHz' /proc/cpuinfo"`

Current CPU temperatures: `paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'`

Current iGPU freq: `sudo intel_gpu_top`

To see max iGPU freq: `sudo intel_gpu_frequency --max`
