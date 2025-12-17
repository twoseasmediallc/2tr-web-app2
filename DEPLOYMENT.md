# Netlify Deployment Instructions

## Option 1: Manual Deployment (Quickest)

1. Go to [Netlify Drop](https://app.netlify.com/drop)
2. Drag and drop the `dist` folder from this project
3. Your site will be live in seconds!

## Option 2: Netlify CLI Deployment

1. Install Netlify CLI globally:
   ```bash
   npm install -g netlify-cli
   ```

2. Login to Netlify:
   ```bash
   netlify login
   ```

3. Deploy the site:
   ```bash
   netlify deploy --prod --dir=dist
   ```

4. Follow the prompts to create a new site or link to an existing one

## Option 3: Connect via Git (Recommended for continuous deployment)

1. Push your code to GitHub, GitLab, or Bitbucket
2. Go to [Netlify](https://app.netlify.com)
3. Click "Add new site" → "Import an existing project"
4. Connect to your Git provider and select your repository
5. Netlify will automatically detect the build settings from `netlify.toml`
6. Add your environment variables in Netlify:
   - Go to Site settings → Environment variables
   - Add all variables from your `.env` file:
     - `VITE_SUPABASE_URL`
     - `VITE_SUPABASE_ANON_KEY`
7. Click "Deploy site"

## Important: Environment Variables

Make sure to add these environment variables in Netlify's dashboard:
- `VITE_SUPABASE_URL` - Your Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Your Supabase anonymous key

To add environment variables:
1. Go to your site in Netlify dashboard
2. Navigate to: Site settings → Environment variables
3. Click "Add a variable" and add each one
4. Redeploy your site for the changes to take effect

## Build Settings

The `netlify.toml` file is already configured with:
- Build command: `npm run build`
- Publish directory: `dist`
- SPA redirect rules (for React Router)

Your site will automatically handle client-side routing!
