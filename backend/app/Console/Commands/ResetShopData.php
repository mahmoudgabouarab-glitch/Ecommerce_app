<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ResetShopData extends Command
{
    protected $signature = 'app:reset-data {--force : Skip the confirmation prompt}';

    protected $description = 'Wipe all orders, reviews and notifications, and zero product ratings/revenue.';

    public function handle(): int
    {
        if (! $this->option('force')
            && ! $this->confirm('This permanently deletes ALL orders, reviews and notifications, and resets ratings. Continue?')) {
            $this->warn('Aborted.');

            return self::SUCCESS;
        }

        Schema::disableForeignKeyConstraints();
        DB::table('order_items')->truncate();
        DB::table('orders')->truncate();
        DB::table('reviews')->truncate();
        DB::table('app_notifications')->truncate();
        Schema::enableForeignKeyConstraints();

        Product::query()->update(['rating' => 0, 'rating_count' => 0]);

        $this->info('Done — orders, reviews and notifications cleared; revenue and ratings zeroed.');

        return self::SUCCESS;
    }
}
