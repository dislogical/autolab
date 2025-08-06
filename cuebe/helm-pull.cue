package cuebe

import (
	"github.com/holos-run/holos/api/core/v1alpha5:core"
)

#HelmPull: {
	#Generator: core.#Generator

	tasks: {
		"helm-pull:\(#Generator.helm.chart.repository.name):\(#Generator.helm.chart.name):\(#Generator.helm.chart.version)": {

			let dest = ".cuebe/helm-cache/\(#Generator.helm.chart.repository.name)/\(#Generator.helm.chart.name)/\(#Generator.helm.chart.version)"

			// This is here because multiple tasks may be merged by cue, but we need the repo urls to be the same if that's the case.
			_repoUrl: #Generator.helm.chart.repository.url

			cmds: [
				"echo Pulling...",
				"mkdir -p \(dest)",
				"""
				echo '#!/usr/bin/env bash
				helm pull \(#Generator.helm.chart.name) \\
					--repo \(#Generator.helm.chart.repository.url) \\
					--version \(#Generator.helm.chart.version) \\
					--destination \(dest) \\
					--untar' > \(dest)/pull.sh
				""",
				"chmod +x \(dest)/pull.sh",
				"\(dest)/pull.sh",
			]

			sources: [
				"\(dest)/pull.sh",
			]
			generates: [
				"\(dest)/\(#Generator.helm.chart.name)/Chart.yaml",
			]
		}
	}
}
