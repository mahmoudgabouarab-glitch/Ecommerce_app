<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('payment_status')
                ->default('unpaid')
                ->after('payment_method');
            $table->string('paymob_order_id')->nullable()->after('payment_status');
            $table->index('paymob_order_id');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['paymob_order_id']);
            $table->dropColumn(['payment_status', 'paymob_order_id']);
        });
    }
};
