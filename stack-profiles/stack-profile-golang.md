# Stack Profile — <repo-id> (Golang)

- Build: `go build ./...`
- Test: `go test ./...`
- Lint: `golangci-lint run`
- Package manager: Go Modules (`go.mod`)
- Folder convention: `internal/<feature>/{handler,service,repository}.go`,
  `cmd/<binary>/main.go` untuk entrypoint
- Naming convention: PascalCase untuk exported identifier, camelCase untuk
  unexported; nama file snake_case
- Database: lihat `stack-profiles/db/stack-profile-db-<engine>.md` sesuai
  database yang dipakai repo ini
- Catatan tambahan: gunakan `context.Context` secara eksplisit untuk request
  scope; error wajib di-wrap dengan konteks (`fmt.Errorf("...: %w", err)"`),
  jangan menelan error tanpa log/return.
