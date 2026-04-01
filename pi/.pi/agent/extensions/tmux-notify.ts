/**
 * Tmux Notify Extension
 *
 * Notifies when pi is done and waiting for input.
 * Sound + tmux window highlight (red) + session alert if cross-session.
 * Port of Claude Code's notify-ready.sh hook.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async () => {
		if (!process.env.TMUX) return;

		const tmuxPane = process.env.TMUX_PANE;
		if (!tmuxPane) return;

		// Get window/session info
		const windowTarget = await pi.exec("tmux", ["display-message", "-t", tmuxPane, "-p", "#S:#I"]);
		const claudeSession = await pi.exec("tmux", ["display-message", "-t", tmuxPane, "-p", "#S"]);
		const activeSessionResult = await pi.exec("tmux", ["list-clients", "-F", "#{session_name}"]);
		const activeSession = activeSessionResult.stdout.trim().split("\n")[0];

		const piSession = claudeSession.stdout.trim();
		const piWindow = (await pi.exec("tmux", ["display-message", "-t", tmuxPane, "-p", "#I"])).stdout.trim();

		// Check if user is already looking at pi's window in Ghostty
		const activeWindowResult = await pi.exec("tmux", ["list-clients", "-F", "#{window_index}"]);
		const activeWindow = activeWindowResult.stdout.trim().split("\n")[0];

		if (piSession === activeSession && piWindow === activeWindow) {
			const frontmost = await pi.exec("osascript", ["-e",
				'tell application "System Events" to get name of first application process whose frontmost is true']);
			if (frontmost.stdout.trim().toLowerCase() === "ghostty") return;
		}

		// Only notify if user is NOT looking at this pane
		pi.exec("afplay", ["/System/Library/Sounds/Funk.aiff"]);

		// Highlight session if pi is in a different one
		if (piSession !== activeSession) {
			await pi.exec("tmux", ["set-option", "-t", activeSession, "status-left",
				'#[fg=#FFFFFF,bg=red,bold] #S #[bg=#343F44] ']);
		}

		// Highlight tmux window in status bar
		await pi.exec("tmux", ["set-window-option", "-t", windowTarget.stdout.trim(),
			"window-status-format", '#[fg=#FFFFFF bg=red bold] #I #W ']);
	});
}
