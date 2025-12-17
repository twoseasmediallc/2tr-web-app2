/*
  # Add RLS Policies for Pre-made Rugs

  1. Security Changes
    - Add policy to allow public SELECT access to Pre-made Rugs table
    - This allows anyone to view the available rugs without authentication
  
  2. Important Notes
    - Only SELECT operations are allowed for public users
    - This is safe because users only need to view rugs, not modify them
*/

-- Drop existing policies if they exist
DO $$
BEGIN
  DROP POLICY IF EXISTS "Public can view pre-made rugs" ON "Pre-made Rugs";
END $$;

-- Create policy to allow public to view pre-made rugs
CREATE POLICY "Public can view pre-made rugs"
  ON "Pre-made Rugs" FOR SELECT
  TO public
  USING (true);
