const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Supabase client
const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Middleware
app.use(cors());
app.use(express.json());

// Environment variables
const APP_URL = process.env.APP_URL || 'https://app.brainstorm.co';
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
const SMTP_HOST = process.env.SMTP_HOST;
const SMTP_PORT = process.env.SMTP_PORT || 587;
const SMTP_USER = process.env.SMTP_USER;
const SMTP_PASS = process.env.SMTP_PASS;
const SMTP_FROM = process.env.SMTP_FROM || 'noreply@brainstorm.co';
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
const GITHUB_CLIENT_ID = process.env.GITHUB_CLIENT_ID;
const GITHUB_CLIENT_SECRET = process.env.GITHUB_CLIENT_SECRET;

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'brainstorm-backend',
        version: '1.0.0',
        timestamp: new Date().toISOString()
    });
});

// MCP installer script endpoint
app.get('/install.sh', (req, res) => {
    const { site_url, api_key, site_name } = req.query;

    if (!site_url || !api_key) {
        return res.status(400).send('# Error: Missing site_url or api_key parameters\n# Usage: curl "https://brainstorm-backend-gk4th.ondigitalocean.app/install.sh?site_url=...&api_key=...&site_name=..." | bash');
    }

    const fs = require('fs');
    const path = require('path');

    // Read the installer script
    const scriptPath = path.join(__dirname, 'mcp-installer.sh');
    let script = fs.readFileSync(scriptPath, 'utf8');

    // Inject the parameters
    script = script.replace('SITE_URL="${SITE_URL:-}"', `SITE_URL="${site_url}"`);
    script = script.replace('API_KEY="${API_KEY:-}"', `API_KEY="${api_key}"`);
    script = script.replace('SITE_NAME="${SITE_NAME:-My WordPress Site}"', `SITE_NAME="${site_name || 'My WordPress Site'}"`);

    res.setHeader('Content-Type', 'text/plain');
    res.setHeader('Content-Disposition', 'attachment; filename="install-brainstorm-mcp.sh"');
    res.send(script);
});

