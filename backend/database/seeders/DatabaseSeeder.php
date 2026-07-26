<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Coupon;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@shopsphere.com'],
            ['name' => 'Admin', 'password' => 'admin123', 'role' => 'admin', 'email_verified_at' => now()]
        );
        User::updateOrCreate(
            ['email' => 'customer@shopsphere.com'],
            ['name' => 'Ahmed Ali', 'password' => 'password', 'role' => 'customer', 'phone' => '01000000000', 'email_verified_at' => now()]
        );

        $categories = collect([
            ['name' => 'Electronics', 'slug' => 'electronics', 'kw' => 'electronics'],
            ['name' => 'Fashion', 'slug' => 'fashion', 'kw' => 'fashion'],
            ['name' => 'Home', 'slug' => 'home', 'kw' => 'home,decor'],
            ['name' => 'Sports', 'slug' => 'sports', 'kw' => 'sports'],
        ])->map(fn ($c) => Category::updateOrCreate(
            ['slug' => $c['slug']],
            ['name' => $c['name'], 'image_url' => $this->img($c['kw'], 1)]
        ));

        $id = fn (string $slug) => $categories->firstWhere('slug', $slug)->id;

        $products = [
            ['Wireless Headphones', 'electronics', 1200, 999, 'SoundMax', true, 'headphones'],
            ['Smart Watch Pro', 'electronics', 2500, null, 'TechWear', true, 'smartwatch'],
            ['Bluetooth Speaker', 'electronics', 800, 650, 'SoundMax', false, 'speaker'],
            ['Wireless Earbuds', 'electronics', 900, 720, 'SoundMax', true, 'earbuds'],
            ['Gaming Mouse', 'electronics', 550, null, 'HyperPlay', false, 'computer,mouse'],
            ['Mechanical Keyboard', 'electronics', 1350, 1150, 'HyperPlay', false, 'keyboard'],
            ['Power Bank 20000mAh', 'electronics', 700, null, 'VoltEdge', false, 'powerbank,battery'],
            ['4K Monitor 27"', 'electronics', 6500, 5900, 'ViewPro', true, 'monitor,computer'],

            ['Cotton T-Shirt', 'fashion', 300, 220, 'UrbanFit', false, 'tshirt'],
            ['Denim Jacket', 'fashion', 900, null, 'UrbanFit', true, 'denim,jacket'],
            ['Leather Backpack', 'fashion', 1450, 1200, 'CarryOn', true, 'leather,backpack'],
            ['Classic Sneakers', 'fashion', 1100, null, 'StepUp', false, 'sneakers'],
            ['Aviator Sunglasses', 'fashion', 650, 520, 'SunRay', false, 'sunglasses'],
            ['Leather Wallet', 'fashion', 400, null, 'CarryOn', false, 'wallet,leather'],
            ['Wool Hoodie', 'fashion', 750, 620, 'UrbanFit', true, 'hoodie'],
            ['Baseball Cap', 'fashion', 250, null, 'StepUp', false, 'cap,hat'],

            ['Coffee Maker', 'home', 2200, null, 'HomeBrew', false, 'coffee,machine'],
            ['Table Lamp', 'home', 450, 399, 'BrightHome', false, 'lamp'],
            ['Ceramic Mug Set', 'home', 350, null, 'HomeBrew', false, 'mug,coffee'],
            ['Scented Candle Set', 'home', 480, 399, 'AromaHome', true, 'candle'],
            ['Wall Clock', 'home', 600, null, 'BrightHome', false, 'clock'],
            ['Throw Pillow', 'home', 320, 260, 'CozyNest', false, 'pillow,cushion'],
            ['Kitchen Knife Set', 'home', 1250, null, 'ChefPro', true, 'knife,kitchen'],
            ['Countertop Blender', 'home', 1600, 1399, 'ChefPro', false, 'blender'],

            ['Running Shoes', 'sports', 1800, 1500, 'RunFast', true, 'running,shoes'],
            ['Yoga Mat', 'sports', 350, null, 'FlexFit', false, 'yoga,mat'],
            ['Adjustable Dumbbell', 'sports', 2400, 2100, 'IronCore', true, 'dumbbell'],
            ['Sports Water Bottle', 'sports', 220, null, 'HydroGo', false, 'water,bottle'],
            ['Football', 'sports', 500, 420, 'KickPro', false, 'football,soccer'],
            ['Tennis Racket', 'sports', 1900, null, 'AceSport', false, 'tennis,racket'],
            ['Bike Helmet', 'sports', 850, 700, 'SafeRide', false, 'bike,helmet'],
            ['Resistance Bands Set', 'sports', 380, null, 'FlexFit', true, 'fitness,bands'],
        ];

        foreach ($products as [$title, $cat, $price, $sale, $brand, $featured, $kw]) {
            Product::updateOrCreate(
                ['title' => $title],
                [
                    'category_id' => $id($cat),
                    'description' => $this->describe($title, $brand),
                    'brand' => $brand,
                    'price' => $price,
                    'sale_price' => $sale,
                    'stock' => mt_rand(15, 80),
                    'images' => [$this->img($kw, 1), $this->img($kw, 2), $this->img($kw, 3)],
                    'rating' => round(mt_rand(35, 50) / 10, 1),
                    'rating_count' => mt_rand(5, 240),
                    'is_featured' => $featured,
                ]
            );
        }

        $this->seedVariants();

        Coupon::updateOrCreate(
            ['code' => 'WELCOME10'],
            ['discount_type' => 'percent', 'amount' => 10, 'min_total' => 500, 'is_active' => true]
        );

        $this->command->info('Seeded '.count($products).' products with matching images.');
        $this->command->info('admin@shopsphere.com / admin123  |  customer@shopsphere.com / password');
    }

    private function seedVariants(): void
    {
        $sizes = ['S', 'M', 'L', 'XL'];
        $shoeSizes = ['40', '41', '42', '43', '44'];

        $map = [
            'Cotton T-Shirt' => $this->sizeVariants($sizes),
            'Denim Jacket' => $this->sizeVariants($sizes),
            'Wool Hoodie' => $this->sizeVariants($sizes),
            'Classic Sneakers' => $this->sizeVariants($shoeSizes),
            'Running Shoes' => $this->sizeVariants($shoeSizes),
        ];

        foreach ($map as $title => $variants) {
            $product = Product::where('title', $title)->first();
            if (! $product) {
                continue;
            }
            $product->variants()->delete();
            foreach ($variants as [$size, $color, $diff]) {
                ProductVariant::create([
                    'product_id' => $product->id,
                    'size' => $size,
                    'color' => $color,
                    'stock' => mt_rand(5, 30),
                    'price_diff' => $diff,
                ]);
            }
        }
    }

    private function sizeVariants(array $sizes): array
    {
        return array_map(
            fn ($s) => [$s, null, $s === 'XL' ? 50 : 0],
            $sizes
        );
    }

    private function img(string $keyword, int $lock): string
    {
        return "https://loremflickr.com/600/600/{$keyword}?lock={$lock}";
    }

    private function describe(string $title, string $brand): string
    {
        return "The $title by $brand combines premium quality with a sleek, "
            .'modern design. Built to last and perfect for everyday use — a '
            ."reliable choice you'll love.";
    }
}
