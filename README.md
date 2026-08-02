# Bazar — Flutter E-Commerce App

A complete shopping application built with a **Flutter** mobile client that
consumes a **Laravel REST API**. It covers the full commerce flow — browsing,
search, cart, checkout, orders — plus a built-in **admin panel** for managing
products, categories, coupons, and orders.

- **App (my work):** Flutter (Dart) · BLoC/Cubit · clean feature-first architecture
- **API:** consumes a Laravel REST API (included in this repo so the full stack can be run locally)
- **Languages:** English + Arabic (RTL) · Light + Dark themes

---

## Screenshots

<table>
  <tr>
    <td align="center"><img src="frontend/screenshots/home.png" width="230"><br><sub>Home — banners &amp; flash deals</sub></td>
    <td align="center"><img src="frontend/screenshots/details.png" width="230"><br><sub>Product details</sub></td>
    <td align="center"><img src="frontend/screenshots/cart.png" width="230"><br><sub>Cart</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="frontend/screenshots/orders.png" width="230"><br><sub>Orders</sub></td>
    <td align="center"><img src="frontend/screenshots/profile.png" width="230"><br><sub>Profile</sub></td>
    <td align="center"><img src="frontend/screenshots/home_light.png" width="230"><br><sub>Light theme</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="frontend/screenshots/admin.png" width="230"><br><sub>Admin dashboard</sub></td>
    <td align="center"><img src="frontend/screenshots/admin_products.png" width="230"><br><sub>Products management</sub></td>
    <td align="center"><img src="frontend/screenshots/admin_product_form.png" width="230"><br><sub>Add product — photos, variants, deals</sub></td>
  </tr>
</table>

---

## Features

### Customer
- **Auth** — register with email verification (OTP), login, forgot/reset password, change password, guest mode (Sanctum tokens)
- **Home** — admin-managed **banner carousel**, **flash deals with live countdown**, "Recently viewed", "Recommended for you", categories, and popular products with infinite scroll; pull-to-refresh with shimmer skeletons
- **Search & filters** — debounced search, recent searches, price range (auto-scaled to the catalogue), sort (newest / price / rating)
- **Product details** — image gallery with **Hero transition**, **variants (size / colour)** with live price, stock status, **ratings summary (per-star bars)**, reviews (tap a reviewer to open their public profile), "You may also like"
- **Wishlist** — favourite products with an animated heart, synced across the app
- **Cart** — add variants, update quantity, stock-aware, animated cart badge
- **Checkout** — saved addresses, cash on delivery / card, coupon codes, order summary
- **Orders** — history, order details, status timeline, cancel, reorder
- **Notifications** — localized in-app centre with an unread badge (home + profile) **and
  FCM push** to the system tray when an order's status changes
- **Profile** — avatar upload, edit profile, phone-visibility toggle, change password, theme & language switch (English / Arabic RTL)

### Admin
- **Dashboard** — revenue, orders, pending, customers, 7-day sales chart, top products
- **Products** — full CRUD with **multiple image upload**, **variant management**, and **flash-deal scheduling**
- **Categories** — create / update / delete (image upload from device)
- **Coupons** — percentage or fixed, min-total and expiry rules
- **Banners** — manage the home carousel, link a banner to a product or category
- **Users** — search users, promote / demote admins (primary admin protected)
- **Orders** — view all, update status (stock is returned automatically on cancel)

---

## Tech Stack

| Layer | Tools |
|-------|-------|
| State management | `flutter_bloc` (Cubit), `equatable` |
| Networking | `dio`, `pretty_dio_logger` |
| DI | `get_it` (service locator) |
| Error handling | `dartz` (`Either<Failure, T>`) |
| UI | `flutter_screenutil`, `cached_network_image`, `shimmer`, `fl_chart` |
| Media | `image_picker`, `share_plus` |
| Push | `firebase_core`, `firebase_messaging` (FCM) |
| Tooling | `flutter_launcher_icons` |
| Localization | `easy_localization` (ar / en) |
| Storage | `shared_preferences` |
| Companion API | Laravel 10, Sanctum, MySQL *(consumed by the app, not part of my work)* |

---

## Project Structure

```
ecommerce_app/
├── frontend/                 # Flutter app
│   ├── lib/
│   │   ├── core/             # theme, network (Dio + service locator), widgets, utils
│   │   └── features/         # feature-first modules
│   │       ├── auth/  home/  cart/  checkout/  order/
│   │       ├── address/  wishlist/  settings/  admin/
│   │       └── onboarding/  splash/
│   │           └── <feature>/
│   │               ├── data/          (models, repo, repo_impl)
│   │               └── presentation/  (view, view_model/cubit)
│   └── assets/translations/  # en.json, ar.json
└── backend/                  # companion Laravel API (consumed by the app)
    ├── app/Http/Controllers  # Auth, Product, Cart, Order, Coupon, Admin…
    ├── app/Models
    ├── database/migrations
    └── routes/api.php
```

Each feature follows the same layering: **model → repo (abstract) → repo_impl
(Dio) → cubit → view**, with failures modelled as `Either<Failure, T>`.

---

## Getting Started

### 1. Companion API (Laravel)

> The API is included so you can run the full stack locally. It is a companion
> backend the app talks to — the focus of this project is the Flutter client.

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate

