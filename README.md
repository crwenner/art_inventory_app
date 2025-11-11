# 🎨 Art Inventory App

A lightweight Sinatra-based web application for managing a personal or studio art inventory.  
Track artworks, upload images, generate QR codes, mark items as sold, and export your full collection to CSV — all from a clean, simple web interface.

---

## ✨ Features

- 🖼️ **Add and edit artworks** — name, price, and image uploads
- 💾 **Persistent data** — stored in a local CSV file (`data/inventory.csv`)
- 🔄 **Automatic QR code generation** — each item gets a scannable QR for quick access
- 💰 **Track sold status** — mark items as sold and note where they were sold
- 📦 **Export inventory to CSV** — backup or analyze your data anytime
- 💡 **Responsive, minimalist UI** — clean HTML and CSS for simplicity
- ⚙️ **Modular Sinatra structure** — helpers, models, and views organized cleanly
- 🪶 **No database required** — fully file-based for quick setup and testing

---

## 🧭 Project Structure

```
├── app.rb
├── config.ru
├── data/
│   └── inventory.csv
├── lib/
│   ├── helpers/
│   │   ├── app_helpers.rb
│   │   ├── file_helpers.rb
│   │   └── qr_code_helpers.rb
│   └── models/
│       └── inventory.rb
├── public/
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── script.js
│   ├── images/
│   └── qr_codes/
└── views/
    ├── layout.erb
    ├── index.erb
    ├── new.erb
    ├── edit.erb
    └── show.erb
```

---

## 🚀 Getting Started

### Prerequisites
- Ruby (3.1+ recommended)
- Bundler (`gem install bundler`)
- Docker (optional, for containerized use)

### Install and Run

```bash
bundle install
ruby app.rb
```

Or, if you’re using Docker:

```bash
docker-compose up --build
```

Then open your browser to:  
👉 [http://localhost:4567](http://localhost:4567)

---

## 🧰 Environment Configuration

You can configure basic runtime settings via environment variables:

| Variable | Description | Default |
|-----------|--------------|----------|
| `APP_HOST` | Host used for generating QR codes | `http://localhost:4567` |
| `PORT` | Port Sinatra listens on | `4567` |
| `RACK_ENV` | App environment | `development` |

---

## 📸 Example Workflow

1. Add a new art piece (name, price, and image).  
2. The app automatically:
   - Saves the image to `public/images/`
   - Creates a unique QR code in `public/qr_codes/`
   - Stores the record in `data/inventory.csv`
3. View, edit, mark as sold, or export your entire collection with one click.

---

## 🔮 Roadmap

Here’s what’s planned for the next iterations:

### 🧹 **Core Improvements**
- [ ] Add delete functionality for individual items
- [ ] Add “Sold Price” field to track sale amounts
- [ ] Make index table more mobile-friendly and card-based

### 🌐 **Smart Features**
- [ ] Make QR codes open the app directly via `APP_HOST`
- [ ] Add configurable base URL for deployment or LAN access

### 🧪 **Development Enhancements**
- [ ] Add RSpec model and feature tests
- [ ] Add RuboCop linting for style consistency
- [ ] Add continuous integration workflow (GitHub Actions)

### 🗄️ **Future Enhancements**
- [ ] Optional SQLite3/Sequel migration (replace CSV backend)
- [ ] Image thumbnail generation
- [ ] Export to PDF

---

## 🤝 Contributing

Contributions are welcome!  
If you have suggestions, improvements, or bug reports:

1. Fork the repository  
2. Create a feature branch  
3. Submit a pull request with a clear description

---

## 🧑‍💻 Author

**Chris Wenner**  
Built with ❤️ using [Sinatra](https://sinatrarb.com) and plain Ruby.

---

## 📜 License

This project is open-source under the [MIT License](LICENSE).
