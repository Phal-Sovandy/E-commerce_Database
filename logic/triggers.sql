
-- ****************************************************************************
-- ***************************** TRIGGERS *************************************
-- ****************************************************************************

-- =(7)========================================================================
-- ======================= Track Actions Timestamp ============================
-- ============================================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_products
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_sellers
BEFORE UPDATE ON sellers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_pricing_timestamp
BEFORE UPDATE ON pricing
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_rankings_timestamp
BEFORE UPDATE ON rankings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_customers_timestamp
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
