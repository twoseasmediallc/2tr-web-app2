import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL!,
  import.meta.env.VITE_SUPABASE_ANON_KEY!
);

export async function submitRugRequest(form: any) {
  const { error } = await supabase
    .from("custom_rug_orders") // <-- MUST match the trigger table
    .insert([{
      name: form.name,
      email: form.email,
      phone: form.phone,
      design_description: form.designDescription,
      dimensions: form.dimensions,
      cut_option: form.cutOption,
      backing_option: form.backingOption,
      // optional: add who should receive it
      notify_to: "chinagrayer@twotuftrugs.com"
    }]);

  if (error) throw error;
}
