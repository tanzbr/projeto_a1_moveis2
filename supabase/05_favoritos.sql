-- Favoritos passam a ser por usuario, em tabela propria.
-- A coluna `favorito` na tabela receitas (que era global) e' removida.

create table if not exists public.favoritos (
  usuario_id  uuid not null references auth.users(id) on delete cascade,
  receita_id  bigint not null references public.receitas(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (usuario_id, receita_id)
);

alter table public.favoritos enable row level security;

drop policy if exists "favoritos_select_meus" on public.favoritos;
create policy "favoritos_select_meus" on public.favoritos
  for select using (usuario_id = auth.uid());

drop policy if exists "favoritos_insert_meus" on public.favoritos;
create policy "favoritos_insert_meus" on public.favoritos
  for insert with check (usuario_id = auth.uid());

drop policy if exists "favoritos_delete_meus" on public.favoritos;
create policy "favoritos_delete_meus" on public.favoritos
  for delete using (usuario_id = auth.uid());

-- coluna `favorito` deixa de fazer sentido: a tabela favoritos manda agora
alter table public.receitas drop column if exists favorito;
