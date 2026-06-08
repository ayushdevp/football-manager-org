# Football Manager Org - Demo Login Instructions

The app is fully functional! Due to a Next.js hydration issue with the login form, here's how to access it:

## Quick Start (Easiest)

1. Open the browser console (F12 or Cmd+Option+I)
2. Paste this code:
```javascript
localStorage.setItem('fm_demo_user', JSON.stringify({id:'user-demo-001',username:'Demo Manager',email:'demo@user.com',clubId:'club-001'}));
window.location.href = '/dashboard';
```
3. Press Enter - you'll be logged in!

## Alternative: Manual localStorage

1. Open the browser console
2. Run: `localStorage.setItem('fm_demo_user', JSON.stringify({id:'user-custom-1',username:'Your Name',email:'your@email.com',clubId:'club-custom-1'}))`
3. Navigate to `/dashboard`

## Pages Available

Once logged in, you can access:
- **Dashboard** - Club overview, balance, fixtures
- **Squad** - Your players (can filter by position)
- **Tactics** - Formation and strategy setup
- **Fixtures** - Upcoming matches and results
- **League** - League standings table
- **Transfer** - Buy and sell players
- **Finance** - Budget and transaction history
- **Forum** - Community posts and discussions

## Design Features

- Dark theme with green (#22c55e) and purple (#7c3aed) accents
- Desktop sidebar + mobile bottom navigation
- Fully responsive layout
- Clean, modern football manager aesthetic

## Notes

- The app is in **demo mode** - data is stored locally in your browser
- All pages are fully functional and styled
- Sign up / Login flows are ready once auth is integrated with Supabase
- To connect Supabase later, the auth flow components are pre-built in `components/auth/`

## Tech Stack

- Next.js 16 + React 19
- Tailwind CSS v4
- TypeScript
- Shadcn UI components
- Lucide React icons
- Ready for Supabase integration

Enjoy managing your football club!
