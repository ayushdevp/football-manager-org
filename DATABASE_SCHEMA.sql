-- Transfer Market Database Schema
-- For Supabase PostgreSQL or any PostgreSQL-compatible database
-- Use this as reference when implementing database integration

-- 1. Transfer Listings (Auctions)
CREATE TABLE transfer_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL,
  seller_id UUID NOT NULL,
  seller_club VARCHAR(100) NOT NULL,
  player_name VARCHAR(255) NOT NULL,
  player_position VARCHAR(5) NOT NULL,
  player_age INTEGER NOT NULL,
  player_rating INTEGER NOT NULL,
  player_value VARCHAR(20),
  wage VARCHAR(20),
  starting_bid BIGINT NOT NULL,
  current_bid BIGINT NOT NULL,
  highest_bidder_id UUID,
  highest_bidder_club VARCHAR(100),
  buy_now_price BIGINT,
  expires_at TIMESTAMP NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, EXPIRED, COMPLETED, CANCELLED
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  INDEX idx_expires_at (expires_at),
  INDEX idx_status (status),
  INDEX idx_seller_id (seller_id)
);

-- 2. Transfer Bids
CREATE TABLE transfer_bids (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES transfer_listings(id),
  bidder_id UUID NOT NULL,
  bidder_club VARCHAR(100) NOT NULL,
  amount BIGINT NOT NULL,
  placed_at TIMESTAMP DEFAULT NOW(),
  is_highest BOOLEAN DEFAULT FALSE,
  INDEX idx_listing_id (listing_id),
  INDEX idx_bidder_id (bidder_id),
  INDEX idx_placed_at (placed_at)
);

-- 3. Transfer Offers (Direct Negotiations)
CREATE TABLE transfer_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL,
  player_name VARCHAR(255) NOT NULL,
  seller_id UUID NOT NULL,
  seller_club VARCHAR(100) NOT NULL,
  buyer_id UUID NOT NULL,
  buyer_club VARCHAR(100) NOT NULL,
  buyer_manager VARCHAR(100) NOT NULL,
  cash_offer BIGINT NOT NULL,
  sell_on_clause INTEGER, -- Percentage: 5-25
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, ACCEPTED, REJECTED, COUNTERED, EXPIRED
  counter_round INTEGER DEFAULT 0, -- 0, 1, or 2
  notes TEXT,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  responded_at TIMESTAMP,
  INDEX idx_player_id (player_id),
  INDEX idx_seller_id (seller_id),
  INDEX idx_buyer_id (buyer_id),
  INDEX idx_status (status),
  INDEX idx_expires_at (expires_at)
);

-- 4. Transfer History (Completed Transfers)
CREATE TABLE transfer_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL,
  player_name VARCHAR(255) NOT NULL,
  from_club VARCHAR(100) NOT NULL,
  to_club VARCHAR(100) NOT NULL,
  transfer_type VARCHAR(20) NOT NULL, -- AUCTION, OFFER, LOAN
  transfer_price BIGINT NOT NULL,
  transfer_tax BIGINT NOT NULL,
  sell_on_percentage INTEGER,
  loan_duration INTEGER, -- weeks
  loan_fee BIGINT,
  option_to_buy_price BIGINT,
  completed_at TIMESTAMP DEFAULT NOW(),
  escrow_refunded BIGINT,
  INDEX idx_player_id (player_id),
  INDEX idx_from_club (from_club),
  INDEX idx_to_club (to_club),
  INDEX idx_completed_at (completed_at)
);

-- 5. Loan Deals
CREATE TABLE loan_deals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL,
  player_name VARCHAR(255) NOT NULL,
  lender_club VARCHAR(100) NOT NULL,
  borrower_club VARCHAR(100) NOT NULL,
  loan_fee BIGINT NOT NULL,
  loan_duration INTEGER NOT NULL, -- weeks
  option_to_buy_price BIGINT,
  weekly_wage_contribution BIGINT,
  start_date TIMESTAMP DEFAULT NOW(),
  return_date TIMESTAMP NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, COMPLETED, CANCELLED
  option_exercised BOOLEAN DEFAULT FALSE,
  INDEX idx_player_id (player_id),
  INDEX idx_return_date (return_date),
  INDEX idx_status (status)
);

