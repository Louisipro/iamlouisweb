-- ═══════════════════════════════════════════════════════════
-- MIROIR — table du parcours
-- À exécuter dans Supabase → SQL Editor
-- ═══════════════════════════════════════════════════════════

create table public.posts (
  id           bigint generated always as identity primary key,

  type         text not null default 'note'
               check (type in ('note', 'episode')),

  titre        text,           -- obligatoire pour un épisode, facultatif pour une note
  texte        text not null,  -- le corps ; les sauts de ligne sont conservés
  media_url    text,           -- URL d'une image (facultatif)
  video_id     text,           -- identifiant YouTube, la partie après v= (facultatif)
  slug         text unique,    -- pour un épisode : "mois-01" → episode.html?e=mois-01

  publie       boolean not null default false,   -- brouillon tant que false
  published_at timestamptz not null default now(),
  created_at   timestamptz not null default now()
);

-- Tri du fil : le plus récent en premier
create index posts_date_idx on public.posts (published_at desc);

-- ── SÉCURITÉ ───────────────────────────────────────────────
-- Différence importante avec waitlist :
--   waitlist = écriture publique, lecture interdite
--   posts    = lecture publique, écriture interdite
-- Tu publies depuis le dashboard Supabase, jamais depuis le site.
-- ───────────────────────────────────────────────────────────

alter table public.posts enable row level security;

create policy "lecture publique des posts publiés"
  on public.posts for select to anon
  using (publie = true);

-- Aucune policy insert / update / delete pour anon :
-- personne ne peut publier à ta place.


-- ── EXEMPLES ───────────────────────────────────────────────
-- Une note (mini-vlog) :
insert into public.posts (type, texte, publie) values (
  'note',
  'Jour 1. Photo de référence prise, même lampe, même mur. Rien à montrer encore — c''est le point zéro.',
  true
);

-- Une note avec image :
-- insert into public.posts (type, texte, media_url, publie)
-- values ('note', 'Nouvelle routine du soir.', 'https://…/photo.jpg', true);

-- Un épisode :
-- insert into public.posts (type, titre, texte, video_id, slug, publie)
-- values ('episode', 'Mois 01 — Le point zéro',
--         'Premier bilan complet.', 'dQw4w9WgXcQ', 'mois-01', true);