// Site registration endpoint
app.post('/api/v1/sites/register', async (req, res) => {
    try {
        const {
            site_url,
            site_name,
            admin_email,
            wordpress_version,
            php_version,
            plugin_version,
            api_key,
            theme,
            is_multisite,
            environment,
            registration_timestamp,
            server_ip
        } = req.body;

        if (!site_url || !admin_email) {
            return res.status(400).json({
                success: false,
                message: 'Site URL and admin email required'
            });
        }

        // Get user_id from access token if provided
        const authHeader = req.headers.authorization;
        let user_id = null;

        if (authHeader && authHeader.startsWith('Bearer ')) {
            try {
                const token = authHeader.substring(7);
                const decoded = jwt.verify(token, JWT_SECRET);
                user_id = decoded.user_id;
            } catch (err) {
                console.log('Could not decode token, creating site without user association');
            }
        }

        // If no user_id from token, try to find user by email
        if (!user_id) {
            const { data: users } = await supabase.auth.admin.listUsers();
            const existingUser = users?.users?.find(u => u.email === admin_email);
            user_id = existingUser?.id;
        }

        // Generate a unique registration ID
        const registration_id = `site_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

        // Generate an access token for the site
        const access_token = jwt.sign(
            {
                registration_id,
                site_url,
                admin_email,
                user_id,
                timestamp: Date.now()
            },
            JWT_SECRET,
            { expiresIn: '365d' } // 1 year
        );

        // Save to Supabase
        const { data: site, error: dbError } = await supabase
            .from('sites')
            .insert({
                user_id,
                registration_id,
                site_url,
                site_name,
                admin_email,
                wordpress_version,
                php_version,
                plugin_version,
                api_key,
                theme,
                is_multisite: is_multisite || false,
                environment: environment || 'production',
                server_ip,
                access_token,
                status: 'active'
            })
            .select()
            .single();

        if (dbError) {
            console.error('Database error:', dbError);
            // Continue even if database fails - return success to WordPress
        }

        console.log(`Site registered: ${site_name} (${site_url})${user_id ? ` for user ${user_id}` : ''}`);

        res.status(201).json({
            success: true,
            registration_id,
            access_token,
            message: 'Site registered successfully',
            registered_at: new Date().toISOString()
        });

    } catch (error) {
        console.error('Site registration error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to register site'
        });
    }
});

// Get user's sites endpoint
app.get('/api/v1/sites', async (req, res) => {
    try {
        // Get user_id from access token
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'Authorization token required'
            });
        }

        const token = authHeader.substring(7);
        const decoded = jwt.verify(token, JWT_SECRET);
        const user_id = decoded.user_id;

        if (!user_id) {
            return res.status(401).json({
                success: false,
                message: 'Invalid token'
            });
        }

        // Fetch sites for this user
        const { data: sites, error: dbError } = await supabase
            .from('sites')
            .select('*')
            .eq('user_id', user_id)
            .order('created_at', { ascending: false });

        if (dbError) {
            console.error('Database error:', dbError);
            return res.status(500).json({
                success: false,
                message: 'Failed to fetch sites'
            });
        }

        res.json({
            success: true,
            sites: sites || [],
            total: sites?.length || 0
        });

    } catch (error) {
        console.error('Fetch sites error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch sites'
        });
    }
});

// Heartbeat endpoint - Update last_heartbeat for a site
app.post('/api/v1/sites/heartbeat', async (req, res) => {
    try {
        const { registration_id } = req.body;

        if (!registration_id) {
            return res.status(400).json({
                success: false,
                message: 'Registration ID required'
            });
        }

        // Update last_heartbeat timestamp
        const { data, error } = await supabase
            .from('sites')
            .update({
                last_heartbeat: new Date().toISOString(),
                status: 'active'
            })
            .eq('registration_id', registration_id)
            .select()
            .single();

        if (error) {
            console.error('Heartbeat update error:', error);
            return res.status(500).json({
                success: false,
                message: 'Failed to update heartbeat'
            });
        }

        res.json({
            success: true,
            last_heartbeat: data.last_heartbeat,
            site_name: data.site_name
        });

    } catch (error) {
        console.error('Heartbeat error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to process heartbeat'
        });
    }
});

// Get site information by registration_id
app.get('/api/v1/sites/:registration_id', async (req, res) => {
    try {
        const { registration_id } = req.params;

        const { data, error } = await supabase
            .from('sites')
            .select('*')
            .eq('registration_id', registration_id)
            .single();

        if (error) {
            console.error('Site fetch error:', error);
            return res.status(404).json({
                success: false,
                message: 'Site not found'
            });
        }

        res.json({
            success: true,
            site: data
        });

    } catch (error) {
        console.error('Site info error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch site information'
        });
    }
});

// Magic link authentication endpoint
app.post('/api/v1/auth/magic-link', async (req, res) => {
    try {
        const { email, site_url, redirect_url } = req.body;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email address required'
            });
        }

        // Generate JWT token for magic link
        const token = jwt.sign(
            { email, site_url, timestamp: Date.now() },
            JWT_SECRET,
            { expiresIn: '15m' }
        );

        // Construct magic link URL
        const magicLink = `${redirect_url}${redirect_url.includes('?') ? '&' : '?'}token=${token}`;

        // Send email
        if (SMTP_HOST && SMTP_USER && SMTP_PASS) {
            const transporter = nodemailer.createTransport({
                host: SMTP_HOST,
                port: SMTP_PORT,
                secure: SMTP_PORT == 465,
                auth: {
                    user: SMTP_USER,
                    pass: SMTP_PASS
                }
            });

            await transporter.sendMail({
                from: SMTP_FROM,
                to: email,
                subject: 'Your Brainstorm Magic Link',
                html: `
                    <h2>Welcome back to Brainstorm!</h2>
                    <p>Click the link below to log in (expires in 15 minutes):</p>
                    <p><a href="${magicLink}" style="display: inline-block; padding: 12px 24px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-decoration: none; border-radius: 8px;">Log in to Brainstorm</a></p>
                    <p>Or copy and paste this URL into your browser:</p>
                    <p>${magicLink}</p>
                    <p>If you didn't request this, you can safely ignore this email.</p>
                `
            });

            console.log(`Magic link sent to ${email}`);
        } else {
            // For testing without SMTP configured
            console.log(`Magic link (SMTP not configured): ${magicLink}`);
        }

        res.json({
            success: true,
            message: `Magic link sent to ${email}`,
            ...(process.env.NODE_ENV === 'development' && { debug_link: magicLink })
        });

    } catch (error) {
        console.error('Magic link error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to send magic link'
        });
    }
});

// Google OAuth URL endpoint
app.get('/api/v1/auth/google/url', (req, res) => {
    try {
        const { site_url, redirect_url } = req.query;

        if (!GOOGLE_CLIENT_ID) {
            return res.status(500).json({
                success: false,
                message: 'Google OAuth not configured'
            });
        }

        // Generate state parameter for CSRF protection
        const state = jwt.sign(
            { site_url, redirect_url, timestamp: Date.now() },
            JWT_SECRET,
            { expiresIn: '15m' }
        );

        // Construct Google OAuth URL
        const googleOAuthUrl = `https://accounts.google.com/o/oauth2/v2/auth?` +
            `client_id=${encodeURIComponent(GOOGLE_CLIENT_ID)}` +
            `&redirect_uri=${encodeURIComponent(`${APP_URL}/auth/google/callback`)}` +
            `&response_type=code` +
            `&scope=${encodeURIComponent('openid email profile')}` +
            `&state=${encodeURIComponent(state)}`;

        res.json({
            success: true,
            oauth_url: googleOAuthUrl
        });

    } catch (error) {
        console.error('Google OAuth URL error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to generate Google OAuth URL'
        });
    }
});

