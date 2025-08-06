package cuebe

#HelmPull: {
	generator: {
		...
	}

	tasks: {
		"helm-pull:\(generator.helm.chart.repository.name):\(generator.helm.chart.name):\(generator.helm.chart.version)": {

			let dest = ".cuebe/helm-cache/\(generator.helm.chart.repository.name)/\(generator.helm.chart.name)/\(generator.helm.chart.version)"

			// This is here because multiple tasks may be merged by cue, but we need the repo urls to be the same if that's the case.
			_repoUrl: generator.helm.chart.repository.url

			cmds: [
				"echo Pulling...",
				"mkdir -p \(dest)",
				"""
					echo '#!/usr/bin/env bash
					helm pull \(generator.helm.chart.name) \\
						--repo \(generator.helm.chart.repository.url) \\
						--version \(generator.helm.chart.version) \\
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
				"\(dest)/\(generator.helm.chart.name)/Chart.yaml",
			]
		}
	}
}
