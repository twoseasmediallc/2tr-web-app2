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

    return { success: true, orderId: data?.id, trackingNumber: data?.tracking_number };
  } catch (err) {
    console.error('Unexpected error:', err);
    return {
      success: false,
      error: err instanceof Error ? err.message : 'An unexpected error occurred'
    };
  }
}
