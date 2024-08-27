package config

import (
	"github.com/khulnasoft/meshplay-adapter-library/adapter"
	"github.com/khulnasoft/meshplay-adapter-library/meshes"
)

func getOperations(dev adapter.Operations) adapter.Operations {
	var adapterVersions []adapter.Version

	dev[PerfOperation] = &adapter.Operation{
		Type:                 int32(meshes.OpCategory_INSTALL),
		Description:          "Install Meshplay Perf",
		Versions:             adapterVersions,
		AdditionalProperties: map[string]string{},
	}

	return dev
}
