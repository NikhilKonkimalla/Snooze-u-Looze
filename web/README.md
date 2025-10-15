# Snooze u Looze - Web Components

This folder contains web-based components for the Snooze u Looze iOS app.

## Files

### `password-reset.html`
A beautiful, responsive web page that handles password reset redirects from Supabase email notifications.

### `confirm-signup.html`
Handles email confirmation for new user signups with automatic app redirect.

### `magic-link.html`
Processes magic link authentication with seamless app integration.

### `invite-user.html`
Manages user invitation acceptance with professional UI and app redirect.

### `change-email.html`
Handles email address change confirmations with secure token processing.

### `reauthentication.html`
Processes security reauthentication requests with identity verification.

**Features (All Pages):**
- 🎨 **Dark theme** matching the iOS app design
- 📱 **Mobile-responsive** design
- 🔄 **Auto-redirect** to iOS app with appropriate tokens
- ⚡ **Fallback handling** if app isn't installed
- 🎯 **Professional UI** with loading states and status messages
- 🔐 **Secure token handling** for all authentication flows
- ✨ **Smooth animations** and transitions
- 📧 **Email-specific messaging** for each auth flow

**Usage:**
1. Host this file on GitHub Pages, Netlify, or any web server
2. Update Supabase email templates to use this URL
3. Users clicking reset links will be redirected to the iOS app

## Deployment Options

### GitHub Pages (Free)
1. Push this folder to your GitHub repository
2. Enable GitHub Pages in repository settings
3. Your URL will be: `https://yourusername.github.io/snooze-u-looze/web/password-reset.html`

### Netlify (Free)
1. Drag and drop this folder to Netlify
2. Get instant deployment with custom domain support
3. Automatic HTTPS and CDN distribution

### Vercel (Free)
1. Connect your GitHub repository to Vercel
2. Deploy automatically on every push
3. Get a custom domain and analytics

## Integration with Supabase

Update your Supabase email templates to use these pages:

### Password Reset
```html
<a href="https://yourdomain.com/web/password-reset.html?token={{ .Token }}&type={{ .TokenType }}">
    Reset Password
</a>
```

### Confirm Signup
```html
<a href="https://yourdomain.com/web/confirm-signup.html?token={{ .Token }}&type={{ .TokenType }}">
    Confirm Signup
</a>
```

### Magic Link
```html
<a href="https://yourdomain.com/web/magic-link.html?token={{ .Token }}&type={{ .TokenType }}">
    Sign In
</a>
```

### Invite User
```html
<a href="https://yourdomain.com/web/invite-user.html?token={{ .Token }}&type={{ .TokenType }}">
    Accept Invitation
</a>
```

### Change Email
```html
<a href="https://yourdomain.com/web/change-email.html?token={{ .Token }}&type={{ .TokenType }}">
    Confirm Email Change
</a>
```

### Reauthentication
```html
<a href="https://yourdomain.com/web/reauthentication.html?token={{ .Token }}&type={{ .TokenType }}">
    Verify Identity
</a>
```

The page will automatically:
- Extract the token from URL parameters
- Redirect to the iOS app with the token
- Handle fallbacks gracefully
