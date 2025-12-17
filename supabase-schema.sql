-- Brainstorm Sites Table
-- Stores registered WordPress sites linked to user accounts

CREATE TABLE IF NOT EXISTS public.sites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Site identification
    registration_id TEXT UNIQUE NOT NULL,
    site_url TEXT NOT NULL,
    site_name TEXT NOT NULL,
    admin_email TEXT NOT NULL,

    -- Technical details
    wordpress_version TEXT,
    php_version TEXT,
    plugin_version TEXT,
    theme TEXT,
    is_multisite BOOLEAN DEFAULT false,
    environment TEXT DEFAULT 'production',

    -- Security
    api_key TEXT NOT NULL,
    access_token TEXT,
    server_ip TEXT,

    -- Status tracking
    status TEXT DEFAULT 'active',
    last_heartbeat TIMESTAMP WITH TIME ZONE,
    last_error TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_sites_user_id ON public.sites(user_id);
CREATE INDEX IF NOT EXISTS idx_sites_registration_id ON public.sites(registration_id);
CREATE INDEX IF NOT EXISTS idx_sites_status ON public.sites(status);

-- Row Level Security (RLS)
ALTER TABLE public.sites ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own sites
CREATE POLICY "Users can view own sites" ON public.sites
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can insert their own sites
CREATE POLICY "Users can insert own sites" ON public.sites
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own sites
CREATE POLICY "Users can update own sites" ON public.sites
    FOR UPDATE USING (auth.uid() = user_id);

-- Policy: Users can delete their own sites
CREATE POLICY "Users can delete own sites" ON public.sites
    FOR DELETE USING (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.sites
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Comments for documentation
COMMENT ON TABLE public.sites IS 'WordPress sites registered with Brainstorm';
COMMENT ON COLUMN public.sites.registration_id IS 'Unique identifier for the site registration';
COMMENT ON COLUMN public.sites.access_token IS 'JWT token for site authentication';
COMMENT ON COLUMN public.sites.last_heartbeat IS 'Last successful heartbeat from the site';
