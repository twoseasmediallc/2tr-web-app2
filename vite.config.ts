import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL!,
  import.meta.env.VITE_SUPABASE_ANON_KEY!
);

export async function submitRugRequest(form: any) {
  const res = await fetch(
    `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/send-order-notification`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // If your function requires auth:
        "Authorization": `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        to: "chinagrayer@twotuftrugs.com",
        ...form,
      }),
    }
  );

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Email failed: ${res.status} ${text}`);
  }
}


