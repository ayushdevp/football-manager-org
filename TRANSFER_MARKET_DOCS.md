# Transfer Market System Documentation

## Overview

The Transfer Market system is a comprehensive player trading ecosystem for the Football Manager app. It includes:

- **Public Auction House** - Real-time bidding on players
- **My Listings** - Manage your player sales
- **Bidding Watchlist** - Track bids and winning status
- **Direct Offers** - Private negotiations between clubs
- **Loan Deals** - Temporary player transfers with options
- **Counter-Offers** - Multi-round negotiation system
- **Sell-On Clauses** - Earn future transfer percentages
- **Anti-Cheat Economics** - Transfer tax, squad caps, price floors/ceilings
- **Escrow System** - Secure financial transactions
- **Automatic Expiry Handling** - Vercel Cron Jobs for task automation

---

## 1. Public Auction House

### Features

- **Real-Time Bidding**: Live auction for players with countdown timer
- **Flexible Duration**: 2, 4, 12, or 24-hour auctions
- **Buy Now Option**: Optional fixed price to bypass bidding
- **Player Locked**: Player cannot be used in matches or listed twice while auctioned

### Player Card Display

```
┌─────────────────────────────┐
│ Kylian Mbappé              │
│ From: PSG                    │
├─────────────────────────────┤
│ Position: ST | Age: 25      │
│ Rating: 95 | Wage: $450K/wk │
├─────────────────────────────┤
│ Current Bid: $145M          │
│ Leading: Manchester City    │
│ Time Left: 45m              │
├─────────────────────────────┤
│ [Place Bid] [Buy Now $180M] │
└─────────────────────────────┘
```

### Auction Flow

1. **List Player** → Starting Bid, Optional Buy Now, Expiry Time
2. **Bids Placed** → Escrow deducted immediately
3. **Highest Bidder** → Can be outbid within time remaining
4. **Auction Expires** → Highest bidder wins, transfer completed
5. **Transfer Tax Applied** → 5-10% deducted from sale price
6. **Money Distributed** → Seller receives net amount, tax to system

### API Endpoints

```
POST /api/transfers/listings/create
{
  playerId: string
  startingBid: number
  buyNowPrice?: number
  expiryHours: 2 | 4 | 12 | 24
  sellerClub: string
}

POST /api/transfers/auction/place-bid
{
  listingId: string
  bidAmount: number
  clubName: string
}

POST /api/transfers/auction/buy-now
{
  listingId: string
  buyerClub: string
}
```

---

## 2. My Listings Tab

### Shows All Active Listings

- Current highest bid
- Bidder club name
- Time remaining countdown
- Listing status (ACTIVE, EXPIRED, SOLD)

### Expired Listings

- If listing expires with 0 bids → "Reclaim Player" button appears
- Player returns to your squad unlocked
- No penalty for failed auction

---

## 3. Bidding Watchlist

### Status Indicators

- **🟢 WINNING** (Green): You have highest bid
  - Current bid and your bid displayed
  - Time remaining updated in real-time
  
- **🔴 OUTBID** (Red): Another club placed higher bid
  - Automatic refund notification
  - Option to place new higher bid
  - Escrow amount shown

---

## 4. Direct Offers System

### Player Availability Statuses

```
NOT_FOR_SALE     → No offers accepted
OPEN_TO_OFFERS   → Direct offers accepted
LISTED_FOR_AUCTION → Public auction ongoing
```

### Offer Card Details

```
From Manager: Carlo Ancelotti
From Club: Real Madrid
Time Received: 2 hours ago

Player: Vinícius Júnior (LW, Age 23, Rating 92)
Squad Role: Starting XI
Contract: Until 2026-06-30

Cash Offer: $110M
Sell-On Clause: 15%
Offer Expires In: 18h 45m

[Accept] [Counter] [Reject] [Block Manager]
```

### Auto-Blocking

- Reject offers repeatedly → Option to "Block Manager"
- Block expires after 1 season
- Blocked manager cannot make offers to your club

### Rules

1. **Public Market Blocks Direct Offers**: If player is on auction → "Place bid instead" message
2. **Minimum Target Value**: If set, auto-reject offers below target
3. **24-Hour Expiry**: Offer automatically expires, escrow refunded

---

## 5. Counter-Offer Loop

### Maximum 2 Counter Rounds

**Example Flow:**
```
Round 1: User A offers $1M
         ↓
Round 2: User B counters $1.5M
         ↓
Round 3: User A accepts $1.5M or walks away
```

- Each counter resets the 24-hour timer
- After 2 total counters, must accept/reject (no further counters)
- Escrow amounts adjust with each counter

---

## 6. Sell-On Clause

### Implementation