// GitHub OAuth URL endpoint
app.get('/api/v1/auth/github/url', (req, res) => {
    try {
        const { site_url, redirect_url } = req.query;

        if (!GITHUB_CLIENT_ID) {
            return res.status(500).json({
                success: false,
                message: 'GitHub OAuth not configured'
            });
        }

        // Generate state parameter for CSRF protection
        const state = jwt.sign(
            { site_url, redirect_url, timestamp: Date.now() },
            JWT_SECRET,
            { expiresIn: '15m' }
        );

        // Construct GitHub OAuth URL
        const githubOAuthUrl = `https://github.com/login/oauth/authorize?` +
            `client_id=${encodeURIComponent(GITHUB_CLIENT_ID)}` +
            `&redirect_uri=${encodeURIComponent(`${APP_URL}/auth/github/callback`)}` +
            `&scope=${encodeURIComponent('user:email')}` +
            `&state=${encodeURIComponent(state)}`;

        res.json({
            success: true,
            oauth_url: githubOAuthUrl
        });

    } catch (error) {
        console.error('GitHub OAuth URL error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to generate GitHub OAuth URL'
        });
    }
});

// Google OAuth callback
app.get('/auth/google/callback', async (req, res) => {
    try {
        const { code, state } = req.query;

        // Verify state parameter
        const decoded = jwt.verify(state, JWT_SECRET);
        const { site_url, redirect_url } = decoded;

        // Exchange code for token
        const tokenResponse = await axios.post('https://oauth2.googleapis.com/token', {
            code,
            client_id: GOOGLE_CLIENT_ID,
            client_secret: GOOGLE_CLIENT_SECRET,
            redirect_uri: `${APP_URL}/auth/google/callback`,
            grant_type: 'authorization_code'
        });

        const { access_token } = tokenResponse.data;

        // Get user info
        const userResponse = await axios.get('https://www.googleapis.com/oauth2/v2/userinfo', {
            headers: { Authorization: `Bearer ${access_token}` }
        });

        const { email, name } = userResponse.data;

        // Create or get user in Supabase
        const { data: authData, error: authError } = await supabase.auth.admin.createUser({
            email,
            email_confirm: true,
            user_metadata: { name, provider: 'google' }
        });

        let userId;
        if (authError && authError.message.includes('already registered')) {
            // User exists, get their ID
            const { data: users } = await supabase.auth.admin.listUsers();
            const existingUser = users.users.find(u => u.email === email);
            userId = existingUser?.id;
        } else {
            userId = authData?.user?.id;
        }

        // Generate session token
        const sessionToken = jwt.sign(
            { email, name, provider: 'google', user_id: userId, timestamp: Date.now() },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        // Redirect back to WordPress with token
        const finalRedirect = `${redirect_url}${redirect_url.includes('?') ? '&' : '?'}token=${sessionToken}`;
        res.redirect(finalRedirect);

    } catch (error) {
        console.error('Google OAuth callback error:', error);
        res.status(500).send('Authentication failed');
    }
});

// GitHub OAuth callback
app.get('/auth/github/callback', async (req, res) => {
    try {
        const { code, state } = req.query;

        // Verify state parameter
        const decoded = jwt.verify(state, JWT_SECRET);
        const { site_url, redirect_url } = decoded;

        // Exchange code for token
        const tokenResponse = await axios.post('https://github.com/login/oauth/access_token', {
            client_id: GITHUB_CLIENT_ID,
            client_secret: GITHUB_CLIENT_SECRET,
            code,
            redirect_uri: `${APP_URL}/auth/github/callback`
        }, {
            headers: { Accept: 'application/json' }
        });

        const { access_token } = tokenResponse.data;

        // Get user info
        const userResponse = await axios.get('https://api.github.com/user', {
            headers: {
                Authorization: `Bearer ${access_token}`,
                Accept: 'application/vnd.github.v3+json'
            }
        });

        const { email, name, login } = userResponse.data;
        const userEmail = email || `${login}@github.com`;
        const userName = name || login;

        // Create or get user in Supabase
        const { data: authData, error: authError } = await supabase.auth.admin.createUser({
            email: userEmail,
            email_confirm: true,
            user_metadata: { name: userName, provider: 'github', github_login: login }
        });

        let userId;
        if (authError && authError.message.includes('already registered')) {
            // User exists, get their ID
            const { data: users } = await supabase.auth.admin.listUsers();
            const existingUser = users.users.find(u => u.email === userEmail);
            userId = existingUser?.id;
        } else {
            userId = authData?.user?.id;
        }

        // Generate session token
        const sessionToken = jwt.sign(
            { email: userEmail, name: userName, provider: 'github', user_id: userId, timestamp: Date.now() },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        // Redirect back to WordPress with token
        const finalRedirect = `${redirect_url}${redirect_url.includes('?') ? '&' : '?'}token=${sessionToken}`;
        res.redirect(finalRedirect);

    } catch (error) {
        console.error('GitHub OAuth callback error:', error);
        res.status(500).send('Authentication failed');
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`Brainstorm Backend API running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Health check: http://localhost:${PORT}/api/health`);
});
