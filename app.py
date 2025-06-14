from flask import Flask, render_template, request, redirect, session, jsonify, flash
import requests
import secrets
import urllib.parse
import os
from requests_oauthlib import OAuth1Session

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', secrets.token_hex(16))

# Tumblr OAuth endpoints
REQUEST_TOKEN_URL = 'https://www.tumblr.com/oauth/request_token'
AUTHORIZE_URL = 'https://www.tumblr.com/oauth/authorize'
ACCESS_TOKEN_URL = 'https://www.tumblr.com/oauth/access_token'
BASE_URL = 'https://api.tumblr.com/v2/'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/oauth/start', methods=['POST'])
def start_oauth():
    consumer_key = request.form.get('consumer_key')
    consumer_secret = request.form.get('consumer_secret')
    
    if not consumer_key or not consumer_secret:
        flash('Both Consumer Key and Consumer Secret are required', 'error')
        return redirect('/')
    
    # Store credentials in session
    session['consumer_key'] = consumer_key
    session['consumer_secret'] = consumer_secret
    
    try:
        # Step 1: Get request token
        callback_uri = request.url_root.rstrip('/') + '/oauth/callback'
        oauth = OAuth1Session(consumer_key, client_secret=consumer_secret, callback_uri=callback_uri)
        
        fetch_response = oauth.fetch_request_token(REQUEST_TOKEN_URL)
        session['oauth_token'] = fetch_response.get('oauth_token')
        session['oauth_token_secret'] = fetch_response.get('oauth_token_secret')
        
        # Step 2: Redirect to authorization URL
        authorization_url = oauth.authorization_url(AUTHORIZE_URL)
        return redirect(authorization_url)
        
    except Exception as e:
        flash(f'OAuth Error: {str(e)}', 'error')
        return redirect('/')

@app.route('/oauth/callback')
def oauth_callback():
    oauth_token = request.args.get('oauth_token')
    oauth_verifier = request.args.get('oauth_verifier')
    
    if not oauth_verifier:
        flash('OAuth verification failed', 'error')
        return redirect('/')
    
    try:
        # Step 3: Get access token
        oauth = OAuth1Session(
            session['consumer_key'],
            client_secret=session['consumer_secret'],
            resource_owner_key=session['oauth_token'],
            resource_owner_secret=session['oauth_token_secret'],
            verifier=oauth_verifier
        )
        
        oauth_tokens = oauth.fetch_access_token(ACCESS_TOKEN_URL)
        
        session['access_token'] = oauth_tokens.get('oauth_token')
        session['access_token_secret'] = oauth_tokens.get('oauth_token_secret')
        
        # Get user info
        user_info = get_user_info()
        session['user_info'] = user_info
        
        return redirect('/dashboard')
        
    except Exception as e:
        flash(f'Token exchange error: {str(e)}', 'error')
        return redirect('/')

@app.route('/dashboard')
def dashboard():
    if 'access_token' not in session:
        flash('Please authorize first', 'error')
        return redirect('/')
    
    user_info = session.get('user_info', {})
    return render_template('dashboard.html', user_info=user_info)

def get_user_info():
    try:
        oauth = OAuth1Session(
            session['consumer_key'],
            client_secret=session['consumer_secret'],
            resource_owner_key=session['access_token'],
            resource_owner_secret=session['access_token_secret']
        )
        
        response = oauth.get(BASE_URL + 'user/info')
        data = response.json()
        
        if response.status_code == 200:
            return data['response']['user']
        else:
            return {'error': 'Failed to fetch user info'}
            
    except Exception as e:
        return {'error': str(e)}

@app.route('/logout')
def logout():
    session.clear()
    flash('Logged out successfully', 'success')
    return redirect('/')

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 Tumblr OAuth Token Generator")
    print("=" * 60)
    print("✅ Server starting...")
    print("🌐 Access the app at: http://localhost:5000")
    print("📝 Need help? Check: https://github.com/jtenniswood/tumblr-oauth")
    print("=" * 60)
    
    # Use debug mode only in development
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=5000, debug=debug_mode) 