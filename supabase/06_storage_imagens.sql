-- Bucket publico para armazenar imagens de receitas enviadas pelos usuarios.
-- Caminho dos arquivos: <auth.uid()>/<timestamp>.jpg
-- A pasta inicial igual ao uid garante que cada usuario so mexe nos seus.

insert into storage.buckets (id, name, public)
values ('receitas-imagens', 'receitas-imagens', true)
on conflict (id) do update set public = excluded.public;

-- Leitura publica (qualquer um ve as imagens das receitas)
drop policy if exists "imagens_select_publico" on storage.objects;
create policy "imagens_select_publico" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'receitas-imagens');

-- Upload so' para usuario logado e dentro da sua propria pasta
drop policy if exists "imagens_insert_dono" on storage.objects;
create policy "imagens_insert_dono" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'receitas-imagens'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Update e delete tambem so' do dono
drop policy if exists "imagens_update_dono" on storage.objects;
create policy "imagens_update_dono" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'receitas-imagens'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "imagens_delete_dono" on storage.objects;
create policy "imagens_delete_dono" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'receitas-imagens'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
