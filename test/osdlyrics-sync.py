#!/usr/bin/env python3
"""
OSDLyrics Sync Script for Noctalia Test Plugin
Monitors MPRIS2 players and syncs lyrics to OSDLyrics
"""

import sys
import dbus
import dbus.mainloop.glib
from gi.repository import GLib
import requests
import json
import time

class OSDLyricsSync:
    def __init__(self):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        self.bus = dbus.SessionBus()
        self.current_track = None
        self.current_player = None
        self.osd_interface = None

        # Try to connect to OSDLyrics
        try:
            osd_service = self.bus.get_object('org.osdlyrics.Daemon', '/org/osdlyrics/Lyrics')
            self.osd_interface = dbus.Interface(osd_service, 'org.osdlyrics.Lyrics')
            print("[INFO] Connected to OSDLyrics")
        except Exception as e:
            print(f"[WARNING] Could not connect to OSDLyrics: {e}")
            print("[INFO] Make sure OSDLyrics is running")

        # Find active MPRIS players
        self.find_players()

    def find_players(self):
        """Find active MPRIS2 players"""
        names = self.bus.list_names()
        mpris_players = [name for name in names if name.startswith('org.mpris.MediaPlayer2.')]

        if not mpris_players:
            print("[INFO] No MPRIS2 players found")
            return

        # Use the first player found
        self.current_player = mpris_players[0]
        print(f"[INFO] Found player: {self.current_player}")

        # Subscribe to property changes
        self.setup_player_monitoring()

        # Get current track
        self.update_current_track()

    def setup_player_monitoring(self):
        """Setup monitoring for MPRIS player property changes"""
        try:
            self.bus.add_signal_receiver(
                self.on_properties_changed,
                signal_name='PropertiesChanged',
                dbus_interface='org.freedesktop.DBus.Properties',
                bus_name=self.current_player,
                path='/org/mpris/MediaPlayer2'
            )
            print("[INFO] Monitoring player for track changes")
        except Exception as e:
            print(f"[ERROR] Failed to setup player monitoring: {e}")

    def on_properties_changed(self, interface, changed, invalidated):
        """Handle MPRIS property changes"""
        if interface != 'org.mpris.MediaPlayer2.Player':
            return

        if 'Metadata' in changed:
            self.update_current_track()

    def update_current_track(self):
        """Get current track metadata from MPRIS player"""
        try:
            player_obj = self.bus.get_object(self.current_player, '/org/mpris/MediaPlayer2')
            props = dbus.Interface(player_obj, 'org.freedesktop.DBus.Properties')
            metadata = props.Get('org.mpris.MediaPlayer2.Player', 'Metadata')

            # Extract track info
            title = str(metadata.get('xesam:title', ''))
            artists = metadata.get('xesam:artist', [])
            artist = ', '.join(str(a) for a in artists) if artists else ''

            track_info = {
                'title': title,
                'artist': artist
            }

            # Check if track changed
            if track_info != self.current_track:
                self.current_track = track_info
                print(f"[INFO] Track changed: {artist} - {title}")
                self.fetch_and_send_lyrics(title, artist)

        except Exception as e:
            print(f"[ERROR] Failed to get track metadata: {e}")

    def fetch_and_send_lyrics(self, title, artist):
        """Fetch lyrics from Netease API and send to OSDLyrics"""
        if not self.osd_interface:
            print("[WARNING] OSDLyrics not connected, skipping lyrics sync")
            return

        if not title:
            print("[WARNING] No title available, skipping lyrics fetch")
            return

        try:
            # Search for the song on Netease
            print(f"[INFO] Searching for lyrics: {artist} - {title}")
            search_url = f"https://music.163.com/api/search/get/web"
            params = {
                's': f"{artist} {title}",
                'type': 1,
                'limit': 1
            }

            response = requests.get(search_url, params=params, timeout=5)
            if response.status_code != 200:
                print(f"[ERROR] Search request failed with status {response.status_code}")
                return

            data = response.json()

            if not data.get('result') or not data['result'].get('songs'):
                print("[WARNING] No search results found")
                return

            song_id = data['result']['songs'][0]['id']
            print(f"[INFO] Found song ID: {song_id}")

            # Get lyrics
            lyrics_url = f"https://music.163.com/api/song/lyric"
            params = {'id': song_id, 'lv': 1, 'tv': -1}

            response = requests.get(lyrics_url, params=params, timeout=5)
            if response.status_code != 200:
                print(f"[ERROR] Lyrics request failed with status {response.status_code}")
                return

            lyrics_data = response.json()

            if not lyrics_data.get('lrc') or not lyrics_data['lrc'].get('lyric'):
                print("[WARNING] No lyrics available for this track")
                return

            lyrics_content = lyrics_data['lrc']['lyric']
            print(f"[INFO] Fetched lyrics ({len(lyrics_content)} bytes)")

            # Send to OSDLyrics
            metadata = {
                'title': dbus.String(title),
                'artist': dbus.String(artist)
            }

            lyrics_bytes = dbus.ByteArray(lyrics_content.encode('utf-8'))
            uri = self.osd_interface.SetLyricContent(metadata, lyrics_bytes)

            if uri:
                print(f"[SUCCESS] Lyrics sent to OSDLyrics: {uri}")
            else:
                print("[WARNING] OSDLyrics returned empty URI")

        except requests.RequestException as e:
            print(f"[ERROR] Network error while fetching lyrics: {e}")
        except Exception as e:
            print(f"[ERROR] Failed to fetch/send lyrics: {e}")

    def run(self):
        """Run the main event loop"""
        print("[INFO] OSDLyrics sync started")
        print("[INFO] Monitoring MPRIS players for track changes...")

        loop = GLib.MainLoop()
        try:
            loop.run()
        except KeyboardInterrupt:
            print("\n[INFO] Stopping OSDLyrics sync")
            sys.exit(0)

if __name__ == "__main__":
    sync = OSDLyricsSync()
    sync.run()
