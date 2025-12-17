/*
  # Add Columns to Pre-made Rugs Table

  1. Changes to Tables
    - Add columns to `premade_rugs` table:
      - `image` (text) - URL path to the rug image stored in Supabase Storage
      - `title` (text) - Name/title of the rug
      - `description` (text) - Description of the rug design
      - `price` (numeric) - Price of the rug in dollars
      - `date_sold` (timestamptz, nullable) - Date when the rug was sold (null if not sold)
      - `updated_at` (timestamptz) - Timestamp when the record was last updated

  2. Storage
    - Creates a storage bucket named `rug-images` for storing rug photos
    - Enables public access to the bucket so images can be displayed on the website
    
  3. Security
    - Policies already exist on the table
    - Add storage policies for the rug-images bucket:
      - Public read access for all images
      - Authenticated users can upload, update, and delete images
    
  4. Functions & Triggers
    - Create function to auto-update `updated_at` timestamp
    - Create trigger to call the function on updates
*/

-- Add columns to existing table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Pre-made Rugs' AND column_name = 'image'
  ) THEN
    ALTER TABLE "Pre-made Rugs" ADD COLUMN image text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Pre-made Rugs' AND column_name = 'title'
  ) THEN
    ALTER TABLE "Pre-made Rugs" ADD COLUMN title text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Pre-made Rugs' AND column_name = 'description'
  ) THEN
    ALTER TABLE "Pre-made Rugs" ADD COLUMN description text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Pre-made Rugs' AND column_name = 'price'
  ) THEN
    ALTER TABLE "Pre-made Rugs" ADD COLUMN price numeric(10, 2);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Pre-made Rugs' AND column_name = 'date_sold'
  ) THEN
    ALTER TABLE "Pre-made Rugs" ADD COLUMN date_sold timestamptz;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Pre-made Rugs' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE "Pre-made Rugs" ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add constraints
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.constraint_column_usage
    WHERE table_name = 'Pre-made Rugs' AND constraint_name LIKE '%price_check%'
  ) THEN
    ALTER TABLE "Pre-made Rugs" ADD CONSTRAINT price_check CHECK (price >= 0);
  END IF;
END $$;

-- Create storage bucket for rug images
INSERT INTO storage.buckets (id, name, public)
VALUES ('rug-images', 'rug-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for rug images bucket
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Public can view rug images'
  ) THEN
    CREATE POLICY "Public can view rug images"
      ON storage.objects
      FOR SELECT
      TO public
      USING (bucket_id = 'rug-images');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Authenticated users can upload rug images'
  ) THEN
    CREATE POLICY "Authenticated users can upload rug images"
      ON storage.objects
      FOR INSERT
      TO authenticated
      WITH CHECK (bucket_id = 'rug-images');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Authenticated users can update rug images'
  ) THEN
    CREATE POLICY "Authenticated users can update rug images"
      ON storage.objects
      FOR UPDATE
      TO authenticated
      USING (bucket_id = 'rug-images')
      WITH CHECK (bucket_id = 'rug-images');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Authenticated users can delete rug images'
  ) THEN
    CREATE POLICY "Authenticated users can delete rug images"
      ON storage.objects
      FOR DELETE
      TO authenticated
      USING (bucket_id = 'rug-images');
  END IF;
END $$;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_premade_rugs_updated_at ON "Pre-made Rugs";
CREATE TRIGGER update_premade_rugs_updated_at
  BEFORE UPDATE ON "Pre-made Rugs"
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();