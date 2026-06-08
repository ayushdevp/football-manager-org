# Free Agent Pool System Documentation

## Overview

The Free Agent Pool System provides a dynamic, self-replenishing marketplace of system-generated players that ensures your football manager game is instantly playable and economically healthy from Day 1. It prevents a stagnant economy by continuously introducing new players based on active user growth.

---

## 1. Free Agent Pool Scaling

### Formula
```
Target Free Agent Pool = Active Users × Squad Size Factor (5-7)
```

### Examples
- **500 active users** = 2,500–3,500 free agents
- **1,000 active users** = 5,000–7,000 free agents  
- **10,000 active users** = 50,000–70,000 free agents

### Dynamic Adjustment
The pool size scales automatically with your user base. As more players join:
- More free agents are available
- Market remains competitive
- New players always have signing options
- No bottlenecks or scarcity issues

---

## 2. Automatic Pool Replenishment (Hourly Cron)

### Cron Job: `/api/cron/maintain-free-agents`
Runs **every hour** to maintain the target pool size.

### Process
1. **Query** current active user count
2. **Calculate** target pool size using formula
3. **Check** current available free agents
4. **Generate** only players needed to reach target
5. **Remove** expired unsigned players (48+ hours old)
6. **Log** metrics for monitoring

### Key Feature: Never Over-Generate
- If pool is at target: **0 players generated**
- If 500 players below target: **exactly 500 players generated**
- If 2,000 expired: **remove all 2,000 and regenerate if needed**

### Example Cron Output
```
[CRON] Free Agent Pool Maintenance - 2025-01-15T14:00:00Z
  Active Users: 500
  Target Pool: 3,000
  Current Pool: 2,800
  Replenishment Needed: 200
  Generated: 200
  Expired & Removed: 45
  New Pool Size: 2,955
```

---

## 3. Rating Distribution Structure

All generated free agents follow a **strict 3-tier distribution model**.

### Tier Breakdown

| Tier | Percentage | Rating Range | Avatar Slots | Purpose |
|------|-----------|--------------|-------------|---------|
| **Low** | 25% | 50–64 | 01–03 | Squad depth, backups, budget signings |
| **Middle** | 65% | 65–78 | 04–07 | Reliable starters (primary source) |
| **Elite** | 10% | 79–90+ | 08–10 | Premium, highly desirable signings |

### Distribution Logic
- **Low Tier (25%)**: Basic players for squad depth
  - Rating 50–64
  - Avatar slots 1, 2, 3
  - Lower contract costs
  - Example: 625 players from 2,500-player pool

- **Middle Tier (65%)**: The backbone of the market
  - Rating 65–78
  - Avatar slots 4, 5, 6, 7
  - Most competitive section
  - New players build squads primarily from this tier
  - Example: 1,625 players from 2,500-player pool

- **Elite Tier (10%)**: Ultra-rare signings
  - Rating 79–90+
  - Avatar slots 8, 9, 10
  - Listed via sealed bid auctions (not fixed price)
  - Creates competition and engagement
  - Example: 250 players from 2,500-player pool

### Avatar Assignment
Each player is randomly assigned an avatar slot within their tier:
- Low tier players: randomly assigned slots 1, 2, or 3
- Middle tier players: randomly assigned slots 4, 5, 6, or 7
- Elite tier players: randomly assigned slots 8, 9, or 10

---

## 4. Signing Mechanisms

### System A: Fixed Price Instant Sign

**For:** Low and Middle tier free agents (90% of pool)

**User Flow:**
1. User browsing free agents sees player profile
2. System displays **fixed market value** (auto-calculated)
3. User clicks "Buy Now"
4. Required cash instantly deducted from club budget
5. Player joins squad immediately
6. Avatar assignment applied
7. Transaction complete

