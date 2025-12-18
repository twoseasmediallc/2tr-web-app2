/*
  # Fix Email Notification Trigger Function

  1. Changes
    - Updates the trigger function to send all required fields to the edge function
    - Fixes the payload structure to match what the edge function expects
    - Ensures orderId, trackingNumber, description, and design_image are included
    
  2. Important Notes
    - The edge function requires: orderId, trackingNumber, name, email, description, dimensions, backing_option, cut_option, design_image
    - Uses pg_net extension for HTTP requests
    - Trigger runs asynchronously to avoid blocking the INSERT operation
*/

-- Drop and recreate the function with correct payload structure
CREATE OR REPLACE FUNCTION notify_new_custom_rug_order()
RETURNS TRIGGER AS $$
DECLARE
  function_url TEXT;
  payload JSONB;
  request_id BIGINT;
BEGIN
  -- Construct the edge function URL
  function_url := 'https://esvrzocrrwabwrvlurpf.supabase.co/functions/v1/send-order-notification';
  
  -- Build the complete payload with all required fields
  payload := jsonb_build_object(
    'orderId', NEW.id,
    'trackingNumber', COALESCE(NEW.tracking_number, 'Pending'),
    'name', NEW.name,
    'email', NEW.email,
    'description', NEW.description,
    'dimensions', NEW.dimensions,
    'backing_option', COALESCE(NEW.backing_option, 'Not specified'),
    'cut_option', COALESCE(NEW.cut_option, 'Not specified'),
    'design_image', NEW.design_image
  );
  
  -- Make async HTTP POST request to edge function
  SELECT extensions.http_post(
    url := function_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzdnJ6b2NycndhYndydmx1cnBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ3MjAzNjksImV4cCI6MjA4MDI5NjM2OX0.-8IjWYSVbsV4UM6qdc2_el9zhdPyAtvH0RHx7YtqDwA'
    ),
    body := payload
  ) INTO request_id;
  
  -- Log the request (optional, for debugging)
  RAISE NOTICE 'Email notification request sent with ID: %, payload: %', request_id, payload;
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log error but don't fail the insert
  RAISE WARNING 'Failed to send email notification: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
