# 🎨 Art Inventory Manager

A lightweight **Sinatra-based web app** for managing your homemade art pieces — track your creations, mark them as sold, and export your data, all from a simple browser interface.

---

## 🚀 Features

- 🖼️ **Add New Art Pieces**
  - Upload an image
  - Automatically generate a unique ID and QR code

- 🔍 **Search and Filter**
  - Search by name, ID, or “Sold Where” location
  - Toggle between viewing **sold** and **unsold** items

- ✏️ **Edit Existing Art**
  - Update name, replace image, change sold status or sold location
  - QR code and ID remain unchanged

- 💰 **Mark Items as Sold**
  - Record where it was sold (Etsy, market, etc.)
  - Automatically logs notes to a file

- 🧾 **Export Inventory**
  - Export the full dataset to a `.csv` file for backup or analysis

- 🪄 **CSV-Based Storage**
  - Data is persisted in `inventory.csv`
  - Easy to edit or sync with spreadsheets

---

## 🧰 Requirements

- Docker and Docker Compose  
  _or_
- Ruby 3.x with `sinatra`, `rqrcode`, `rqrcode_png`, `puma`, and `rackup` gems installed

---

## 🐳 Running with Docker

1. **Build the image**
   ```bash
   docker compose build
   ```

2. **Start the container**
   ```bash
   docker compose up
   ```

3. **Visit the app**
   ```
   http://localhost:4567
   ```

---

## 📂 Project Structure

```
art_inventory_app/
├── app.rb              # Sinatra app
├── inventory.csv       # Inventory data (auto-generated)
├── notes/              # Sold notes
├── public/
│   ├── uploads/        # Uploaded images
│   └── qr/             # QR codes
├── views/              # Embedded templates
├── Dockerfile          # Container setup
├── docker-compose.yml  # Compose configuration
└── README.md           # Project documentation
```

---

## ✏️ Editing and Managing Art Pieces

- From the main list view, click **“Edit”** to:
  - Change the name
  - Replace the image
  - Toggle **Sold** on/off
  - Update **Sold Where**
- Use the **search bar** or toggle link to show/hide sold items.

---

## 📤 Exporting Data

To download all your records as CSV:

```
http://localhost:4567/export
```

---

## 🗺️ Roadmap

Future development plans and enhancements:

### 🔐 Authentication
- Add simple login system to protect the admin interface
- Optional `.env` support for credentials

### 🗑️ Soft Delete / Archive
- Allow hiding or archiving old or withdrawn pieces
- Add “View Archived” toggle similar to sold items

### 📸 Image Handling Improvements
- Optional image compression and thumbnail generation
- Validation for supported image types

### 🧭 Advanced Search & Filtering
- Filter by sold status, sold location, or upload date
- Sorting by name, status, or creation date

### 📦 Data Enhancements
- Store timestamps for creation and update
- Add JSON export for integration with other tools

### ⚙️ Quality & Maintenance
- Add tests (RSpec or Minitest)
- Optional SQLite or PostgreSQL support for larger inventories
- Improved error handling and logging

---

## 🧑‍💻 Development Notes

You can rebuild the Docker image at any time with:

```bash
docker compose build --no-cache
```

To install gems manually (if running locally without Docker):

```bash
bundle add sinatra rqrcode rqrcode_png rackup puma
```

---

## 📜 License

This project is licensed under the **MIT License**.  
See [LICENSE.txt](./LICENSE.txt) for details.
