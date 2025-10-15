# Snooze u Looze - Web Components

This folder contains web-based components for the Snooze u Looze iOS app.

## Files

### `password-reset.html`
A beautiful, responsive web page that handles password reset redirects from Supabase email notifications.

**Features:**
- 🎨 **Dark theme** matching the iOS app design
- 📱 **Mobile-responsive** design
- 🔄 **Auto-redirect** to iOS app with reset token
- ⚡ **Fallback handling** if app isn't installed
- 🎯 **Professional UI** with loading states and status messages

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

Update your Supabase email template to use this page:

```html
<a href="https://yourdomain.com/web/password-reset.html?token={{ .Token }}&type={{ .TokenType }}">
    Reset Password
</a>
```

The page will automatically:
- Extract the token from URL parameters
- Redirect to the iOS app with the token
- Handle fallbacks gracefully
