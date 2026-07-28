# Bazar Backend (Laravel 10 + Sanctum + XAMPP MySQL)

REST API for the Bazar e-commerce app. Runs on XAMPP's bundled PHP 8.1
and MySQL (MariaDB) — no Homebrew needed.

## Stack
- **Laravel 10** (last version supporting PHP 8.1, which XAMPP ships)
- **Sanctum 3** token auth
- **MySQL/MariaDB** via XAMPP

> Paths below assume XAMPP at `/Applications/XAMPP`. The PHP binary is
> `/Applications/XAMPP/xamppfiles/bin/php`. Add it to your PATH to type just
> `php`:
> ```bash
> export PATH="/Applications/XAMPP/xamppfiles/bin:$PATH"
> ```

## 1. Start MySQL (XAMPP)
```bash
sudo /Applications/XAMPP/xamppfiles/xampp startmysql
```
(or open the **XAMPP** app → Manage Servers → start **MySQL Database**)

## 2. Install dependencies
Composer is bundled locally as `composer.phar`:
```bash
cd backend
/Applications/XAMPP/xamppfiles/bin/php composer.phar install
```

## 3. Environment
```bash
cp .env.example .env
/Applications/XAMPP/xamppfiles/bin/php artisan key:generate
```
The default DB config matches XAMPP (host `127.0.0.1`, user `root`, empty password).

## 4. Create the database
```bash
/Applications/XAMPP/xamppfiles/bin/mysql -u root -h 127.0.0.1 \
  -e "CREATE DATABASE IF NOT EXISTS shopsphere CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

## 5. Migrate + seed
```bash
/Applications/XAMPP/xamppfiles/bin/php artisan migrate --seed
```
Seed creates:
- Admin → `admin@shopsphere.com` / `admin123`
- Customer → `customer@shopsphere.com` / `password`
- 4 categories, 10 products, coupon `WELCOME10` (10% off, min 500).

## 6. Run
```bash
/Applications/XAMPP/xamppfiles/bin/php artisan serve --host=127.0.0.1 --port=8000
```
API base URL: **http://127.0.0.1:8000/api**

Quick test:
```bash
curl http://127.0.0.1:8000/api/products
```

## Connecting from Flutter
`lib/core/network/api_service.dart` → `_baseUrl`:
- iOS simulator / desktop / web: `http://127.0.0.1:8000/api/`
- Android emulator: `http://10.0.2.2:8000/api/`
- Real device: `http://<your-computer-LAN-IP>:8000/api/`

## API overview

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/register` | – | Sign up, returns token |
| POST | `/api/login` | – | Sign in, returns token |
| GET | `/api/me` | ✔ | Current user |
| POST | `/api/logout` | ✔ | Revoke token |
| GET | `/api/categories` | – | List categories |
| GET | `/api/products` | – | List/search/filter products |
| GET | `/api/products/{id}` | – | Product details + variants + reviews |
| POST | `/api/products/{id}/reviews` | ✔ | Add/update review |
| GET/POST | `/api/wishlist` | ✔ | Wishlist + toggle |
| GET/POST/PUT/DELETE | `/api/cart` | ✔ | Cart management |
| POST | `/api/coupons/apply` | ✔ | Validate coupon on cart |
| GET/POST/PUT/DELETE | `/api/addresses` | ✔ | Address book |
| POST | `/api/orders` | ✔ | Checkout the cart |
| GET | `/api/orders` | ✔ | Order history |
| ... | `/api/admin/*` | ✔ admin | Products/categories/coupons/orders/stats |

### Product query params
`?search=` `&category_id=` `&brand=` `&min_price=` `&max_price=`
`&min_rating=` `&featured=1` `&sort=price_asc|price_desc|rating|newest` `&per_page=`

### Auth header
```
Authorization: Bearer <token>
```
