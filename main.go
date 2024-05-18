package main

import (
	_ "github.com/coredns/coredns/core/plugin"
	_ "github.com/relekang/coredns-blocklist"

	"github.com/coredns/coredns/core/dnsserver"
	"github.com/coredns/coredns/coremain"
)

func init() {
	var directives []string

	// append blocklist after log
	for _, name := range dnsserver.Directives {
		if name == "log" {
			directives = append(directives, "blocklist")
		}
		directives = append(directives, name)
	}

	// update directives
	dnsserver.Directives = directives
}

func main() {
	coremain.Run()
}
