/*
  # Fix Security Issues

  1. RLS Policy Performance Optimization
    - Update all `Profiles` table policies to use `(select auth.uid())` instead of `auth.uid()`
    - This prevents re-evaluation of auth.uid() for each row, improving query performance at scale

  2. Function Search Path Security
    - Add explicit `SET search_path = ''` to all functions to prevent search_path manipulation
    - Affects functions:
      - `handle_new_user` - Creates profile on user signup
      - `handle_updated_at` - Updates timestamp on profile changes
      - `update_updated_at_column` - Updates timestamp on table changes
      - `generate_tracking_number` - Generates unique tracking numbers
      - `assign_tracking_number` - Assigns tracking numbers to orders

  ## Notes
  - Auth DB Connection Strategy: Must be changed in Supabase Dashboard > Settings > Database > Connection pooling
  - Leaked Password Protection: Must be enabled in Supabase Dashboard > Authentication > Settings > Password Protection
*/

-- ============================================
-- 1. FIX RLS POLICIES FOR PERFORMANCE
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read own profile" ON public."Profiles";
DROP POLICY IF EXISTS "Users can insert own profile" ON public."Profiles";
DROP POLICY IF EXISTS "Users can update own profile" ON public."Profiles";

-- Recreate policies with optimized auth.uid() calls
CREATE POLICY "Users can read own profile"
  ON public."Profiles"
  FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = id);

CREATE POLICY "Users can insert own profile"
  ON public."Profiles"
  FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = id);

CREATE POLICY "Users can update own profile"
  ON public."Profiles"
  FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = id)
  WITH CHECK ((select auth.uid()) = id);

-- ============================================
-- 2. FIX FUNCTION SEARCH PATHS
-- ============================================

-- Fix handle_new_user function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public."Profiles" (id, name, email)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'name', ''),
    new.email
  );
  RETURN new;
END;
$$;

-- Fix handle_updated_at function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  new.updated_at = now();
  RETURN new;
END;
$$;

-- Fix update_updated_at_column function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Fix generate_tracking_number function
CREATE OR REPLACE FUNCTION public.generate_tracking_number()
RETURNS text
LANGUAGE plpgsql
SET search_path = ''
AS $$
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
  WHILE EXISTS (SELECT 1 FROM public."Custom Rugs" WHERE tracking_number = new_tracking_number) LOOP
    random_part := lpad(floor(random() * 100000)::text, 5, '0');
    new_tracking_number := '2TR-' || date_part || '-' || random_part;
  END LOOP;
  
  RETURN new_tracking_number;
END;
$$;

-- Fix assign_tracking_number function
CREATE OR REPLACE FUNCTION public.assign_tracking_number()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF NEW.tracking_number IS NULL THEN
    NEW.tracking_number := public.generate_tracking_number();
  END IF;
  RETURN NEW;
END;
$$;