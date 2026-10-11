-- ==============================================================================
-- SUPABASE CMS DATABASE SCHEMA UNTUK PORTOFOLIO MUHAMAD DIMAS NURZAKY
-- Salin dan jalankan script ini di: Supabase Dashboard -> SQL Editor -> Run
-- ==============================================================================

-- 1. TABEL PROJECTS
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT DEFAULT 'Web Development',
    tags TEXT NOT NULL, -- Contoh: "Laravel, PHP, MySQL, Authentication"
    badge TEXT DEFAULT 'Project',
    image_url TEXT,
    demo_url TEXT,
    github_url TEXT,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABEL EXPERIENCES
CREATE TABLE IF NOT EXISTS public.experiences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company TEXT NOT NULL,
    role TEXT NOT NULL,
    type TEXT DEFAULT 'INTERNSHIP',
    stack_badge TEXT, -- Contoh: "Laravel & MySQL"
    description_points JSONB DEFAULT '[]'::JSONB, -- Array string: ["Point 1", "Point 2"]
    cert_title TEXT,
    cert_id TEXT,
    cert_desc TEXT,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL CERTIFICATIONS
CREATE TABLE IF NOT EXISTS public.certifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    issuer TEXT NOT NULL,
    issue_date TEXT NOT NULL, -- Contoh: "Agu 2025"
    description TEXT NOT NULL,
    credential_id TEXT,
    credential_url TEXT,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABEL MESSAGES (Kontak Masuk dari Form Portofolio)
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    topic TEXT,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policy untuk Public (Pengunjung Website)
-- 1. Public bisa membaca data Projects, Experiences, Certifications
CREATE POLICY "Allow public read on projects" 
    ON public.projects FOR SELECT USING (true);

CREATE POLICY "Allow public read on experiences" 
    ON public.experiences FOR SELECT USING (true);

CREATE POLICY "Allow public read on certifications" 
    ON public.certifications FOR SELECT USING (true);

-- 2. Public bisa mengirim pesan melalui Form Kontak
CREATE POLICY "Allow public insert on messages" 
    ON public.messages FOR INSERT WITH CHECK (true);

-- Policy untuk Authenticated User (Admin CMS)
-- User yang login (Admin) punya hak penuh CRUD (Create, Read, Update, Delete)
CREATE POLICY "Allow full access for authenticated users on projects" 
    ON public.projects FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow full access for authenticated users on experiences" 
    ON public.experiences FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow full access for authenticated users on certifications" 
    ON public.certifications FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow full access for authenticated users on messages" 
    ON public.messages FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ==============================================================================
-- SEED INITIAL DATA (Data bawaan portofolio)
-- ==============================================================================

-- Seed Projects
INSERT INTO public.projects (title, description, category, tags, badge, sort_order)
VALUES
('Secural ID — Cyber Security Portal', 'Platform edukasi keamanan siber dan perlindungan identitas digital masyarakat hasil kolaborasi Kominfo Digital Literacy Program.', 'Security & Education', 'React, Tailwind CSS, JavaScript, Figma', 'Kominfo Jul 2025', 1),
('CARDS Backend CMS System', 'Pengembangan modul CMS backend Laravel untuk platform CARDS PT Cazh Teknologi Inovasi, menangani pengelolaan data pengguna.', 'Backend Laravel', 'Laravel, PHP, MySQL, Authentication', 'PT Cazh Intern', 2),
('Website Profil TK-KB Al-Fath', 'Sistem informasi profil sekolah, pendaftaran siswa baru, dan galeri kegiatan pembelajaran anak.', 'School Website', 'HTML5, CSS3, JavaScript, Tailwind', 'School Profile', 3),
('Azkal Jaya Las Booking Portal', 'Platform katalog produk kanopi & pagar beserta kalkulator estimasi biaya awal dan jadwal booking survey lokasi.', 'Workshop Catalog', 'HTML5, JavaScript, Tailwind CSS', 'Catalog & Survey', 4),
('Jelajahi Banyumas Directory', 'Platform web direktori informasi pariwisata, tempat bersejarah, dan destinasi kuliner khas Banyumas.', 'Culture & Tourism', 'HTML5, CSS3, JavaScript, Tailwind', 'Web Directory', 5),
('Arang Pinus & Mint Shoe Deodorizer', 'Website showcase interaktif produk inovasi penghilang bau sepatu berbasis bahan organik arang pinus dan ekstrak mint.', 'Product Showcase', 'Tailwind CSS, JavaScript, UI Design', 'Research Project', 6)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- MEDIA MIGRATION
-- Jalankan bagian ini jika tabel sudah pernah dibuat sebelumnya.
-- File gambar dibatasi di CMS hingga 2 MB dan disimpan di Supabase Storage.
-- ============================================================================

ALTER TABLE public.experiences
    ADD COLUMN IF NOT EXISTS attachment_url TEXT;

ALTER TABLE public.certifications
    ADD COLUMN IF NOT EXISTS attachment_url TEXT;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'portfolio-assets',
    'portfolio-assets',
    true,
    2097152,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Public can read portfolio assets" ON storage.objects;
