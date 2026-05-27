-- Tabela de receitas no Supabase (Postgres).
-- Espelha o modelo Receita do app, em snake_case (convencao Postgres).
-- A coluna `favorito` esta aqui enquanto nao ha autenticacao;
-- o plano de auth movera favoritos para uma tabela por usuario.

create table if not exists public.receitas (
  id              bigserial primary key,
  nome            text not null,
  descricao       text default '',
  imagem_url      text default '',
  tempo_minutos   integer not null default 0,
  porcoes         integer not null default 0,
  dificuldade     text not null,
  categoria       text not null,
  ingredientes    jsonb not null default '[]'::jsonb,
  modo_preparo    jsonb not null default '[]'::jsonb,
  destaque        boolean not null default false,
  favorito        boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- mantem updated_at sempre coerente em updates
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_receitas_updated_at on public.receitas;
create trigger trg_receitas_updated_at
before update on public.receitas
for each row execute function public.set_updated_at();

-- RLS aberto para anon enquanto a autenticacao nao esta pronta.
-- Os planos seguintes restringem para o usuario dono.
alter table public.receitas enable row level security;

drop policy if exists "receitas_select_all" on public.receitas;
create policy "receitas_select_all" on public.receitas
  for select using (true);

drop policy if exists "receitas_insert_all" on public.receitas;
create policy "receitas_insert_all" on public.receitas
  for insert with check (true);

drop policy if exists "receitas_update_all" on public.receitas;
create policy "receitas_update_all" on public.receitas
  for update using (true) with check (true);

drop policy if exists "receitas_delete_all" on public.receitas;
create policy "receitas_delete_all" on public.receitas
  for delete using (true);