**Value Calculation:**
```
Fixed Transfer Value = 
  (Rating × 1M) +
  (Potential Upside × 500K) +
  (Age Multiplier)

Age Multipliers:
- Under 25: ×1.2 (young prospect premium)
- 25-29: ×1.0 (prime years)
- 30+: ×0.8 (veteran discount)

Rounded to nearest 100K for clean numbers
```

**Example:**
- Player: 68 Rating, 82 Potential, 23 years old
- Base: 68M × 1M = 68M
- Potential: (82-68) × 500K = 7M
- Age: 23 < 25, ×1.2 = 1.2 multiplier
- Total: (68M + 7M) × 1.2 = 90M → **90,000,000**

**Instant Gratification:** Players sign immediately, no waiting.

---

### System B: System-Hosted Sealed Bid Auction

**For:** Elite tier free agents (10% of pool, 79+ rating)

**Purpose:**
- Prevent wealthy managers from instantly buying all elite players
- Increase competition and engagement
- Create uncertainty and market discussion

**Auction Flow:**
1. System lists elite player
2. Countdown timer displayed (24 hours)
3. Users submit **secret bids**
4. **Bids are NOT visible** to other managers
5. **No bid history** shown during auction
6. **No public highest bid** displayed

**Auction Resolution:**
1. Countdown reaches zero
2. System evaluates all submitted bids
3. **Highest bid wins**
4. Winner receives player
5. Funds deducted from winner's budget
6. All other bids have **escrow funds released**
7. Auction closes and player is removed from market

**Example:**
```
Elite Player: Erling Haaland (89 Rating)
Listing Type: Sealed Bid Auction
Duration: 24 hours
Minimum Bid: $75M

Manager 1 bids: $85M (secret)
Manager 2 bids: $92M (secret)
Manager 3 bids: $88M (secret)

At countdown zero:
  Winner: Manager 2 ($92M)
  Player joins Manager 2's club
  $92M deducted from budget
  Managers 1 & 3 get escrow refunded
```

**Benefits:**
- No wealthy manager domination
- Excitement and competition for rare players
- Fresh auctions every time cron runs
- Prevents market stagnation for elite talent

---

## 5. Market Rotation and Cleanup

### 48-Hour Expiry System

Every system-generated free agent has:
- `created_at`: When player was generated
- `expires_at`: Exactly 48 hours after creation

### Automatic Cleanup Rules

**If player remains unsigned for 48+ hours:**
1. Automatically remove player from database
2. Remove all associated listings
3. Cancel any active auction bids
4. Release all held escrow
5. Player ceases to exist

**Purpose:**
- ✅ Market stays fresh with new opportunities
- ✅ No stale listings or old players
- ✅ Database stays lean and performant
- ✅ Encourages timely decision-making
- ✅ Ensures continuous player rotation

### Example Timeline
```
12:00 PM - System generates 200 new free agents
          - expires_at set to tomorrow 12:00 PM

2:00 PM  - Managers sign 150 of them
          - 50 remain unsigned

10:00 PM - Managers sign 30 more
          - 20 remain unsigned

11:59 PM - 20 unsigned players still available

12:00 PM NEXT DAY - Cron runs:
  - Expires and removes 20 unsigned players
  - Generates 200 NEW free agents to meet target
  - Market refreshed with fresh talent
```

---

## 6. Database Performance Objective

### Keep Market Clean and Efficient

**Rule 1: Only maintain target pool**
- If target is 3,000 players
- Only 3,000 active free agents exist (±new generation buffer)
- No database bloat

**Rule 2: Automatic expiry deletion**
- Signed players move to club roster (separate table)
- Unsigned players deleted after 48 hours
- Zero orphaned records

**Rule 3: Efficient queries**
- Indexes on: `expires_at`, `tier`, `is_signed`, `position`
- Views for common queries (e.g., `expired_unsigned_free_agents`)
- Partitioning by `created_at` for archive management

**Expected Performance:**
- Pool queries: <100ms
- Generate 500 players: <5 seconds
- Expire 1,000 players: <3 seconds
- Transfer player to club: <500ms

---

## 7. Integration with Existing System

