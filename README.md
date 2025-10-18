# the HouseMan

the HouseMan is doing his work dilligently, constantly cleaning up and making the place look nice.

This is a collection of small, simple tasks I want to constantly have running on my Fedora system.

Only User/Home context stuff like:

- [x] Removing any old unnamed TMUX sessions
- [ ] Regular clearing of logs, paths
- [-] Changing volume of applications
- [ ] Keeping SSH sessions active

Put any commands, shellscripts, programs, whatever in `~/.config/houseman/jobs.txt` to run them.

Future ideas:

- [ ] Send reminders or upcoming calendaritems to active TMUX sessions
- [ ] Regular backups and git maintenance

This installs as a `systemd-timer` which runs a small program every 10 seconds.

The program checks a todo list, with set intervals and executes tasks at the desired interval.

Clone to `~/.config`:

```bash
git clone https://github.com/rolflobker/HouseMan ~/.config/houseman
```

Modify `~/.config/houseman/jobs.txt` to your liking.

Include or exclude any of the accompanying jobs:

```text
10 ~/.config/houseman/jobs/volume_adjuster
10 ~/.config/houseman/jobs/tmux_close_numbered_sessions
```

Each line is: `<interval in seconds> <command to run>`

Create systemd timer:

```bash
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
HOUSEMAN_SERVICE_NAME="houseman"
HOUSEMAN_SERVICE_FILE="$USER_SYSTEMD_DIR/${HOUSEMAN_SERVICE_NAME}.service"
HOUSEMAN_TIMER_FILE="$USER_SYSTEMD_DIR/${HOUSEMAN_SERVICE_NAME}.timer"

HOUSEMAN_SCRIPT="$HOME/.config/houseman/houseman.sh"

mkdir -p "$USER_SYSTEMD_DIR"

cat >"$HOUSEMAN_SERVICE_FILE" <<EOF
[Unit]
Description=the HouseMan -- doing his chores

[Service]
Type=oneshot
ExecStart=$HOUSEMAN_SCRIPT
EOF


cat >"$HOUSEMAN_TIMER_FILE" <<EOF
[Unit]
Description=Put the HouseMan to work

[Timer]
OnUnitActiveSec=1m
AccuracySec=10s
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now "$SERVICE_NAME".service
systemctl --user enable --now "$HOUSEMAN_TIMER_FILE"

loginctl enable-linger "$USER"

```
