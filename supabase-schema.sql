-- VerdeVivo Brasil — banco de dados (Supabase)
-- Cole no Supabase: SQL Editor > New query > Run

create table if not exists public.projects (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 3 and 90),
  type        text not null check (type in ('Escola','Comunidade')),
  description text check (char_length(description) <= 300),
  status      text not null default 'Em planejamento'
              check (status in ('Em planejamento','Em andamento','Concluído')),
  approved    boolean not null default false,   -- você aprova no painel
  created_at  timestamptz not null default now()
);

alter table public.projects enable row level security;

-- Qualquer visitante lê apenas projetos aprovados
drop policy if exists "ler aprovados" on public.projects;
create policy "ler aprovados" on public.projects
  for select to anon using (approved = true);

-- Qualquer visitante pode enviar, mas sempre como "não aprovado"
drop policy if exists "enviar projeto" on public.projects;
create policy "enviar projeto" on public.projects
  for insert to anon
  with check (approved = false and status = 'Em planejamento');

-- Permissões mínimas: ler e inserir só as colunas abaixo
revoke all on public.projects from anon;
grant select (id, name, type, description, status, created_at) on public.projects to anon;
grant insert (name, type, description, status) on public.projects to anon;

-- Para aprovar: Table Editor > projects > marque "approved".
-- Visitantes não conseguem editar nem apagar nada.