CREATE POLICY "Public can read portfolio assets"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'portfolio-assets');

DROP POLICY IF EXISTS "Authenticated admins can upload portfolio assets" ON storage.objects;
CREATE POLICY "Authenticated admins can upload portfolio assets"
    ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'portfolio-assets');

DROP POLICY IF EXISTS "Authenticated admins can update portfolio assets" ON storage.objects;
CREATE POLICY "Authenticated admins can update portfolio assets"
    ON storage.objects FOR UPDATE TO authenticated
    USING (bucket_id = 'portfolio-assets')
    WITH CHECK (bucket_id = 'portfolio-assets');

DROP POLICY IF EXISTS "Authenticated admins can delete portfolio assets" ON storage.objects;
CREATE POLICY "Authenticated admins can delete portfolio assets"
    ON storage.objects FOR DELETE TO authenticated
    USING (bucket_id = 'portfolio-assets');

-- Seed Experiences
INSERT INTO public.experiences (company, role, type, stack_badge, description_points, cert_title, cert_id, cert_desc, sort_order)
VALUES
(
    'PT DENSO Indonesia',
    'Digitalization & Workflow Automation Intern',
    'INTERNSHIP',
    'Microsoft Power Platform',
    '["Mengembangkan aplikasi internal dan otomatisasi workflow bisnis manufaktur menggunakan Microsoft Power Platform (Power Apps & Power Automate).", "Melakukan perancangan sistem informasi dan digitalisasi proses bisnis operasional untuk meningkatkan efisiensi kerja lintas departemen.", "Menganalisis kebutuhan pengguna internal dan merancang solusi teknologi yang intuitif serta terintegrasi."]'::JSONB,
    'Sertifikat Magang & Surat Keterangan Resmi PT DENSO Indonesia',
    'DENSO-INT-2023/889',
    'Verifikasi resmi penyelesaian program magang digitalisasi dan otomatisasi proses bisnis manufaktur berbasis Microsoft Power Platform.',
    1
),
(
    'PT CAZH Teknologi Inovasi',
    'Web Development Intern (Backend & RESTful API)',
    'INTERNSHIP',
    'Laravel & MySQL',
    '["Merancang dan mengembangkan RESTful API menggunakan Laravel/PHP serta pengelolaan database MySQL untuk platform CMS CARDS.", "Mengembangkan fitur autentikasi pengguna, manajemen hak akses (role authorization), dan optimasi query basis data.", "Berkolaborasi secara aktif dalam tim pengembang untuk memastikan performa sistem web sesuai dengan standar kebutuhan pengguna."]'::JSONB,
    'Sertifikat Magang Rekayasa Web & RESTful API',
    'CAZH-DEV-2023/104',
    'Verifikasi resmi kontribusi magang dalam perancangan backend Laravel, RESTful API CMS CARDS, dan optimasi database MySQL.',
    2
),
(
    'Dinas Kominfo Kota Semarang',
    'Web & Information System Intern',
    'INTERNSHIP',
    'Public Service Digitalization',
    '["Mendukung digitalisasi layanan publik dan perancangan sistem informasi bagi instansi pemerintah Kota Semarang.", "Mengembangkan modul aplikasi web interaktif, integrasi data publik, dan penyesuaian fungsionalitas antarmuka bagi masyarakat."]'::JSONB,
    'Surat Keterangan & Sertifikat Magang Pemerintah',
    'KM-SMR-2022/412',
    'Verifikasi resmi partisipasi magang dalam mendukung perancangan sistem informasi dan digitalisasi layanan publik pemerintah Kota Semarang.',
    3
)
ON CONFLICT DO NOTHING;

-- Seed Certifications
INSERT INTO public.certifications (title, issuer, issue_date, description, credential_id, credential_url, sort_order)
VALUES
(
    'Laravel & CMS Web Development',
    'PT Cazh Teknologi Inovasi — Professional Internship Certification',
    'Agu 2025',
    'Sertifikasi kompetensi praktik industri dalam pengembangan backend CMS CARDS, manajemen query database MySQL, dan penerapan skema otorisasi sistem.',
    'CAZH-INT-2025-08',
    '#',
    1
),
(
    'AWS Cloud Practitioner Essentials',
    'Amazon Web Services (AWS Training & Certification)',
    'Jul 2025',
    'Validasi pemahaman komprehensif konsep cloud computing, keamanan infrastruktur AWS, arsitektur komputasi awan, dan manajemen biaya.',
    'AWS-TRN-77821-CLD',
    '#',
    2
),
(
    'UI/UX Design Specialist',
    'Telkom University & Digital Creative Lab',
    'Mei 2025',
    'Sertifikasi kompetensi perancangan antarmuka pengguna, user research, wireframing, serta pengujian sistem interaktif berbasis Figma & CSS Framework.',
    'TELU-IT-UIUX-2025',
    '#',
    3
)
ON CONFLICT DO NOTHING;
