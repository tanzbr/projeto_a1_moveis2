-- Restringe escrita na tabela receitas a usuarios autenticados.
-- Substitui as politicas abertas criadas em 01_receitas.sql.
-- Leitura segue publica (qualquer um, logado ou nao, pode listar receitas).

drop policy if exists "receitas_select_all" on public.receitas;
drop policy if exists "receitas_insert_all" on public.receitas;
drop policy if exists "receitas_update_all" on public.receitas;
drop policy if exists "receitas_delete_all" on public.receitas;

create policy "receitas_select_publico" on public.receitas
  for select using (true);

create policy "receitas_insert_autenticado" on public.receitas
  for insert with check (auth.uid() is not null);

create policy "receitas_update_autenticado" on public.receitas
  for update using (auth.uid() is not null)
  with check (auth.uid() is not null);

create policy "receitas_delete_autenticado" on public.receitas
  for delete using (auth.uid() is not null);
