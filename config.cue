package autolab

import "net"

#Config: {
	[Name=string]: {
		name: Name

		external_url: net.URL
		cert_issuer:  string
	}
	dev: {
		external_url: "localhost"
		cert_issuer:  "self-signed"
	}
	prod: {
		external_url: "dislogi.net"
		cert_issuer:  "acme-prod"
	}
}

// Custom parameters
env_name: string | *"dev" @tag(env, type=string)
env:      #Config[env_name]
