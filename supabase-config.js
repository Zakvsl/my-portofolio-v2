// ==============================================================================
// SUPABASE CONFIGURATION
// Ganti SUPABASE_URL dan SUPABASE_ANON_KEY dengan kredensial dari project Supabase Anda:
// Buka https://supabase.com -> Project Settings -> API
// ==============================================================================

const SUPABASE_CONFIG = {
    // Project URL Supabase
    url: 'https://caswsepbxzrjlbcuypcp.supabase.co',

    // Supabase Public API Key
    anonKey: 'sb_publishable_0hkOkQWdMzFbZnL6JdS66g_3OH6eeVI'
};

// Inisialisasi Supabase Client jika kredensial sudah diisi dan library tersedia
let supabaseClient = null;

function isSupabaseConfigured() {
    return Boolean(
        SUPABASE_CONFIG.url && 
        SUPABASE_CONFIG.url.startsWith('http') &&
        !SUPABASE_CONFIG.url.includes('YOUR_PROJECT_ID') &&
        SUPABASE_CONFIG.anonKey && 
        !SUPABASE_CONFIG.anonKey.includes('TEMPEL_') &&
        SUPABASE_CONFIG.anonKey.length > 15
    );
}

// Bersihkan format URL jika tidak sengaja terbawa path /rest/v1/
const cleanSupabaseUrl = (SUPABASE_CONFIG.url || '').replace(/\/rest\/v1\/?$/, '').replace(/\/+$/, '');

if (typeof supabase !== 'undefined' && isSupabaseConfigured()) {
    try {
        supabaseClient = supabase.createClient(cleanSupabaseUrl, SUPABASE_CONFIG.anonKey);
        console.log('Supabase client successfully initialized.');
    } catch (err) {
        console.warn('Gagal menginisialisasi Supabase client:', err);
    }
} else {
    console.info('Supabase belum dikonfigurasi dengan benar. Pastikan anonKey adalah token JWT panjang.');
}