# configure your database (MySQL) in .env, then:
php artisan migrate --seed
php artisan storage:link          # required so uploaded images are served
php artisan serve                 # http://127.0.0.1:8000
```

> **Note:** `storage:link` must point at *this* project. If the repo was copied
> from another folder, delete `backend/public/storage` and re-run the command.

**Seeded demo accounts:**

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@shopsphere.com` | `admin123` |
| Customer | `customer@shopsphere.com` | `password` |

### 2. Frontend (Flutter)

```bash
cd frontend
flutter pub get
```

Point the app at your API with `--dart-define` (no code edits needed):

```bash
flutter run --dart-define=API_BASE_URL=https://your-app.up.railway.app/api/
```

If you omit it, the app falls back to a local address (edit `_defaultBaseUrl`
in [`frontend/lib/core/network/api_service.dart`](frontend/lib/core/network/api_service.dart)):

| Target | Base URL |
|--------|----------|
| Android emulator | `http://10.0.2.2:8000/api/` |
| iOS simulator / desktop | `http://127.0.0.1:8000/api/` |
| Physical device (same Wi-Fi) | `http://YOUR_COMPUTER_LAN_IP:8000/api/` |

For a release build, pass the same flag:

```bash
flutter build apk --dart-define=API_BASE_URL=https://your-app.up.railway.app/api/
```

---

## API Overview

Base path: `/api` · Auth: `Authorization: Bearer <token>` (Sanctum)

**Public**
```
POST /register            POST /login
POST /password/forgot     POST /password/reset
GET  /categories          GET  /categories/{id}
GET  /products            GET  /products/{id}
GET  /products/{id}/related    GET /products/{id}/reviews
```

**Authenticated**
```
GET  /me                  POST /logout        POST /profile
GET/POST/PUT/DELETE /cart      POST /coupons/apply
GET/POST/PATCH /orders         apiResource /addresses
POST /products/{id}/reviews    POST /wishlist/{id}
GET  /notifications       POST /notifications/read-all
PATCH /notifications/{id}/read
POST /device-tokens       DELETE /device-tokens   (FCM registration)
```

**Admin** (`/admin`, requires admin role)
```
Products, Categories, Coupons CRUD
GET  /admin/orders     PATCH /admin/orders/{id}/status
GET  /admin/stats
```

---

## Localization & Theming

- Strings live in [`frontend/assets/translations/en.json`](frontend/assets/translations/en.json) and `ar.json`.
- Arabic switches the app to RTL automatically.
- Theme (System / Light / Dark) and language are toggled from the Profile screen.

---

## Deploying the API (Railway)

The `backend/` folder ships a `Dockerfile`, `railway.json`, and a startup
script, so Railway can build and run it as-is.

1. **Push to GitHub** (already done), then on [railway.app](https://railway.app)
   choose **New Project → Deploy from GitHub repo**.
2. In the service **Settings**, set **Root Directory** to `backend`.
3. Add a **MySQL** database to the project (**New → Database → MySQL**).
4. Uploaded images (products, avatars, banners, categories) go to
   **Cloudinary**, so no persistent volume is needed. Grab the single
   `CLOUDINARY_URL` from your Cloudinary dashboard for the variables below.
5. Set the service **Variables**:

   | Variable | Value |
   |----------|-------|
   | `APP_KEY` | `base64:...` (run `php artisan key:generate --show` locally) |
   | `APP_ENV` | `production` |
   | `APP_DEBUG` | `false` |
   | `APP_URL` | `https://your-app.up.railway.app` |
   | `DB_URL` | `${{MySQL.MYSQL_URL}}` (Railway reference variable) |
   | `CLOUDINARY_URL` | `cloudinary://API_KEY:API_SECRET@CLOUD_NAME` |
   | `LOG_CHANNEL` | `stderr` |
   | `FCM_CREDENTIALS` | *(optional)* Firebase service-account JSON — see below |

6. Deploy. On boot the container runs `migrate --force` automatically.
7. One-off, to load demo data, open the service **Shell** and run:
   `php artisan db:seed --force`.
8. Point the app at it:
   `flutter run --dart-define=API_BASE_URL=https://your-app.up.railway.app/api/`

> Uploaded images are served from Cloudinary's CDN over `https://`, so they
> survive redeploys and load fast anywhere. The dev server (`php artisan serve`)
> is fine for a demo; swap in nginx + php-fpm for heavier production traffic.

---

## Push notifications (FCM)

Order-status pushes are optional — the app works with in-app notifications on
its own, and push simply stays disabled until Firebase is configured.

**Client (Flutter):**

```bash
dart pub global activate flutterfire_cli
flutterfire configure          # registers the app, writes google-services.json
```

**Server (Laravel):** in the Firebase console, open **Project settings →
Service accounts → Generate new private key**, then set the whole JSON as the
`FCM_CREDENTIALS` env var on the API service. The backend signs an FCM HTTP v1
request with it and pushes to the customer's registered devices on every order
update. The device token is registered from the app after login via
`POST /device-tokens`.

> The service-account key is a secret — keep it in the env var only, never in
> the repo. `google-services.json` is client config and is safe to commit.

---

## App icon

The launcher icon is generated from `frontend/assets/icon/` with
[`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons).
To use your own logo, replace `frontend/assets/icon/icon_full.png` (1024×1024) and run:

```bash
dart run flutter_launcher_icons
```

---

## License

This project is provided for educational and portfolio use.
