/*
  # Add Backing Option to Custom Rugs

  1. Changes
    - Add `backing_option` column to store the customer's choice of backing finish
    - Options: "Non-Slip Floor Finish" or "Wall Hanging Finish"

  2. Notes
    - Column is required for new orders
    - Default value is empty string for backwards compatibility
*/

-- Add backing_option column to Custom Rugs table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'backing_option'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN backing_option text NOT NULL DEFAULT '';
  END IF;
END $$;

-- Add comment for backing_option column
COMMENT ON COLUMN "Custom Rugs".backing_option IS 'Backing finish option: Non-Slip Floor Finish or Wall Hanging Finish';
