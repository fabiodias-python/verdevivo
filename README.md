# Verdevivo

Plataforma para apoiar pessoas, comunidades e governos estaduais na implementação de **jardins de chuva** no Brasil.

Criado por **Fábio**.

## Sobre

Jardins de chuva são áreas rebaixadas e vegetadas que captam a água da chuva escoada de telhados, calçadas e ruas, permitindo que ela infiltre no solo de forma gradual. Eles reduzem alagamentos, ajudam a recarregar o lençol freático, filtram poluentes e ainda trazem mais verde e biodiversidade para as cidades.

O Verdevivo nasceu com um objetivo: **tornar mais fácil para qualquer pessoa, município ou estado do Brasil planejar e implantar jardins de chuva**, reunindo informação confiável, exemplos de projetos e orientação prática em um só lugar.

## Missão

- Levar o conhecimento sobre jardins de chuva a cidadãos, escolas e comunidades
- Apoiar estados e municípios na adoção da solução como política de drenagem sustentável
- Mostrar projetos reais e acompanhar o andamento de cada iniciativa
- Incentivar o uso de plantas nativas adequadas a cada região do país

## Funcionalidades

- Catálogo de projetos de jardins de chuva, com nome, tipo, descrição e status
- Conteúdo educativo sobre o que são, como funcionam e quais os benefícios
- Orientações para implantação (escolha do local, solo, plantas, manutenção)
- Página de contato para pessoas e órgãos públicos interessados

## Tecnologias

- **Frontend:** [HTML/CSS/JS, React, Next.js, etc.]
- **Backend e banco de dados:** [Supabase](https://supabase.com) (PostgreSQL)
- **Hospedagem:** [GitHub Pages](https://pages.github.com)

## Estrutura do banco de dados

Tabela `public.projects`:

| Coluna        | Tipo | Descrição                                          |
|---------------|------|----------------------------------------------------|
| `id`          | uuid | Identificador único (chave primária)               |
| `name`        | text | Nome do projeto                                    |
| `type`        | text | Tipo (ex.: residencial, escola, via pública, praça) |
| `description` | text | Descrição do projeto                               |
| `status`      | text | Situação (ex.: planejado, em andamento, concluído) |

### Segurança (RLS)

A tabela usa **Row Level Security**. Para o site exibir os projetos, é necessária uma política de leitura pública:

```sql
create policy "Leitura publica de projetos"
on public.projects
for select
to anon
using (true);
```

Escrita (insert, update, delete) deve ficar restrita a usuários autenticados.

## Cadastrando projetos

Pelo painel do Supabase (**Table Editor > projects > Insert**) ou via SQL:

```sql
insert into public.projects (name, type, description, status)
values (
  'Jardim de chuva da Escola Municipal X',
  'escola',
  'Jardim de chuva para captar a água do telhado do pátio.',
  'planejado'
);
```

## Deploy

O site é publicado no **GitHub Pages**: https://fabiodias-python.github.io/verdevivo/

Para atualizar, basta enviar as alterações para a branch configurada em **Settings > Pages**:

```bash
git add .
git commit -m "Descrição da alteração"
git push origin main
```

O GitHub Pages só serve arquivos estáticos e não lê arquivos `.env` em produção. Como o site é público, a chave `anon` do Supabase fica no código do frontend. Isso é esperado e seguro **desde que a RLS esteja ativa e bem configurada**, pois é ela que protege os dados.

## Como contribuir

Quer ajudar a espalhar jardins de chuva pelo Brasil? Você pode:

- Sugerir ou cadastrar um projeto
- Compartilhar materiais técnicos e experiências da sua cidade
- Reportar problemas ou propor melhorias abrindo uma *issue*

## Roadmap

- [ ] Mapa interativo dos jardins de chuva existentes
- [ ] Guia de plantas nativas por bioma e região
- [ ] Material de apoio para gestores estaduais e municipais
- [ ] [Outra melhoria planejada]

