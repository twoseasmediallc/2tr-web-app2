import { supabase } from './supabase';

export interface TrackingInfo {
  id: number;
  tracking_number: string;
  status: string;
  name: string;
  email: string;
  dimensions: string;
  backing_option: string;
  cut_option: string;
  created_at: string;
  updated_at: string;
}

export async function lookupTracking(trackingNumber: string): Promise<{
  data: TrackingInfo | null;
  error: string | null;
}> {
  try {
    const { data, error } = await supabase
      .from('Custom Rugs')
      .select('*')
      .eq('tracking_number', trackingNumber.trim().toUpperCase())
      .maybeSingle();

    if (error) {
      return { data: null, error: 'Failed to lookup tracking number. Please try again.' };
    }

    if (!data) {
      return { data: null, error: 'Tracking number not found. Please check and try again.' };
    }

    return { data: data as TrackingInfo, error: null };
  } catch (err) {
    return { data: null, error: 'An unexpected error occurred. Please try again.' };
  }
}

export function getOrderStageIndex(status: string): number {
  const stages = ['pending', 'in_production', 'quality_check', 'shipped', 'delivered'];
  const index = stages.indexOf(status.toLowerCase());
  return index === -1 ? 0 : index;
}

export function getOrderStageLabel(status: string): string {
  const labels: { [key: string]: string } = {
    'pending': 'Order Placed',
    'in_production': 'In Production',
    'quality_check': 'Quality Check',
    'shipped': 'Shipped',
    'delivered': 'Delivered'
  };
  return labels[status.toLowerCase()] || 'Order Placed';
}
