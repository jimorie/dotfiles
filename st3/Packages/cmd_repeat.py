import sublime
import sublime_plugin

class CmdRepeatCommand(sublime_plugin.WindowCommand):
    def run(self, subcommand=None, repeat=1):
        window = self.window
        while repeat > 0:
            window.run_command(subcommand["command"], subcommand["args"])
            repeat -= 1

