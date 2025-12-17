import { supabase } from './supabase';

export interface CustomRugOrder {
  name: string;
  email: string;
  description: string;
  dimensions: string;
  backing_option: string;
  cut_option: string;
  design_image?: string;
}

export async function uploadDesignImage(file: File): Promise<string> {
  const fileExt = file.name.split('.').pop();
  const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${fileExt}`;
  const filePath = `designs/${fileName}`;

  const { error: uploadError } = await supabase.storage
    .from('custom-rug-designs')
    .upload(filePath, file, {
      cacheControl: '3600',
      upsert: false
    });

  if (uploadError) {
    throw new Error(`Failed to upload image: ${uploadError.message}`);
  }

  const { data: { publicUrl } } = supabase.storage
    .from('custom-rug-designs')
    .getPublicUrl(filePath);

  return publicUrl;
}

async function sendOrderNotification(orderData: CustomRugOrder, orderId: number, trackingNumber: string) {
  try {
    const apiUrl = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/send-order-notification`;
    const headers = {
      'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json',
    };

    const response = await fetch(apiUrl, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        orderId,
        trackingNumber,
        name: orderData.name,
        email: orderData.email,
        description: orderData.description,
        dimensions: orderData.dimensions,
        backing_option: orderData.backing_option,
        cut_option: orderData.cut_option,
        design_image: orderData.design_image,
      }),
    });

    if (!response.ok) {
      console.error('Failed to send email notification:', await response.text());
    }
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

export async function createCustomRugOrder(
  orderData: CustomRugOrder
): Promise<{ success: boolean; orderId?: number; trackingNumber?: string; error?: string }> {
  try {
    const { data, error } = await supabase
      .from('Custom Rugs')
      .insert([
        {
          name: orderData.name,
          email: orderData.email,
          description: orderData.description,
          dimensions: orderData.dimensions,
          backing_option: orderData.backing_option,
          cut_option: orderData.cut_option,
          design_image: orderData.design_image,
          status: 'pending'
        }
      ])
      .select('id, tracking_number')
      .maybeSingle();

    if (error) {
      console.error('Supabase error:', error);
      return { success: false, error: error.message };
    }

    if (data?.id && data?.tracking_number) {
      await sendOrderNotification(orderData, data.id, data.tracking_number);
    }

    return { success: true, orderId: data?.id, trackingNumber: data?.tracking_number };
  } catch (err) {
    console.error('Unexpected error:', err);
    return {
      success: false,
      error: err instanceof Error ? err.message : 'An unexpected error occurred'
    };
  }
}
