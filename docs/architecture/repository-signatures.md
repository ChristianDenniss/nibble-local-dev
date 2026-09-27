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
| **auth** | `Repository` | `CreateAccount`, `CredentialsByEmail`, `IdentityBySubject`, `LinkIdentity`, `CreateSession`, `SessionByTokenHash(hash, now)`, `DeleteSession` |
| **menu** | `Repository` | `GetByID`, `Upsert`, `SetImageURL(id, url)` — legacy storefront items |
| **compare** | (service deps) | places, users, channels, resolution, item prices, quotes, serviceability |
| **ingest** | `IngestRunRepository`, `SourceSnapshotRepository` | run lifecycle + raw snapshots |
| **channel** | `Repository` | channel catalog |
| **market** | `MarketRepository`, `ProbeDropoffRepository`, `ChannelCoverageRepository` | coverage probes |
| **promotion** | `PromotionRepository` | `GetByID`, `ListActiveByChannel`, `ListActiveWithTargets(at)`, `Upsert`, `UpsertConstraint`, `UpsertTarget` |
| **promotion** | `MembershipProductRepository` | `GetByID`, `Upsert` |
| **merchandising** | `Repository` | `ActivePlacements(slot, marketID, at)`, `UpsertAdvertiser`, `UpsertCampaign`, `UpsertPlacement`, `RecordEvent` |
| **home** | (service deps) | `CatalogLoader` (storefront service), `PromotionSource` (promotion service), `PlacementSource` (merchandising service) |

HTTP handlers call **services** only; services depend on these ports, not SQL.
