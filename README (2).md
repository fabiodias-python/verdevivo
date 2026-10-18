# 🌱 VerdeVivo Brasil

**Plataforma educativa para apoiar pessoas, escolas, comunidades e gestores públicos na adoção de jardins de chuva no Brasil.**

> 🔗 **Demonstração:** https://fabiodias-python.github.io/verdevivo/

Criado por **Fábio** · Protótipo educativo · Versão 0.7

---

## Sobre o projeto

Jardins de chuva são áreas rebaixadas e vegetadas que recebem a água escoada de telhados, calçadas e ruas e a deixam infiltrar no solo de forma gradual. Eles ajudam a reduzir alagamentos, recarregar o lençol freático, filtrar poluentes e ampliar a biodiversidade urbana.

Apesar dos benefícios, a informação prática sobre o tema é dispersa e pouco acessível. O VerdeVivo reúne em um só lugar conteúdo educativo, ferramentas interativas e um cadastro colaborativo de iniciativas, para que qualquer pessoa consiga dar os primeiros passos, entender o que precisa ser avaliado e saber quando procurar apoio técnico.

### Missão

- Levar conhecimento sobre jardins de chuva a cidadãos, escolas e comunidades.
- Apoiar municípios e estados na adoção da solução como drenagem sustentável.
- Dar visibilidade a iniciativas reais e acompanhar o andamento de cada uma.
- Incentivar o uso de plantas nativas adequadas a cada bioma.

> **Território-piloto proposto:** Nilópolis e a Baixada Fluminense (RJ). É uma proposta de piloto: não representa parceria oficial, mapeamento confirmado nem dados ambientais verificados.

---

## Funcionalidades

| Módulo | O que faz |
|---|---|
| **Jardim de chuva** | Explica o conceito em quatro passos (local, solo, plantas nativas, manutenção) e traz um checklist para avaliar se o espaço está pronto. |
| **Guia de plantas nativas** | Exemplos de espécies para os seis biomas brasileiros, com a zona sugerida no jardim (centro mais úmido, zona intermediária ou borda mais seca). |
| **Assistente ambiental** | Orientações educativas predefinidas para alagamento, falta de áreas verdes, resíduos e educação ambiental na escola. |
| **Laboratório da chuva** | Simulador que estima o volume de água que escoa conforme a chuva, a área e a superfície. Mostra litros, baldes de 20 L, a fração que escoa, uma área de referência para o jardim (10% a 30% da área drenada) e permite copiar um resumo. |
| **Projetos verdes** | Envio de iniciativas de escolas e comunidades, com busca, situação do projeto e exportação em JSON. |
| **Mapa de iniciativas** | Mapa interativo (Leaflet + OpenStreetMap) com a localização aproximada das iniciativas. |

### Decisões de projeto

- **Honestidade sobre o que o protótipo faz.** O assistente usa regras predefinidas e não é um modelo de IA. O site informa isso na própria interface e não apresenta dados fictícios como ocorrências reais.
- **Privacidade por padrão.** As coordenadas do mapa são arredondadas a duas casas decimais (cerca de 1 km), o formulário orienta a não informar casas, nomes completos, telefones nem dados de crianças, e todo envio passa por moderação antes de ficar público.
- **Segurança.** Todo texto digitado pelo usuário é inserido com `textContent` ou escapado, o que previne XSS. O banco é protegido por Row Level Security.
- **Acessibilidade.** Link de salto para o conteúdo, rótulos em todos os campos, regiões `aria-live`, indicação da seção atual no menu, foco visível e respeito a `prefers-reduced-motion`.
- **Funciona sem backend.** Sem o Supabase configurado, o cadastro de projetos opera em modo local, salvando no navegador.

---

## Tecnologias

