/*
  # Add Tracking Number to Custom Rugs

  1. Changes
    - Add `tracking_number` column to Custom Rugs table
    - Set up unique constraint to ensure no duplicate tracking numbers
    - Create function to auto-generate tracking numbers (format: 2TR-YYYYMMDD-XXXXX)
    - Create trigger to automatically assign tracking numbers on insert
    
  2. Security
    - No RLS changes needed - existing policies remain in effect
*/

-- Add tracking_number column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'tracking_number'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN tracking_number text UNIQUE;
  END IF;
END $$;

-- Create function to generate tracking number
CREATE OR REPLACE FUNCTION generate_tracking_number()
RETURNS text AS $$
DECLARE
  new_tracking_number text;
  date_part text;
  random_part text;
BEGIN
  -- Get current date in YYYYMMDD format
  date_part := to_char(NOW(), 'YYYYMMDD');
  
  -- Generate random 5-digit number
  random_part := lpad(floor(random() * 100000)::text, 5, '0');
  
  -- Combine into tracking number format: 2TR-YYYYMMDD-XXXXX
  new_tracking_number := '2TR-' || date_part || '-' || random_part;
  
  -- Check if it already exists (rare collision case)
  WHILE EXISTS (SELECT 1 FROM "Custom Rugs" WHERE tracking_number = new_tracking_number) LOOP
    random_part := lpad(floor(random() * 100000)::text, 5, '0');
    new_tracking_number := '2TR-' || date_part || '-' || random_part;
  END LOOP;
  
  RETURN new_tracking_number;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to auto-assign tracking number
CREATE OR REPLACE FUNCTION assign_tracking_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tracking_number IS NULL THEN
    NEW.tracking_number := generate_tracking_number();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS assign_tracking_number_trigger ON "Custom Rugs";
CREATE TRIGGER assign_tracking_number_trigger
  BEFORE INSERT ON "Custom Rugs"
  FOR EACH ROW
  EXECUTE FUNCTION assign_tracking_number();

-- Update existing records with tracking numbers
UPDATE "Custom Rugs" 
SET tracking_number = generate_tracking_number()
WHERE tracking_number IS NULL;