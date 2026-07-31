<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class StatsController extends Controller
{
    public function index()
    {
        return response()->json([
            'revenue' => round((float) Order::where('payment_status', 'paid')
                ->where('status', '!=', 'cancelled')->sum('total'), 2),
            'orders_count' => Order::count(),
            'pending_orders' => Order::where('status', 'pending')->count(),
            'customers_count' => User::where('role', 'customer')->count(),
            'products_count' => Product::count(),
            'orders_by_status' => Order::select('status', DB::raw('count(*) as count'))
                ->groupBy('status')
                ->pluck('count', 'status'),
            'top_products' => DB::table('order_items')
                ->join('orders', 'orders.id', '=', 'order_items.order_id')
                ->where('orders.status', '!=', 'cancelled')
                ->select('product_title', DB::raw('SUM(quantity) as sold'))
                ->groupBy('product_title')
                ->orderByDesc('sold')
                ->limit(5)
                ->get(),
            'sales_last_7_days' => $this->salesLast7Days(),
        ]);
    }

    private function salesLast7Days(): array
    {
        $rows = Order::where('payment_status', 'paid')
            ->where('status', '!=', 'cancelled')
            ->where('created_at', '>=', Carbon::today()->subDays(6))
            ->select(DB::raw('DATE(created_at) as day'), DB::raw('SUM(total) as total'))
            ->groupBy('day')
            ->pluck('total', 'day');

        $result = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i);
            $key = $date->format('Y-m-d');
            $result[] = [
                'date' => $key,
                'label' => $date->format('D'),
                'total' => round((float) ($rows[$key] ?? 0), 2),
            ];
        }

        return $result;
    }
}
