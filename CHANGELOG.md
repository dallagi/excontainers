# Changelog

## [0.3.1] - 2021-02-23
### Changed
- Relaxed version requirement for Tesla

## [0.3.0] - 2021-04-03
### Changed
- `Excontainers.Container` now starts the corresponding docker container automatically when it starts, and stops it when it terminates.
- `Excontainers.Container` is now a GenServer, hence it is possible to place containers under supervision trees.

## [0.2.1] - 2021-04-03
### Added
- Allow binding container ports to specific ports on the host.

