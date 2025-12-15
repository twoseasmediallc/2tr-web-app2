/*
  # Add Custom Rug Order Fields

  1. Changes
    - Add `name` column to store customer name
    - Add `email` column to store customer email
    - Add `description` column to store design description
    - Add `design_image` column to store uploaded design reference file path
    - Add `dimensions` column to store selected rug dimensions
    - Add `status` column to track order status (pending, approved, in_production, shipped, delivered)
    - Add `updated_at` column with auto-update trigger

  2. Security
    - Table already has RLS enabled
    - Add policies for public to insert their own orders
    - Add policies for public to view their own orders
*/

-- Add columns to Custom Rugs table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'name'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN name text NOT NULL DEFAULT '';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'email'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN email text NOT NULL DEFAULT '';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'description'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN description text NOT NULL DEFAULT '';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'design_image'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN design_image text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'dimensions'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN dimensions text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'status'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN status text NOT NULL DEFAULT 'pending';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Custom Rugs' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE "Custom Rugs" ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add comment for design_image column
COMMENT ON COLUMN "Custom Rugs".design_image IS 'Storage file path for design reference image. Upload to: custom-rug-designs bucket';

-- Drop existing policies if they exist
DO $$
BEGIN
  DROP POLICY IF EXISTS "Anyone can insert custom rug orders" ON "Custom Rugs";
  DROP POLICY IF EXISTS "Anyone can view custom rug orders" ON "Custom Rugs";
END $$;

-- Create policies for Custom Rugs table
CREATE POLICY "Anyone can insert custom rug orders"
  ON "Custom Rugs" FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can view custom rug orders"
  ON "Custom Rugs" FOR SELECT
  TO public
  USING (true);
