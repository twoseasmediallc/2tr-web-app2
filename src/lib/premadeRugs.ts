import { supabase } from './supabase';

export interface PremadeRug {
  id: number;
  created_at: string;
  image: string | null;
  title: string | null;
  description: string | null;
  price: string | null;
  date_sold: string | null;
  updated_at: string | null;
}

export async function fetchPremadeRugs(): Promise<{
  data: PremadeRug[] | null;
  error: string | null
}> {
  try {
    const { data, error } = await supabase
      .from('Pre-made Rugs')
      .select('*')
      .is('date_sold', null)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Supabase error:', error);
      return { data: null, error: error.message };
    }

    return { data, error: null };
  } catch (err) {
    console.error('Unexpected error:', err);
    return {
      data: null,
      error: err instanceof Error ? err.message : 'An unexpected error occurred'
    };
  }
}
