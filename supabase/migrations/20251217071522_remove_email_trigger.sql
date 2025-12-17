/*
  # Remove Email Notification Trigger
  
  1. Changes
    - Removes the database trigger for email notifications
    - Removes the trigger function
    - Keeps pg_net extension for potential future use
    
  2. Reason
    - The pg_net extension has cross-database reference issues
    - Email notifications will be handled from the frontend instead
*/

-- Drop the trigger
DROP TRIGGER IF EXISTS trigger_notify_custom_rug_order ON "Custom Rugs";

-- Drop the function
DROP FUNCTION IF EXISTS notify_new_custom_rug_order();
