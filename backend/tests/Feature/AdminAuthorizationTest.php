<?php

namespace Tests\Feature;

use App\Models\Banner;
use App\Models\Category;
use App\Models\Coupon;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    private function adminEndpoints(): array
    {
        $product = Product::factory()->create();
        $category = Category::factory()->create();
        $coupon = Coupon::factory()->create();
        $banner = Banner::create(['image' => 'https://res.cloudinary.com/x/banner.png', 'is_active' => true]);
        $order = Order::factory()->create();
        $user = User::factory()->create();

        return [
            ['get', '/api/admin/stats'],
            ['get', '/api/admin/users'],
            ['patch', "/api/admin/users/{$user->id}/role"],
            ['post', '/api/admin/products'],
            ['put', "/api/admin/products/{$product->id}"],
            ['delete', "/api/admin/products/{$product->id}"],
            ['post', '/api/admin/categories'],
            ['put', "/api/admin/categories/{$category->id}"],
            ['delete', "/api/admin/categories/{$category->id}"],
            ['get', '/api/admin/coupons'],
            ['post', '/api/admin/coupons'],
            ['delete', "/api/admin/coupons/{$coupon->id}"],
            ['get', '/api/admin/banners'],
            ['post', '/api/admin/banners'],
            ['put', "/api/admin/banners/{$banner->id}"],
            ['delete', "/api/admin/banners/{$banner->id}"],
            ['get', '/api/admin/orders'],
            ['patch', "/api/admin/orders/{$order->id}/status"],
        ];
    }

    public function test_customers_are_forbidden_from_every_admin_endpoint(): void
    {
        Sanctum::actingAs(User::factory()->create(['role' => 'customer']));

        foreach ($this->adminEndpoints() as [$method, $uri]) {
            $response = $this->json($method, $uri);
            $this->assertSame(
                403,
                $response->status(),
                "Expected 403 for customer on {$method} {$uri}, got {$response->status()}"
            );
        }
    }

    public function test_guests_are_unauthorized_on_every_admin_endpoint(): void
    {
        foreach ($this->adminEndpoints() as [$method, $uri]) {
            $response = $this->json($method, $uri);
            $this->assertSame(
                401,
                $response->status(),
                "Expected 401 for guest on {$method} {$uri}, got {$response->status()}"
            );
        }
    }

    public function test_admin_can_list_stats_users_and_orders(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->getJson('/api/admin/stats')->assertOk();
        $this->getJson('/api/admin/users')->assertOk();
        $this->getJson('/api/admin/orders')->assertOk();
        $this->getJson('/api/admin/coupons')->assertOk();
        $this->getJson('/api/admin/banners')->assertOk();
    }

    public function test_admin_can_create_a_product(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson('/api/admin/products', [
            'title' => 'New Gadget',
            'price' => 199.99,
            'stock' => 5,
        ])->assertCreated()->assertJsonPath('data.title', 'New Gadget');

        $this->assertDatabaseHas('products', ['title' => 'New Gadget']);
    }

    public function test_admin_can_create_a_category(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson('/api/admin/categories', [
            'name' => 'Gaming',
            'slug' => 'gaming',
        ])->assertCreated();

        $this->assertDatabaseHas('categories', ['slug' => 'gaming']);
    }

    public function test_admin_can_create_a_coupon(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson('/api/admin/coupons', [
            'code' => 'WELCOME',
            'discount_type' => 'fixed',
            'amount' => 25,
        ])->assertCreated();

        $this->assertDatabaseHas('coupons', ['code' => 'WELCOME']);
    }

    public function test_admin_cannot_change_their_own_role(): void
    {
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        $this->patchJson("/api/admin/users/{$admin->id}/role", ['role' => 'customer'])
            ->assertStatus(422);

        $this->assertDatabaseHas('users', ['id' => $admin->id, 'role' => 'admin']);
    }

    public function test_admin_can_promote_a_customer_to_admin(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());
        $customer = User::factory()->create(['role' => 'customer']);

        $this->patchJson("/api/admin/users/{$customer->id}/role", ['role' => 'admin'])
            ->assertOk();

        $this->assertDatabaseHas('users', ['id' => $customer->id, 'role' => 'admin']);
    }
}