1. **Seller Sets Percentage** (5-25%) when accepting offer
2. **Recorded in System** → TransferHistory tracks clause
3. **Future Sale Triggers Fee** → When that player is sold again:
   - Original seller receives `percentage × selling_price`
   - Automatic calculation and fund transfer
   - Both clubs notified

### Example

```
2024-06-15: You sell Mbappé to Man City for $150M
            → Set 15% sell-on clause

2025-08-20: Man City sells Mbappé to Real Madrid for $180M
            → You automatically receive: $27M (15% of $180M)
```

---

## 7. Loan With Option To Buy

### Loan Parameters

- **Loan Fee**: One-time payment upfront
- **Loan Duration**: In weeks (e.g., 13 weeks = half-season)
- **Weekly Wage Contribution**: Borrowing club pays % of player's wage
- **Option to Buy Price**: Future purchase price (optional)

### Loan Flow

1. **Create Loan Deal** → Deduct loan fee from borrower
2. **Player Transferred** → To borrower's squad temporarily
3. **Weekly Payments** → Wage contributions deducted each week
4. **At Expiry**:
   - If option set → Borrower can buy at agreed price
   - If option not set → Player returns to lender
   - If not exercised → Player returns to lender

### API

```
POST /api/transfers/loans/create
{
  playerId: string
  loanDuration: number (weeks)
  loanFee: number
  optionToBuyPrice?: number
  weeklyWageContribution: number
  borrowerClub: string
  lenderClub: string
}
```

---

## 8. Anti-Cheat & Economy Balance

### Transfer Tax (5-10%)

```javascript
< $50M   → 5% tax
$50-100M → 6.5% tax
$100-200M → 8% tax
> $200M  → 10% tax
```

### Price Floors & Ceilings

Based on:
- Player rating (2M per point base)
- Player age (peak 25-32 years)
- Contract length remaining
- Weekly wage

```javascript
floorPrice = (rating * 2M) * ageMultiplier * contractMultiplier * 0.85
ceilingPrice = (rating * 2M) * ageMultiplier * contractMultiplier * 1.35
```

### Squad Caps

- **Maximum**: 25 senior players
- **Cannot add** if squad full (must sell first)
- **Minimum to sell**: 11 players (cannot drop below minimum)

### Escrow System

1. **Bid Placed** → Full bid amount deducted immediately
2. **Bid Outbid** → Full amount refunded to account
3. **Auction Expires** → Full amount refunded if not winner
4. **Direct Offer** → Full offer amount deducted until accepted/rejected
5. **Offer Rejected** → Full amount refunded

---

## 9. Database Schema

### Key Tables

```sql
-- Active listings
TransferListing {
  id, playerId, sellerId, playerName, startingBid,
  currentBid, highestBidderId, buyNowPrice, expiresAt,
  status: ACTIVE|EXPIRED|COMPLETED|CANCELLED
}

-- All bids placed
TransferBid {
  id, listingId, bidderId, bidderClub, amount, placedAt, isHighest
}

-- Direct offers between clubs
TransferOffer {
  id, playerId, sellerId, buyerId, cashOffer, sellOnClause,
  expiresAt, status: PENDING|ACCEPTED|REJECTED|COUNTERED|EXPIRED,
  counterRound: 0|1|2
}

-- Completed transfers
TransferHistory {
  id, playerId, fromClub, toClub, transferType: AUCTION|OFFER|LOAN,
  transferPrice, transferTax, sellOnPercentage, completedAt
}

-- Loan deals
LoanDeal {
  id, playerId, lenderClub, borrowerClub, loanFee, loanDuration,
  optionToBuyPrice, weeklyWageContribution, startDate, returnDate,
  status: ACTIVE|COMPLETED|CANCELLED
}

-- Sell-on clauses tracking
SellOnClause {
  id, originalTransferId, percentage, playerName,
  originalSellerClub, playerCurrentClub, earned
}

-- Blocked managers
BlockedManagerOffer {
  id, blockerId, blockedManagerId, createdAt, expiresAt
}

-- Club escrow balances
TransferEscrow {
  clubId, totalEscrow, transactions: [{type, amount, status}]
}
```

---

## 10. Vercel Cron Job: Resolve Transfers

### Endpoint

```
GET /api/cron/resolve-transfers
Authorization: Bearer {CRON_SECRET}
Runs: Every 1-5 minutes
```

### Responsibilities

1. **Find Expired Auctions**
   - Query: `WHERE status = ACTIVE AND expiresAt <= NOW()`
   
2. **Determine Winners**
   - Highest bidder = winner
   - Transfer completed, money distributed
   
3. **Complete Transfers**
   - Deduct tax from sale price
   - Send money to seller
   - Transfer player to buyer
   - Mark listing as COMPLETED
   
