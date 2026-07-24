<?php

namespace App\Http\Controllers;

use App\Http\Resources\AddressResource;
use App\Models\Address;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    // GET /api/addresses
    public function index(Request $request)
    {
        return AddressResource::collection(
            $request->user()->addresses()->latest()->get()
        );
    }

    // POST /api/addresses
    public function store(Request $request)
    {
        $data = $this->validateData($request);

        // First address becomes the default automatically.
        if ($request->user()->addresses()->count() === 0) {
            $data['is_default'] = true;
        }
        if (! empty($data['is_default'])) {
            $request->user()->addresses()->update(['is_default' => false]);
        }

        $address = $request->user()->addresses()->create($data);

        return new AddressResource($address);
    }

    // PUT /api/addresses/{address}
    public function update(Request $request, Address $address)
    {
        $this->authorizeOwner($request, $address);
        $data = $this->validateData($request);

        if (! empty($data['is_default'])) {
            $request->user()->addresses()->update(['is_default' => false]);
        }

        $address->update($data);

        return new AddressResource($address);
    }

    // DELETE /api/addresses/{address}
    public function destroy(Request $request, Address $address)
    {
        $this->authorizeOwner($request, $address);
        $address->delete();

        return response()->json(['message' => 'Address deleted.']);
    }

    private function validateData(Request $request): array
    {
        return $request->validate([
            'full_name' => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:30'],
            'line1' => ['required', 'string', 'max:255'],
            'city' => ['required', 'string', 'max:120'],
            'country' => ['nullable', 'string', 'max:120'],
            'is_default' => ['boolean'],
        ]);
    }

    private function authorizeOwner(Request $request, Address $address): void
    {
        abort_if($address->user_id !== $request->user()->id, 403, 'Forbidden.');
    }
}