-- 6. Sell-On Clauses
CREATE TABLE sell_on_clauses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  original_transfer_id UUID NOT NULL REFERENCES transfer_history(id),
  original_buyer_club VARCHAR(100) NOT NULL,
  original_seller_club VARCHAR(100) NOT NULL,
  percentage INTEGER NOT NULL, -- 5-25%
  player_name VARCHAR(255) NOT NULL,
  player_current_club VARCHAR(100),
  current_buyer VARCHAR(100),
  earned BIGINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_original_transfer_id (original_transfer_id),
  INDEX idx_original_seller_club (original_seller_club)
);

-- 7. Blocked Manager Offers
CREATE TABLE blocked_manager_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL,
  blocker_club VARCHAR(100) NOT NULL,
  blocked_manager_id UUID NOT NULL,
  blocked_manager_club VARCHAR(100) NOT NULL,
  player_name VARCHAR(255),
  reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP, -- Auto-expire after 1 season (~365 days)
  INDEX idx_blocker_id (blocker_id),
  INDEX idx_blocked_manager_id (blocked_manager_id),
  INDEX idx_expires_at (expires_at)
);

-- 8. Player Availability Status
CREATE TABLE player_availability_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL UNIQUE,
  status VARCHAR(30) NOT NULL DEFAULT 'NOT_FOR_SALE', -- NOT_FOR_SALE, OPEN_TO_OFFERS, LISTED_FOR_AUCTION
  minimum_target_value BIGINT,
  listed_price BIGINT,
  updated_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_player_id (player_id),
  INDEX idx_status (status)
);

-- 9. Transfer Escrow (Club Balances)
CREATE TABLE transfer_escrow (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID NOT NULL UNIQUE,
  club_name VARCHAR(100) NOT NULL,
  total_escrow BIGINT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_club_id (club_id)
);

-- 10. Escrow Transactions (Sub-records)
CREATE TABLE escrow_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  escrow_id UUID NOT NULL REFERENCES transfer_escrow(id),
  transaction_id VARCHAR(100) NOT NULL,
  transaction_type VARCHAR(20) NOT NULL, -- BID, OFFER, LOAN
  amount BIGINT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'LOCKED', -- LOCKED, COMPLETED, REFUNDED
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  INDEX idx_escrow_id (escrow_id),
  INDEX idx_transaction_id (transaction_id)
);

-- 11. Club Squad Capacity (Summary)
CREATE TABLE club_squad_info (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID NOT NULL UNIQUE,
  club_name VARCHAR(100) NOT NULL,
  senior_players_count INTEGER DEFAULT 0,
  max_senior_players INTEGER DEFAULT 25,
  youth_players_count INTEGER DEFAULT 0,
  last_updated TIMESTAMP DEFAULT NOW(),
  INDEX idx_club_id (club_id)
);

-- Useful Views

-- View: Active Auctions
CREATE VIEW active_auctions AS
SELECT 
  tl.id,
  tl.player_name,
  tl.player_position,
  tl.player_rating,
  tl.seller_club,
  tl.current_bid,
  tl.highest_bidder_club,
  tl.buy_now_price,
  tl.expires_at,
  EXTRACT(EPOCH FROM (tl.expires_at - NOW())) as seconds_remaining
FROM transfer_listings tl
WHERE tl.status = 'ACTIVE'
ORDER BY tl.expires_at ASC;

-- View: Player Market Value Estimates
CREATE VIEW player_market_values AS
SELECT 
  tl.player_id,
  tl.player_name,
  tl.player_rating,
  AVG(tb.amount) as avg_bid,
  MAX(tb.amount) as max_bid,
  MIN(tb.amount) as min_bid,
  COUNT(tb.id) as bid_count
FROM transfer_listings tl
LEFT JOIN transfer_bids tb ON tl.id = tb.listing_id
WHERE tl.status = 'COMPLETED'
GROUP BY tl.player_id, tl.player_name, tl.player_rating;

