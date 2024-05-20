import sublime_plugin
import subprocess
from time import sleep
import sys

# Define constants
SUBIME_MAIN_WINDOW_TITLE = " - Sublime Text (UNREGISTERED)"
MAX_ATTEMPTS = 10
WAIT_TIME = 0.5

def execute_command(command):
    """Execute shell command and return output."""
    try:
        output = subprocess.check_output(command, shell=True)
        return output.decode().strip()
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        return ""

class LicenseWindowKiller(sublime_plugin.EventListener):
    def find_sublime_window_ids(self):
        """Find Sublime Text window IDs."""
        sublime_pid = execute_command("pgrep sublime_text")
        if sublime_pid:
            window_ids = execute_command(f"wmctrl -lp | grep {sublime_pid} | awk '{{print $1}}'")
            return window_ids.splitlines()
        return []

    def close_second_window(self, main_window_id):
        """Close the second window if present."""
        second_window_id = execute_command(f"wmctrl -lp | grep {main_window_id} | awk '{{ids[$1]++}}{{for (id in ids){{if (id != \"{main_window_id}\"){{printf id}}}}}}'")
        if second_window_id:
            execute_command(f"wmctrl -i -c {second_window_id}")

    def seek_n_close(self):
        """Seek and close the second window."""
        window_ids = self.find_sublime_window_ids()
        for window_id in window_ids:
            self.close_second_window(window_id)

    def on_pre_save_async(self, *args):
        """Close the second window before saving."""
        attempts = 0
        while attempts < MAX_ATTEMPTS:
            self.seek_n_close()
            sleep(WAIT_TIME)
            attempts += 1
