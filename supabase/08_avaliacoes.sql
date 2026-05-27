-- Avaliacoes simples (1 a 5) por usuario, uma por receita.
-- A media e o total ficam derivados (calculados no app a partir das linhas).

create table if not exists public.avaliacoes (
  usuario_id  uuid not null references auth.users(id) on delete cascade,
  receita_id  bigint not null references public.receitas(id) on delete cascade,
  nota        smallint not null check (nota between 1 and 5),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  primary key (usuario_id, receita_id)
);

-- reaproveita o trigger set_updated_at criado em 01_receitas.sql
drop trigger if exists trg_avaliacoes_updated_at on public.avaliacoes;
create trigger trg_avaliacoes_updated_at
before update on public.avaliacoes
for each row execute function public.set_updated_at();

alter table public.avaliacoes enable row level security;

-- qualquer um (logado ou nao) ve as notas
drop policy if exists "avaliacoes_select_publico" on public.avaliacoes;
create policy "avaliacoes_select_publico" on public.avaliacoes
  for select using (true);

-- so' o dono insere/atualiza/remove a propria nota
drop policy if exists "avaliacoes_insert_minhas" on public.avaliacoes;
create policy "avaliacoes_insert_minhas" on public.avaliacoes
  for insert with check (usuario_id = auth.uid());

drop policy if exists "avaliacoes_update_minhas" on public.avaliacoes;
create policy "avaliacoes_update_minhas" on public.avaliacoes
  for update using (usuario_id = auth.uid())
  with check (usuario_id = auth.uid());

drop policy if exists "avaliacoes_delete_minhas" on public.avaliacoes;
create policy "avaliacoes_delete_minhas" on public.avaliacoes
  for delete using (usuario_id = auth.uid());
