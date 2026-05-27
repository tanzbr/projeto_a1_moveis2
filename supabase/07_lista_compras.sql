-- Lista de compras por usuario.
-- Cada usuario tem no maximo UMA lista ativa (unique em usuario_id).
-- Os ingredientes de receitas viram itens; itens com mesmo nome sao
-- agrupados pelo app (consolidacao por nome em lowercase + trim).

create table if not exists public.listas_compras (
  id          bigserial primary key,
  usuario_id  uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now()
);

-- so' uma lista por usuario (simplifica controller e service)
create unique index if not exists listas_compras_usuario_unique
  on public.listas_compras(usuario_id);

create table if not exists public.lista_compras_itens (
  id           bigserial primary key,
  lista_id     bigint not null references public.listas_compras(id) on delete cascade,
  nome         text not null,
  -- texto livre para quantidades; agregamos como array para guardar varias
  -- ocorrencias (ex.: "200g" + "1 xicara") sem tentar conversao automatica
  quantidades  text[] not null default '{}',
  comprado     boolean not null default false,
  created_at   timestamptz not null default now()
);

alter table public.listas_compras enable row level security;
alter table public.lista_compras_itens enable row level security;

-- Policies das listas: dono ve/insere/apaga so' as suas
drop policy if exists "listas_select_minhas" on public.listas_compras;
create policy "listas_select_minhas" on public.listas_compras
  for select using (usuario_id = auth.uid());

drop policy if exists "listas_insert_minhas" on public.listas_compras;
create policy "listas_insert_minhas" on public.listas_compras
  for insert with check (usuario_id = auth.uid());

drop policy if exists "listas_delete_minhas" on public.listas_compras;
create policy "listas_delete_minhas" on public.listas_compras
  for delete using (usuario_id = auth.uid());

-- Policies dos itens: passam pelo lista_id -> usuario dono
drop policy if exists "itens_select_meus" on public.lista_compras_itens;
create policy "itens_select_meus" on public.lista_compras_itens
  for select using (
    exists (
      select 1 from public.listas_compras l
      where l.id = lista_id and l.usuario_id = auth.uid()
    )
  );

drop policy if exists "itens_insert_meus" on public.lista_compras_itens;
create policy "itens_insert_meus" on public.lista_compras_itens
  for insert with check (
    exists (
      select 1 from public.listas_compras l
      where l.id = lista_id and l.usuario_id = auth.uid()
    )
  );

drop policy if exists "itens_update_meus" on public.lista_compras_itens;
create policy "itens_update_meus" on public.lista_compras_itens
  for update using (
    exists (
      select 1 from public.listas_compras l
      where l.id = lista_id and l.usuario_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from public.listas_compras l
      where l.id = lista_id and l.usuario_id = auth.uid()
    )
  );

drop policy if exists "itens_delete_meus" on public.lista_compras_itens;
create policy "itens_delete_meus" on public.lista_compras_itens
  for delete using (
    exists (
      select 1 from public.listas_compras l
      where l.id = lista_id and l.usuario_id = auth.uid()
    )
  );
