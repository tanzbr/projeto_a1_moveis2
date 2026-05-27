-- Receitas passam a ter dono. Cada usuario ve as receitas publicas + as suas.
-- Seeds antigos (sem dono) viram publicos para continuarem aparecendo na Home.

alter table public.receitas
  add column if not exists usuario_id uuid references auth.users(id) on delete set null,
  add column if not exists publica boolean not null default false;

-- seeds preexistentes nao tem dono; marca como publicos
update public.receitas set publica = true where usuario_id is null;

-- Substitui as politicas da fase 02 (todas exigiam apenas estar logado)
drop policy if exists "receitas_select_publico" on public.receitas;
drop policy if exists "receitas_insert_autenticado" on public.receitas;
drop policy if exists "receitas_update_autenticado" on public.receitas;
drop policy if exists "receitas_delete_autenticado" on public.receitas;

-- Cada um le suas + as publicas
create policy "receitas_select_publicas_ou_minhas" on public.receitas
  for select using (publica = true or usuario_id = auth.uid());

-- So pode inserir como dono
create policy "receitas_insert_minhas" on public.receitas
  for insert with check (usuario_id = auth.uid());

-- So o dono edita / exclui
create policy "receitas_update_minhas" on public.receitas
  for update using (usuario_id = auth.uid())
  with check (usuario_id = auth.uid());

create policy "receitas_delete_minhas" on public.receitas
  for delete using (usuario_id = auth.uid());