4. **Refund Non-Winners**
   - All bids except winner → full refund
   - Escrow returned to bidders
   
5. **Expire Direct Offers**
   - Query: `WHERE status = PENDING AND expiresAt <= NOW()`
   - Refund escrow to bidder
   - Mark as EXPIRED
   
6. **Process Loan Expirations**
   - Query: `WHERE status = ACTIVE AND returnDate <= NOW()`
   - Return player to lender
   - If option not exercised, mark COMPLETED

### Response

```json
{
  "success": true,
  "timestamp": "2024-06-07T14:30:00Z",
  "processed": {
    "expiredAuctions": 5,
    "completedTransfers": 5,
    "refundedBids": 23,
    "expiredOffers": 3
  }
}
```

---

## 11. Youth Academy Transfer Protection

### Youth Academy Improvements

#### New Actions Column

```
[Promote to First Team] [Offer Pro Contract] [Release]
```

#### New Badges

- **Youth** - U18/U19 development player
- **Signed** - Pro contract signed
- **Vulnerable** - Contract expiring soon

#### Poaching Warning

If youth contract < 6 months to expiry:
```
⚠️ WARNING: This player is vulnerable to poaching!
Rival clubs may sign him on a free transfer soon.
Action: Offer pro contract to secure player
```

#### Clear Separation

- **Youth Academy** = Unsigned players < 19, growing in background
- **Youth Development** = Signed young players in reserves/B-team/loaned out

---

## Utilities & Helper Functions

Located in `/lib/transfer-market/utils.ts`:

```typescript
// Calculate transfer tax based on price
calculateTax(price: number): number

// Get floor and ceiling price for player
calculatePriceRange(rating, age, wage, contractYears): PriceFloorCeiling

// Check if player can be added (squad cap)
canAddPlayer(currentCount, maxCount): boolean

// Validate auction expiry times
isValidAuctionExpiry(hours): boolean

// Get time remaining as readable string
getTimeRemaining(expiresAt): string

// Check if offer is expired (24 hours)
isOfferExpired(createdAt): boolean

// Validate counter-offer is allowed
canMakeCounterOffer(counterRound): boolean

// Flag suspicious bidding patterns
flagSuspiciousBidding(clubId, bidsInLastHour, bidJumps): boolean
```

---

## Integration Checklist

- [x] Transfer Market page with 4 tabs (Auction, My Listings, Watchlist, Offers)
- [x] Glassmorphic UI with blurred background (matches existing design)
- [x] Cyan/blue color scheme and emoji headers
- [x] API endpoints for auctions, bids, offers, loans, cron jobs
- [x] Type definitions for all transfer objects
- [x] Utility functions for calculations and validation
- [x] Cron job for expiry handling (ready for Vercel)
- [ ] Database schema implementation (requires Supabase/DB setup)
- [ ] Real backend integration (currently mock data)
- [ ] Youth Academy UI improvements
- [ ] Real-time notifications (WebSocket or polling)
- [ ] Transfer history page
- [ ] Club finances impact (escrow, transfer tax tracking)

---

## Environment Variables Required

```env
CRON_SECRET=your-secure-cron-secret
DATABASE_URL=your-database-url
```

---

## Next Steps for Full Implementation

1. **Database**: Create PostgreSQL schema in Supabase
2. **API Integration**: Connect all endpoints to database
3. **Real-Time Updates**: Add WebSocket or Server-Sent Events
4. **Notifications**: Email/in-app alerts for offers and auctions
5. **Transfer History**: Create historical record viewer
6. **Youth Academy**: Implement player protection features
7. **Testing**: Unit tests for calculations and anti-fraud
8. **Deployment**: Configure Vercel Cron schedule (1-5 min intervals)

---

## File Structure

```
/app/transfer/
  page.tsx (main Transfer Market UI - 662 lines)

/app/api/
  /cron/
    resolve-transfers/route.ts
  /transfers/
    /auction/
      place-bid/route.ts
      buy-now/route.ts
    /offers/
      make-offer/route.ts
      counter-offer/route.ts
    /listings/
      create/route.ts
    /loans/
      create/route.ts

/lib/transfer-market/
  types.ts (TypeScript interfaces)
  utils.ts (Helper functions and calculations)
```

---

## Design System Consistency

✅ Matches existing app design:
- Glassmorphic cards with backdrop blur
- Blurred background image (dashboard-bg-blur.jpg)
- Cyan, blue, green, purple, red accent colors
- Strong text shadows for readability
- Emoji-enhanced headers
- Responsive grid layouts
- Hover effects and smooth transitions

---

Generated: June 7, 2024
Transfer Market System v1.0
