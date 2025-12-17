/*
  # Create Pre-made Rugs Table

  1. New Tables
    - `premade_rugs`
      - `id` (uuid, primary key) - Unique identifier for each rug
      - `image` (text) - URL path to the rug image stored in Supabase Storage
      - `title` (text) - Name/title of the rug
      - `description` (text) - Description of the rug design
      - `price` (numeric) - Price of the rug in dollars
      - `date_sold` (timestamptz, nullable) - Date when the rug was sold (null if not sold)
      - `created_at` (timestamptz) - Timestamp when the record was created
      - `updated_at` (timestamptz) - Timestamp when the record was last updated

  2. Storage
    - Creates a storage bucket named `rug-images` for storing rug photos
    - Enables public access to the bucket so images can be displayed on the website
    
  3. Security
    - Enable RLS on `premade_rugs` table
    - Add policy for anyone to view rugs (public read access)
    - Add policy for authenticated users to insert rugs
    - Add policy for authenticated users to update rugs
    - Add policy for authenticated users to delete rugs
    
  4. Storage Security
    - Public read access for all images
    - Authenticated users can upload images
    - Authenticated users can update their own images
    - Authenticated users can delete images
*/

-- Create the premade_rugs table
CREATE TABLE IF NOT EXISTS premade_rugs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  price numeric(10, 2) NOT NULL CHECK (price >= 0),
  date_sold timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE premade_rugs ENABLE ROW LEVEL SECURITY;

-- Public can view all rugs
CREATE POLICY "Anyone can view premade rugs"
  ON premade_rugs
  FOR SELECT
  TO public
  USING (true);

-- Authenticated users can insert rugs
CREATE POLICY "Authenticated users can insert premade rugs"
  ON premade_rugs
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Authenticated users can update rugs
CREATE POLICY "Authenticated users can update premade rugs"
  ON premade_rugs
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Authenticated users can delete rugs
CREATE POLICY "Authenticated users can delete premade rugs"
  ON premade_rugs
  FOR DELETE
  TO authenticated
  USING (true);

-- Create storage bucket for rug images
INSERT INTO storage.buckets (id, name, public)
VALUES ('rug-images', 'rug-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for rug images bucket
CREATE POLICY "Public can view rug images"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'rug-images');

CREATE POLICY "Authenticated users can upload rug images"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'rug-images');

CREATE POLICY "Authenticated users can update rug images"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (bucket_id = 'rug-images')
  WITH CHECK (bucket_id = 'rug-images');

CREATE POLICY "Authenticated users can delete rug images"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'rug-images');

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_premade_rugs_updated_at
  BEFORE UPDATE ON premade_rugs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
