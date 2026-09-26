# Repository ports (by bounded context)

Canonical interfaces live in `nibble-go-data-model/*/repository`. `nibble-go-data-store` implements them in `target_*.go` / `storefront.go`.

| Context | Port | Key methods |
|---------|------|-------------|
| **source** | `StoreRepository` | `GetByID`, `GetByChannelExternal`, `ListByChannel`, `Upsert` |
| **source** | `MenuRepository` | `GetByID`, `ListByStore`, `Upsert` |
| **source** | `CategoryRepository` | `ListByMenu`, `Upsert` |
| **source** | `ItemRepository` | `ListByCategory`, `Upsert` |
| **source** | `BrowseRepository` | `LoadMenuBrowse(store, fulfillment, executor)` |
| **storefront** | `Repository` | `LoadCatalog(accountID)` — legacy read model |
| **compare** | (service deps) | places, users, channels, resolution, item prices, quotes, serviceability |
| **ingest** | `IngestRunRepository`, `SourceSnapshotRepository` | run lifecycle + raw snapshots |
| **channel** | `Repository` | channel catalog |
| **market** | `MarketRepository`, `ProbeDropoffRepository`, `ChannelCoverageRepository` | coverage probes |

HTTP handlers call **services** only; services depend on these ports, not SQL.