### Uses Existing Player Generation
- `generatePlayerName()`: Respects nationality (43+ nations)
- `generateCompleteOutfieldStats()`: Proper stat generation
- `generateCompleteGoalkeeperStats()`: GK-specific logic
- `calculateCompleteFinancials()`: Wage calculations
- `NATIONALITY_DATABASE`: India regions + 42 other nations

### No Duplication of Logic
- Free agent generator imports from player generation library
- Single source of truth for names, stats, financials
- Consistent player quality across system

---

## 8. File Structure

```
lib/transfer-market/
├── free-agent-types.ts          (Type definitions)
├── free-agent-generator.ts      (Generation logic)
├── free-agent-schema.sql        (Database schema)

app/api/
├── cron/
│   └── maintain-free-agents/route.ts    (Hourly maintenance)
├── free-agents/
│   ├── sign/route.ts                    (System A: Fixed price)
│   └── auction/
│       └── place-sealed-bid/route.ts    (System B: Sealed auction)
```

---

## 9. Configuration & Deployment

### Environment Variables
```env
# Cron job secret
CRON_SECRET=your-secret-here

# Active user count (can be dynamic from analytics)
ACTIVE_USER_COUNT=500

# Squad size factor (5-7)
SQUAD_SIZE_FACTOR=6
```

### Vercel Cron Configuration
```json
{
  "crons": [
    {
      "path": "/api/cron/maintain-free-agents",
      "schedule": "0 * * * *"  // Every hour
    }
  ]
}
```

### Database Setup
1. Run SQL schema in `free-agent-schema.sql`
2. Create indexes and views
3. Verify `free_agents` table exists

---

## 10. Monitoring & Metrics

### Key Metrics to Track
- **Active Pool Size**: Should stay near target
- **Generation Rate**: Should match expiry rate at equilibrium
- **Tier Distribution**: Verify 25/65/10 split
- **Signing Rate**: Indicates market health
- **Avg Time to Sign**: How long before expiry

### Alerts to Set
- ⚠️ Pool size drops below 80% of target
- ⚠️ Generation takes >10 seconds
- ⚠️ Expiry deletion takes >5 seconds
- ⚠️ More than 1,000 players expire unsigned in one hour
- ⚠️ Zero elite tier players available

---

## 11. Example: 500-User Launch Day

### Scenario
- 500 active users join your game
- Squad size: 11 players per club
- Squad factor: 6 (5-7 range)

### Calculation
```
Target Pool = 500 users × 6 = 3,000 free agents
Low Tier (25%) = 750 players (50-64 rating)
Middle Tier (65%) = 1,950 players (65-78 rating)
Elite Tier (10%) = 300 players (79-90+ rating)
```

### Launch Timeline
- **T+0 Hours**: Cron runs, generates 3,000 free agents
- **T+1 Hour**: Managers signing players, pool at ~2,700
- **T+2 Hours**: More signings, pool at ~2,400
- **T+2:30 Hours**: Pool below target, cron has access to new generators
- **T+3 Hours**: Cron runs, generates ~600 new players
- **T+24 Hours**: First batch of 48-hour players expire, replacements generated
- **Ongoing**: Pool stays between 2,800–3,200, fresh players always available

---

## 12. Future Enhancements

- **Youth Academy Integration**: Generate prospects from academies
- **Injury/Recovery**: Temporarily remove injured free agents
- **Market Trends**: Price adjustments based on signing patterns
- **Regional Preference**: More players from popular nations
- **Seasonal Events**: Special free agent pools for tournaments
- **Player Stats Decay**: Older players gradually decline in rating

---

## Summary

The Free Agent Pool System transforms your Transfer Market into a **dynamic, self-sustaining ecosystem** where:
✅ Market never gets stale
✅ New players always available
✅ Economy scales with growth
✅ No database bloat
✅ Instant gratification (System A) + competition (System B)
✅ Fresh opportunities every 48 hours
✅ Built on existing player generation logic
