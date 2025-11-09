# 🎨 Art Inventory Manager

A simple Sinatra web app to manage your homemade art pieces.

## Features

- Add new art pieces with name + photo
- Auto-generate ID + QR code for each piece
- Mark pieces as sold with notes (e.g., Etsy, local market)
- Export inventory as CSV
- Persistent data using Docker volumes

## To Do:
- [ ] Add search functionality
- [ ] Add soft delete
- [ ] Add Google sheet sync?
- [ ] Authentication

## 🚀 Run Locally (Docker Compose)

```bash
docker compose up --build
```

Then open your browser at: [http://localhost:4567](http://localhost:4567)

### 🧩 Endpoints

| Path | Description |
|------|--------------|
| `/` | View inventory |
| `/new` | Add a new piece |
| `/sold/:id` | Mark piece as sold |
| `/export` | Export CSV of all inventory |

### 🗂️ Project Structure

```
art_inventory_app/
├── app.rb
├── Dockerfile
├── docker-compose.yml
├── inventory.csv
├── notes/
├── public/
│   ├── uploads/
│   └── qr/
└── README.md
```

### 🧱 Tech Stack

- Ruby (Sinatra)
- RQRCode (for QR generation)
- CSV (for lightweight data storage)

---

👩‍🎨 Built for independent artists to keep track of their creations.
