/*
  # Add cut_option column to Custom Rugs table

  1. Changes
    - Add `cut_option` column to `Custom Rugs` table
      - Type: text
      - Description: Stores the customer's choice for how the rug should be cut (either "Cut to Dimension Border" or "Cut to Image Outline")
      - Not null constraint will be added for new orders
  
  2. Notes
    - Existing records will have NULL values initially
    - New orders will require this field to be populated
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'cut_option'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN cut_option text;
  END IF;
END $$;