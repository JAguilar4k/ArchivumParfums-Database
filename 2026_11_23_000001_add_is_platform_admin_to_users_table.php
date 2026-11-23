<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Mark the accounts that administer the platform (#347). The mark lives on the account, not on a business: users has
     * no business_id and no row policy, so no policy changes and the application role keeps working without BYPASSRLS.
     */
    public function up(): void
    {
        DB::statement('ALTER TABLE users ADD COLUMN is_platform_admin boolean NOT NULL DEFAULT false');
    }

    /** Remove the mark. */
    public function down(): void
    {
        DB::statement('ALTER TABLE users DROP COLUMN is_platform_admin');
    }
};
