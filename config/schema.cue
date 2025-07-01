package config

import "net"

config: [Name=string]: {
	name: Name

	external_url: net.URL
	cert_issuer:  string
}
