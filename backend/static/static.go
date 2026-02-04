package static

import (
	"embed"
	"io/fs"
	"net/http"
)

//go:embed all:frontend_dist
var frontendFiles embed.FS

func BuildHTTPFS() (http.FileSystem, error) {
	stripped, err := fs.Sub(frontendFiles, "frontend_dist")
	if err != nil {
		return nil, err
	}
	return http.FS(stripped), nil
}