- **Frontend:** HTML, CSS e JavaScript puros, em um único arquivo (`index.html`), sem etapa de build.
- **Mapa:** [Leaflet](https://leafletjs.com) 1.9.4 com tiles do [OpenStreetMap](https://www.openstreetmap.org/copyright).
- **Backend e banco de dados:** [Supabase](https://supabase.com) (PostgreSQL, API REST e Row Level Security).
- **Hospedagem:** [GitHub Pages](https://pages.github.com).

```
.
├── index.html   # site completo (HTML, CSS e JS)
└── README.md
```

---

## Como rodar localmente

Não há dependências para instalar. Sirva a pasta com qualquer servidor estático, por exemplo:

```bash
git clone https://github.com/fabiodias-python/verdevivo.git
cd verdevivo
python -m http.server 8000
```

Abra `http://localhost:8000`.

Se o objeto `SB` do `index.html` estiver vazio, o site funciona em **modo local**: os projetos ficam salvos apenas no navegador. Com `SB` preenchido, passa ao **modo online**, usando o Supabase.

---

## Configurando o Supabase

1. Crie um projeto no [Supabase](https://supabase.com).
2. No **SQL Editor**, execute o script abaixo (para um banco novo):

```sql
create table if not exists public.projects (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 3 and 90),
  type        text not null check (type in ('Escola', 'Comunidade')),
  description text check (char_length(description) <= 300),
  status      text not null default 'Em planejamento'
              check (status in ('Em planejamento', 'Em andamento', 'Concluído')),
  approved    boolean not null default false,
  lat         double precision check (lat between -90 and 90),
  lng         double precision check (lng between -180 and 180),
  created_at  timestamptz not null default now()
);

alter table public.projects enable row level security;

grant select, insert on public.projects to anon;

-- Qualquer pessoa vê apenas projetos aprovados
create policy "Leitura de aprovados" on public.projects
  for select to anon using (approved);

-- Qualquer pessoa pode enviar, mas sempre como "não aprovado"
create policy "Envio publico" on public.projects
  for insert to anon
  with check (
    approved = false
    and status = 'Em planejamento'
    and char_length(name) between 3 and 90
  );
```

3. Em **Project Settings > API**, copie a **Project URL** e a chave **publishable** (anon) e preencha o objeto `SB` no `index.html`:

```js
const SB = { url: 'https://SEU-PROJETO.supabase.co', key: 'SUA-CHAVE-PUBLISHABLE' };
```

> **Importante:** nunca publique a chave `service_role` no frontend nem no repositório. A chave publishable fica visível no código por natureza; quem protege os dados é a RLS.

### Já tem a tabela criada?

Adicione as colunas novas e substitua a política de leitura antiga:

```sql
alter table public.projects
  add column if not exists approved boolean not null default false,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists lat double precision check (lat between -90 and 90),
  add column if not exists lng double precision check (lng between -180 and 180);

drop policy if exists "Leitura publica de projetos" on public.projects;
```

Depois crie as duas políticas do script acima.

### Moderação

Os envios chegam com `approved = false`. Para publicar, abra **Table Editor > projects**, marque `approved` como `true` na linha desejada, ou use SQL:

```sql
update public.projects set approved = true where id = 'ID-DO-PROJETO';
```

---

## Deploy

O site é publicado no **GitHub Pages**, a partir da branch `main`, em **Settings > Pages**. Para atualizar:

```bash
git add .
git commit -m "Descrição da alteração"
git push origin main
```

Se você configurar um domínio próprio, o GitHub cria um arquivo `CNAME` por meio de um commit. Rode `git pull` antes do próximo `git push`.

---

## Limitações conhecidas

- O assistente ambiental e as recomendações são **educativos e predefinidos**. Não substituem avaliação profissional: o dimensionamento de um jardim de chuva exige análise do solo, da drenagem e das redes subterrâneas.
- Os coeficientes de escoamento do simulador são valores de referência. Os reais variam com inclinação, tipo de solo e umidade.
- As espécies do guia de plantas são **exemplos educativos**. Confirme a ocorrência natural na sua região e a origem das mudas com um viveiro ou técnico local.
- O limite de um envio por minuto e o campo anti-spam são feitos no navegador e **não substituem** proteção no servidor.
- O mapa depende de conexão para carregar os blocos do OpenStreetMap.

---

## Roadmap

- [x] Conteúdo educativo sobre jardins de chuva e checklist de viabilidade
- [x] Simulador de escoamento da chuva
- [x] Guia de plantas nativas por bioma
- [x] Mapa interativo de iniciativas, com localização aproximada
- [ ] Painel de moderação com autenticação
- [ ] Proteção no servidor contra spam (limite por IP ou CAPTCHA)
- [ ] Validação do guia de plantas com especialistas e fontes botânicas
- [ ] Material de apoio para gestores estaduais e municipais
- [ ] Fotos e acompanhamento de cada iniciativa ao longo do tempo
- [ ] Assistente com IA, com base técnica revisada

---

## Como contribuir

- Sugira ou cadastre uma iniciativa pelo próprio site.
- Compartilhe materiais técnicos e experiências da sua cidade.
- Reporte problemas ou proponha melhorias abrindo uma *issue*.

---

## Créditos

- Mapa: © [colaboradores do OpenStreetMap](https://www.openstreetmap.org/copyright), com [Leaflet](https://leafletjs.com).

## Contato

**Fábio** · [github.com/fabiodias-python](https://github.com/fabiodias-python)

## Licença

[MIT](LICENSE)
