# OSDLyrics Sync Plugin

A Noctalia Shell plugin that syncs lyrics from MPRIS2 media players to OSDLyrics desktop lyrics display.

## Features

- Monitors MPRIS2 compatible music players
- Automatically fetches lyrics from Netease Cloud Music API
- Syncs lyrics to OSDLyrics in real-time
- Displays current track information in the status bar
- Visual status indicator (active/inactive)

## Requirements

- OSDLyrics installed and running
- Python 3 with the following packages:
  - `dbus-python`
  - `PyGObject`
  - `requests`
- A MPRIS2 compatible music player (Spotify, VLC, YesPlayMusic, etc.)

## Installation

### 1. Install Dependencies

```bash
# Arch Linux
sudo pacman -S osdlyrics python-dbus python-gobject python-requests

# Ubuntu/Debian
sudo apt install osdlyrics python3-dbus python3-gi python3-requests

# Fedora
sudo dnf install osdlyrics python3-dbus python3-gobject python3-requests
```

### 2. Install Plugin

Install through Noctalia's plugin manager or manually place in the plugins directory.

### 3. Make Python Script Executable

```bash
chmod +x ~/.config/noctalia/plugins/test/osdlyrics-sync.py
```

## Usage

1. Start OSDLyrics
2. Enable the plugin in Noctalia settings
3. Play music in any MPRIS2 compatible player
4. Lyrics will automatically sync to OSDLyrics

## How It Works

1. The plugin monitors D-Bus for MPRIS2 player events
2. When a track changes, it extracts the title and artist
3. Fetches lyrics from Netease Cloud Music API
4. Sends lyrics to OSDLyrics via D-Bus interface
5. OSDLyrics displays the synced lyrics on your desktop

## Supported Players

Any MPRIS2 compatible media player, including:
- Spotify
- VLC
- YesPlayMusic
- Netease Cloud Music (Linux version)
- Rhythmbox
- Audacious
- And many more...

## Configuration

The plugin can be enabled/disabled through Noctalia's plugin settings. By default, it starts disabled.

## Troubleshooting

### No lyrics appear
- Ensure OSDLyrics is running
- Check if your player supports MPRIS2: `qdbus | grep mpris`
- Check plugin logs in Noctalia console

### Python dependencies missing
```bash
pip install --user dbus-python PyGObject requests
```

### Permission errors
Make sure the Python script is executable:
```bash
chmod +x ~/.config/noctalia/plugins/test/osdlyrics-sync.py
```

## Credits

Based on YesPlayMusic's OSDLyrics integration implementation.
