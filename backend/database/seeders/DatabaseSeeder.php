<?php

namespace Database\Seeders;

use App\Models\Banner;
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

        $imageMap = [
            'Wireless Headphones' => ['https://images.pexels.com/photos/3394650/pexels-photo-3394650.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/3394648/pexels-photo-3394648.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/3394653/pexels-photo-3394653.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Smart Watch Pro' => ['https://images.pexels.com/photos/31541678/pexels-photo-31541678.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/12564670/pexels-photo-12564670.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/28967487/pexels-photo-28967487.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Bluetooth Speaker' => ['https://images.pexels.com/photos/29581125/pexels-photo-29581125.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/12502430/pexels-photo-12502430.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/5552789/pexels-photo-5552789.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Wireless Earbuds' => ['https://images.pexels.com/photos/4526407/pexels-photo-4526407.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/3756985/pexels-photo-3756985.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/11296248/pexels-photo-11296248.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Gaming Mouse' => ['https://images.pexels.com/photos/12877898/pexels-photo-12877898.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/32890143/pexels-photo-32890143.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/9058886/pexels-photo-9058886.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Mechanical Keyboard' => ['https://images.pexels.com/photos/8219211/pexels-photo-8219211.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/18311171/pexels-photo-18311171.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/14063089/pexels-photo-14063089.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Power Bank 20000mAh' => ['https://images.pexels.com/photos/38649173/pexels-photo-38649173.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/4765366/pexels-photo-4765366.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/947407/pexels-photo-947407.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            '4K Monitor 27"' => ['https://images.pexels.com/photos/5552789/pexels-photo-5552789.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/29283981/pexels-photo-29283981.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/20487289/pexels-photo-20487289.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Cotton T-Shirt' => ['https://images.pexels.com/photos/5996939/pexels-photo-5996939.png?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/7818329/pexels-photo-7818329.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/966067/pexels-photo-966067.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Denim Jacket' => ['https://images.pexels.com/photos/3649765/pexels-photo-3649765.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/20954293/pexels-photo-20954293.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/8685990/pexels-photo-8685990.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Leather Backpack' => ['https://images.pexels.com/photos/18978810/pexels-photo-18978810.png?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/4452517/pexels-photo-4452517.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/26965828/pexels-photo-26965828.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Classic Sneakers' => ['https://images.pexels.com/photos/19845610/pexels-photo-19845610.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/25492111/pexels-photo-25492111.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/11761543/pexels-photo-11761543.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Aviator Sunglasses' => ['https://images.pexels.com/photos/32677246/pexels-photo-32677246.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/8364105/pexels-photo-8364105.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/28666270/pexels-photo-28666270.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Leather Wallet' => ['https://images.pexels.com/photos/4452503/pexels-photo-4452503.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/36343444/pexels-photo-36343444.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/4452506/pexels-photo-4452506.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Wool Hoodie' => ['https://images.pexels.com/photos/15564085/pexels-photo-15564085.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/977418/pexels-photo-977418.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/35240860/pexels-photo-35240860.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Baseball Cap' => ['https://images.pexels.com/photos/18434487/pexels-photo-18434487.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/6423437/pexels-photo-6423437.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/9743022/pexels-photo-9743022.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Coffee Maker' => ['https://images.pexels.com/photos/32103303/pexels-photo-32103303.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/13943377/pexels-photo-13943377.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/36573009/pexels-photo-36573009.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Table Lamp' => ['https://images.pexels.com/photos/31410610/pexels-photo-31410610.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/30727755/pexels-photo-30727755.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/35329516/pexels-photo-35329516.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Ceramic Mug Set' => ['https://images.pexels.com/photos/16033792/pexels-photo-16033792.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/35225525/pexels-photo-35225525.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/2168346/pexels-photo-2168346.png?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Scented Candle Set' => ['https://images.pexels.com/photos/30676121/pexels-photo-30676121.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/33180700/pexels-photo-33180700.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/278664/pexels-photo-278664.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Wall Clock' => ['https://images.pexels.com/photos/35070219/pexels-photo-35070219.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/36143696/pexels-photo-36143696.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/5740996/pexels-photo-5740996.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Throw Pillow' => ['https://images.pexels.com/photos/9290601/pexels-photo-9290601.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/27355165/pexels-photo-27355165.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/8634412/pexels-photo-8634412.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Kitchen Knife Set' => ['https://images.pexels.com/photos/14040574/pexels-photo-14040574.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/20392663/pexels-photo-20392663.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/16443132/pexels-photo-16443132.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Countertop Blender' => ['https://images.pexels.com/photos/20276493/pexels-photo-20276493.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/36573009/pexels-photo-36573009.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/38609262/pexels-photo-38609262.png?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Running Shoes' => ['https://images.pexels.com/photos/29342147/pexels-photo-29342147.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/29342144/pexels-photo-29342144.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/29342151/pexels-photo-29342151.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Yoga Mat' => ['https://images.pexels.com/photos/8436580/pexels-photo-8436580.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/6916301/pexels-photo-6916301.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/16148425/pexels-photo-16148425.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Adjustable Dumbbell' => ['https://images.pexels.com/photos/11433027/pexels-photo-11433027.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/9073247/pexels-photo-9073247.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/10518845/pexels-photo-10518845.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Sports Water Bottle' => ['https://images.pexels.com/photos/13871766/pexels-photo-13871766.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/37935977/pexels-photo-37935977.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/32116008/pexels-photo-32116008.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Football' => ['https://images.pexels.com/photos/28222529/pexels-photo-28222529.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/11644798/pexels-photo-11644798.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/10466535/pexels-photo-10466535.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Tennis Racket' => ['https://images.pexels.com/photos/13789945/pexels-photo-13789945.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/16686174/pexels-photo-16686174.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/16639180/pexels-photo-16639180.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Bike Helmet' => ['https://images.pexels.com/photos/38463220/pexels-photo-38463220.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/11355176/pexels-photo-11355176.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/11155175/pexels-photo-11155175.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
            'Resistance Bands Set' => ['https://images.pexels.com/photos/7072051/pexels-photo-7072051.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/28970127/pexels-photo-28970127.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600', 'https://images.pexels.com/photos/8436147/pexels-photo-8436147.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=600&h=600'],
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
                    'deal_ends_at' => $sale !== null ? now()->addHours(mt_rand(6, 72)) : null,
                    'stock' => mt_rand(15, 80),
                    'images' => $imageMap[$title] ?? [$this->img($kw, 1), $this->img($kw, 2), $this->img($kw, 3)],
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

        $banners = [
            ['https://images.pexels.com/photos/7987759/pexels-photo-7987759.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=900&h=400', 'Mega Sale', 'Up to 30% off electronics', 'category', $id('electronics'), 1],
            ['https://images.pexels.com/photos/16888144/pexels-photo-16888144.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=900&h=400', 'New Gadgets', 'Latest tech just landed', 'category', $id('electronics'), 2],
            ['https://images.pexels.com/photos/8311880/pexels-photo-8311880.jpeg?auto=compress&cs=tinysrgb&fit=crop&w=900&h=400', 'Fashion Picks', 'Fresh styles for the season', 'category', $id('fashion'), 3],
        ];
        foreach ($banners as [$image, $title, $subtitle, $lt, $lv, $sort]) {
            Banner::updateOrCreate(
                ['title' => $title],
                ['image' => $image, 'subtitle' => $subtitle, 'link_type' => $lt, 'link_value' => $lv, 'is_active' => true, 'sort_order' => $sort]
            );
        }

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