-- View: Club Transfer Activity
CREATE VIEW club_transfer_activity AS
SELECT 
  DATE(th.completed_at) as transfer_date,
  th.from_club,
  th.to_club,
  COUNT(*) as transfers_count,
  SUM(th.transfer_price) as total_spending,
  SUM(th.transfer_tax) as total_tax_paid
FROM transfer_history th
WHERE th.completed_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE(th.completed_at), th.from_club, th.to_club
ORDER BY transfer_date DESC;

-- Indexes for Performance

CREATE INDEX idx_transfers_created_at ON transfer_listings(created_at);
CREATE INDEX idx_offers_created_at ON transfer_offers(created_at);
CREATE INDEX idx_history_completed ON transfer_history(completed_at);
CREATE INDEX idx_loans_borrower ON loan_deals(borrower_club);
CREATE INDEX idx_loans_lender ON loan_deals(lender_club);

-- Stored Procedures (Optional but recommended)

-- SP: Complete Auction
CREATE OR REPLACE FUNCTION complete_auction(
  p_listing_id UUID,
  p_winner_id UUID,
  p_winner_club VARCHAR
)
RETURNS TABLE(
  success BOOLEAN,
  message VARCHAR,
  transfer_id UUID
) AS $$
DECLARE
  v_listing record;
  v_transfer_id UUID;
  v_tax BIGINT;
  v_seller_receives BIGINT;
BEGIN
  -- Get listing details
  SELECT * INTO v_listing FROM transfer_listings WHERE id = p_listing_id;
  
  -- Calculate 7.5% tax (average)
  v_tax := (v_listing.current_bid * 75 / 1000);
  v_seller_receives := v_listing.current_bid - v_tax;
  
  -- Record transfer
  INSERT INTO transfer_history (
    player_id, player_name, from_club, to_club,
    transfer_type, transfer_price, transfer_tax
  ) VALUES (
    v_listing.player_id, v_listing.player_name,
    v_listing.seller_club, p_winner_club,
    'AUCTION', v_listing.current_bid, v_tax
  ) RETURNING id INTO v_transfer_id;
  
  -- Update listing
  UPDATE transfer_listings 
  SET status = 'COMPLETED', completed_at = NOW()
  WHERE id = p_listing_id;
  
  RETURN QUERY SELECT true, 'Auction completed successfully'::VARCHAR, v_transfer_id;
END
$$ LANGUAGE plpgsql;

-- SP: Refund Bid
CREATE OR REPLACE FUNCTION refund_bid(
  p_escrow_id UUID,
  p_transaction_id VARCHAR,
  p_amount BIGINT
)
RETURNS TABLE(
  success BOOLEAN,
  message VARCHAR
) AS $$
BEGIN
  -- Update escrow
  UPDATE transfer_escrow 
  SET total_escrow = total_escrow - p_amount
  WHERE id = p_escrow_id;
  
  -- Update transaction
  UPDATE escrow_transactions
  SET status = 'REFUNDED', completed_at = NOW()
  WHERE transaction_id = p_transaction_id;
  
  RETURN QUERY SELECT true, 'Bid refunded successfully'::VARCHAR;
END
$$ LANGUAGE plpgsql;

-- Notes:
-- 1. All timestamps are UTC (use timezone-aware client code)
-- 2. All currency in smallest units (cents/pence)
-- 3. All IDs are UUIDs for security and distribution
-- 4. Indexes on frequently queried columns for performance
-- 5. Foreign keys not explicit but documented above
-- 6. Enable Row-Level Security (RLS) per club for data isolation
-- 7. Use triggers to auto-update updated_at timestamps
-- 8. Consider partitioning transfer_history by completed_at for very large tables

-- Example RLS Policies:
-- ALTER TABLE transfer_listings ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY transfer_listings_own
--   ON transfer_listings FOR ALL
--   USING (seller_id = auth.uid())
--   WITH CHECK (seller_id = auth.uid());

-- Example Triggers:
-- CREATE TRIGGER update_timestamp
--   BEFORE UPDATE ON transfer_listings
--   FOR EACH ROW
--   EXECUTE FUNCTION update_updated_at_column();
