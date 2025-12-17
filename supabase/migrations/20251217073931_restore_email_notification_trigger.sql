/*
  # Restore Email Notification Trigger for Custom Rug Orders

  1. Changes
    - Recreates the trigger function that sends order data to the send-order-notification edge function
    - Recreates the trigger that fires after INSERT on "Custom Rugs" table
    
  2. How it works
    - When a new row is inserted into "Custom Rugs", the trigger automatically fires
    - The trigger function gathers all order details and sends them to the edge function
    - The edge function sends an email notification to chinagrayer@twotuftrugs.com
    
  3. Important Notes
    - Uses pg_net extension for HTTP requests
    - Trigger runs asynchronously to avoid blocking the INSERT operation
*/

-- Ensure pg_net extension is enabled
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Create function to send order notification
CREATE OR REPLACE FUNCTION notify_new_custom_rug_order()
RETURNS TRIGGER AS $$
DECLARE
  function_url TEXT;
  payload JSONB;
  request_id BIGINT;
BEGIN
  -- Construct the edge function URL
  function_url := 'https://esvrzocrrwabwrvlurpf.supabase.co/functions/v1/send-order-notification';
  
  -- Build the payload with order details
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
  RAISE NOTICE 'Email notification request sent with ID: %', request_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on "Custom Rugs" table
DROP TRIGGER IF EXISTS trigger_notify_custom_rug_order ON "Custom Rugs";
CREATE TRIGGER trigger_notify_custom_rug_order
  AFTER INSERT ON "Custom Rugs"
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_custom_rug_order();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA extensions TO postgres, service_role;
