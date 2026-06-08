# Football Manager Org

A comprehensive web-based football management game built with Next.js, Tailwind CSS, and Supabase.

## Features

- **User Authentication**: Secure sign-up and login with Supabase Auth
- **Club Management**: Auto-generated clubs with 15 players on sign-up
- **Squad Management**: View all players with detailed stats (pace, shooting, passing, defense, physical)
- **Tactical Control**: Choose formations (4-3-3, 4-4-2, 3-5-2, etc.) and strategies (Attacking, Balanced, Defensive)
- **Fixtures Management**: View upcoming matches and past results
- **League Standings**: Check your position with goals for/against and form circles
- **Transfer Market**: Buy and sell players with filtering by position and price
- **Finance Dashboard**: Track balance, income, expenses, and transaction history
- **Community Forum**: Real-time discussion with Supabase subscriptions

## Tech Stack

- **Frontend**: Next.js 16, React 19, Tailwind CSS
- **Backend**: Supabase (PostgreSQL, Auth, Real-time)
- **UI Components**: Shadcn/ui, Lucide Icons
- **Styling**: Dark theme with green (#22c55e) and purple (#7c3aed) accents

## Setup Instructions

### 1. Environment Variables

Set these in your Vercel project settings or `.env.local`:

```
NEXT_PUBLIC_SUPABASE_URL=<your-supabase-url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-supabase-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
```

### 2. Database Setup

Run the SQL schema from `supabase/schema.sql` in your Supabase project's SQL Editor:

- Creates all necessary tables (users, clubs, players, fixtures, etc.)
- Sets up Row Level Security policies
- Enables real-time subscriptions for forum posts and replies

### 3. Install Dependencies

```bash
pnpm install
```

### 4. Run Development Server

```bash
pnpm dev
```

Visit `http://localhost:3000` to start the app.

## App Pages

| Route | Purpose |
|-------|---------|
| `/` | Landing page with features and CTA |
| `/signup` | Create new account |
| `/login` | Sign in to existing account |
| `/dashboard` | Club overview with key stats |
| `/squad` | View and manage players |
| `/tactics` | Set formation and strategy |
| `/fixtures` | Upcoming matches and results |
| `/league` | League standings table |
| `/transfer` | Transfer market for buying/selling |
| `/finance` | Financial tracking and history |
| `/forum` | Community discussion with real-time updates |

## Design System

### Colors

- **Background**: #0f0b11 (Dark)
- **Primary**: #22c55e (Green)
- **Secondary**: #7c3aed (Purple)
- **Card**: #1a1520 (Dark card background)
- **Border**: #2d2435 (Subtle borders)

### Responsive Design

- **Desktop**: Sidebar navigation (64 chars wide)
- **Mobile**: Bottom tab navigation with mobile menu
- All pages fully responsive

## Database Schema

### Core Tables

- `user_profiles` - User data linked to Supabase auth
- `clubs` - Team information and budget
- `players` - Squad members with stats
- `fixtures` - Upcoming and completed matches
- `league_standings` - League table data
- `tactics` - Formation and strategy settings
- `transfer_listings` - Players available for sale
- `transactions` - Financial history
- `forum_posts` - Discussion topics
- `forum_replies` - Post comments with real-time support

## Game Flow

1. **Sign Up**: User creates account → Club auto-generates with 15 random players
2. **Dashboard**: View club overview, next match, top players
3. **Squad**: Browse and manage your team
4. **Tactics**: Choose formation and strategy
5. **League**: Check standings and position
6. **Transfer Market**: Buy/sell players to balance team
7. **Forum**: Connect with other managers

## Features to Enhance

- Match simulation and results generation
- Player skill progression and aging
- Youth academy
- Sponsor deals and bonuses
- Cup competitions
- Admin panel for fixture scheduling
- Match day live commentary
- API for external tools

## Deployment

Deploy to Vercel with:

```bash
vercel deploy
```

Make sure to set environment variables in Vercel project settings.

## License

This project is open source and available for educational purposes.
