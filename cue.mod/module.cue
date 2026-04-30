module: "github.com/dislogical/autolab@v0"
language: {
	version: "v0.16.1"
}
source: {
	kind: "git"
}
deps: {
	"cue.dev/x/crd/cert-manager.io@v0": {
		v:       "v0.1.0"
		default: true
	}
	"cue.dev/x/crd/fluxcd.io@v0": {
		v: "v0.2.0"
	}
	"cue.dev/x/crd/k8s.io/networking@v0": {
		v:       "v0.2.0"
		default: true
	}
	"cue.dev/x/k8s.io@v0": {
		v:       "v0.4.0"
		default: true
	}
}
