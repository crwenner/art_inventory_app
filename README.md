# 🎨 Art Inventory App (Modular)

A friendly, lightweight Sinatra app to manage your homemade art pieces — images, QR codes, sold tracking, and CSV export.

## Features
- Add and list art pieces with images and QR codes
- Edit items, mark sold, and record "Sold Where"
- Search by name, ID or Sold Where
- Toggle showing sold items
- Export inventory to CSV
- Modular structure for easy extension (helpers, services, models)

## Quick start (Docker)
```bash
docker compose build
docker compose up
```
Visit http://localhost:4567

## Roadmap
- Soft delete / archive items
- Authentication for admin actions
- Tailwind CSS refactor (when styles are stable)
- Tests (RSpec) and CI
- Move CSV -> SQLite (optional) for larger inventories

## Notes
- Images saved to `public/images`, QR codes to `public/qr_codes`, data to `data/inventory.csv`
- Static asset serving fixed in `app.rb` to ensure Docker accessibility
- MIT Licensed
