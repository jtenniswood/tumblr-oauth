# Tumblr OAuth Token Generator

**Generate OAuth tokens for the Tumblr API in 3 simple steps.**

## What This Does

This web app helps you get OAuth tokens for the Tumblr API:

1. **Enter your Tumblr app credentials** (Consumer Key & Secret)
2. **Authorize with Tumblr** (redirects to Tumblr's website)
3. **Copy your OAuth tokens** (ready to use in your API calls)

No coding required - just a simple web interface to handle the OAuth flow.

## Quick Start

**Run the container:**
```bash
docker run -p 8080:5000 ghcr.io/jtenniswood/tumblr-oauth:latest
```

You'll see a friendly startup message telling you exactly where to access the app:
```
============================================================
🚀 Tumblr OAuth Token Generator
============================================================
✅ Server starting...
🌐 Access the app at: http://localhost:8080
📝 Need help? Check: https://github.com/jtenniswood/tumblr-oauth
============================================================
```

**Or run with Docker Compose:**
```bash
cd docker && docker-compose up --build
```

> 💡 **Optimized for Size**: This container uses Alpine Linux and multi-stage builds for a minimal footprint (~110MB vs 542MB standard Python images).

## Before You Start: Get Tumblr API Credentials

You need a Consumer Key and Consumer Secret from Tumblr first:

1. **Go to:** https://www.tumblr.com/oauth/apps
2. **Login** to your Tumblr account
3. **Click** "Register application"
4. **Fill out the form:**
   - Application name: `My OAuth App` (or any name)
   - Application website: `http://localhost:8080`
   - Default callback URL: `http://localhost:8080/oauth/callback` ⚠️ **Must be exact**
   - Email: Your email address
5. **Save** your Consumer Key and Consumer Secret

## How to Use the App

1. **Start the container** (see Quick Start above)
2. **Open** http://localhost:8080 in your browser
3. **Enter** your Consumer Key and Consumer Secret
4. **Click** "Generate OAuth Tokens"
5. **Authorize** on Tumblr's website (opens automatically)
6. **Copy** your OAuth Token and OAuth Token Secret

## Troubleshooting

**"OAuth Error"**  
→ Double-check your Consumer Key and Consumer Secret

**"Callback URL mismatch"**  
→ Make sure you used exactly `http://localhost:8080/oauth/callback` in your Tumblr app settings

**"Port already in use"**  
→ Use a different port: `docker run -p 9090:5000 ghcr.io/jtenniswood/tumblr-oauth:latest`  
→ Then open http://localhost:9090

## Security Note

- Keep your Consumer Secret private
- OAuth tokens are only stored temporarily in your browser session