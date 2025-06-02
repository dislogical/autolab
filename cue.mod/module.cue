module: "github.com/dislogical/autolab@v0"
language: {
	version: "v0.13.0"
}
source: {
	kind: "git"
}
description: "A recipe for a homelab cluster that's as automated as possible"
deps: {
	"cue.dev/x/k8s.io@v0": {
		v:       "v0.4.0"
		default: true
	}
	"github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io@v2": {
		v:       "v2.4.0"
		default: true
	}
	"github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io@v2": {
		v:       "v2.0.0"
		default: true
	}
}
