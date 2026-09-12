import { basename } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsubscribe,
				invalidate() {},
				render(width: number): string[] {
					const branch = footerData.getGitBranch();
					const left = theme.fg("dim", `${basename(ctx.cwd)}${branch ? ` (${branch})` : ""}`);
					const right = theme.fg("dim", `${ctx.model?.id ?? "no-model"} · ${ctx.thinkingLevel}`);
					const padding = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
					return [truncateToWidth(left + padding + right, width)];
				},
			};
		});
	});
}
