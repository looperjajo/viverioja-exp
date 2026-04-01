-- =============================================================
-- ScriptMind — Datos Ficticios Realistas (6 meses operación)
-- Periodo: Enero 2024 – Junio 2024
-- =============================================================
-- DISTRIBUCIÓN REALISTA DE UN SAAS EARLY-STAGE:
-- - ~55% usuarios Free (muchos no convierten nunca)
-- - ~30% Pro (el grueso del revenue)
-- - ~10% Max (pocos pero alto valor)
-- - ~10-15% Churn mensual en Pro (alto para early-stage)
-- - Conversión Free→Pro: ~8-12% (típico en PLG)
-- =============================================================

-- ─────────────────────
-- PLANES (3 tiers)
-- ─────────────────────
INSERT INTO planes (nombre, precio_mensual, limite_minutos_mes, limite_ia_queries, limite_proyectos, soporte, descripcion) VALUES
('free', 0.00,  60,   10,   3,   'comunidad',  'Ideal para probar ScriptMind. 60 min de transcripción y 10 consultas IA al mes.'),
('pro',  19.00, 600,  200,  20,  'email',      'Para profesionales: 600 min/mes, 200 consultas IA, integraciones Notion y Slack.'),
('max',  49.00, NULL, NULL, NULL,'prioritario','Sin límites. API access, multi-workspace, soporte prioritario 24h, modelos IA avanzados.');


-- ─────────────────────────────
-- USUARIOS (65 usuarios, 6 cohortes)
-- ─────────────────────────────
-- Cohorte Enero (13 usuarios)
INSERT INTO usuarios (email, nombre, apellidos, plan_actual, canal_adquisicion, pais, empresa, fecha_registro, ultimo_login, activo, onboarding_completo) VALUES
('alex.morgan@gmail.com',       'Alex',     'Morgan',       'pro',     'product_hunt', 'US', NULL,              '2024-01-08 09:15:00', '2024-06-28 14:22:00', TRUE,  TRUE),
('sara.klein@freiberufler.de',  'Sara',     'Klein',        'max',     'google_ads',   'DE', 'Klein Consulting','2024-01-09 11:30:00', '2024-06-30 10:05:00', TRUE,  TRUE),
('jordi.puig@startup.cat',      'Jordi',    'Puig',         'pro',     'referido',     'ES', 'Launchpad BCN',   '2024-01-10 08:45:00', '2024-06-29 16:40:00', TRUE,  TRUE),
('mike.chen@podcastpro.io',     'Mike',     'Chen',         'max',     'product_hunt', 'US', 'PodcastPro',      '2024-01-11 14:00:00', '2024-06-30 09:15:00', TRUE,  TRUE),
('laura.vidal@gmail.com',       'Laura',    'Vidal',        'free',    'organico',     'ES', NULL,              '2024-01-12 10:20:00', '2024-04-15 11:00:00', TRUE,  FALSE),
('carlos.reyes@periodista.mx',  'Carlos',   'Reyes',        'churned', 'seo',          'MX', NULL,              '2024-01-13 16:30:00', '2024-03-10 09:00:00', FALSE, TRUE),
('anna.nkosi@journalist.za',    'Anna',     'Nkosi',        'pro',     'twitter',      'ZA', 'Daily Voice SA',  '2024-01-15 07:00:00', '2024-06-27 08:30:00', TRUE,  TRUE),
('tom.baker@consultancy.uk',    'Tom',      'Baker',        'max',     'linkedin_ads', 'GB', 'Baker & Co',      '2024-01-16 13:45:00', '2024-06-30 11:20:00', TRUE,  TRUE),
('isabella.romano@gmail.com',   'Isabella', 'Romano',       'free',    'organico',     'IT', NULL,              '2024-01-18 09:00:00', '2024-02-28 10:00:00', TRUE,  FALSE),
('david.lee@techfirm.sg',       'David',    'Lee',          'pro',     'google_ads',   'SG', 'TechFirm SG',     '2024-01-20 05:30:00', '2024-06-28 04:00:00', TRUE,  TRUE),
('marta.kowalski@agencia.pl',   'Marta',    'Kowalski',     'churned', 'seo',          'PL', NULL,              '2024-01-22 11:15:00', '2024-04-01 09:30:00', FALSE, TRUE),
('noah.williams@gmail.com',     'Noah',     'Williams',     'free',    'directo',      'AU', NULL,              '2024-01-25 23:00:00', '2024-06-10 22:00:00', TRUE,  TRUE),
('priya.sharma@edtech.in',      'Priya',    'Sharma',       'pro',     'product_hunt', 'IN', 'LearnFast India', '2024-01-28 06:00:00', '2024-06-30 05:45:00', TRUE,  TRUE),
-- Cohorte Febrero (12 usuarios)
('elena.petrov@gmail.com',      'Elena',    'Petrov',       'pro',     'referido',     'RU', NULL,              '2024-02-02 10:00:00', '2024-06-29 09:00:00', TRUE,  TRUE),
('samuel.osei@media.gh',        'Samuel',   'Osei',         'free',    'twitter',      'GH', 'Accra Media',     '2024-02-05 08:30:00', '2024-05-20 07:00:00', TRUE,  FALSE),
('claire.dupont@freelance.fr',  'Claire',   'Dupont',       'max',     'google_ads',   'FR', NULL,              '2024-02-06 14:00:00', '2024-06-30 13:45:00', TRUE,  TRUE),
('javier.herrera@agencia.es',   'Javier',   'Herrera',      'pro',     'linkedin_ads', 'ES', 'Herrera Digital', '2024-02-08 09:30:00', '2024-06-28 10:00:00', TRUE,  TRUE),
('yuki.tanaka@podcast.jp',      'Yuki',     'Tanaka',       'pro',     'product_hunt', 'JP', NULL,              '2024-02-10 02:00:00', '2024-06-30 01:30:00', TRUE,  TRUE),
('amy.roberts@freelance.ca',    'Amy',      'Roberts',      'churned', 'seo',          'CA', NULL,              '2024-02-12 16:00:00', '2024-05-15 15:00:00', FALSE, TRUE),
('omar.hassan@startup.ae',      'Omar',     'Hassan',       'max',     'directo',      'AE', 'GulfTech',        '2024-02-14 11:00:00', '2024-06-29 10:00:00', TRUE,  TRUE),
('sofia.berg@media.se',         'Sofia',    'Berg',         'free',    'organico',     'SE', NULL,              '2024-02-16 15:30:00', '2024-06-15 14:00:00', TRUE,  FALSE),
('marcus.jensen@podcast.dk',    'Marcus',   'Jensen',       'pro',     'referido',     'DK', NULL,              '2024-02-18 10:00:00', '2024-06-28 09:30:00', TRUE,  TRUE),
('ines.almeida@jornalista.pt',  'Inês',     'Almeida',      'free',    'seo',          'PT', NULL,              '2024-02-20 09:00:00', '2024-04-10 08:00:00', TRUE,  FALSE),
('ryan.oconnor@podcast.ie',     'Ryan',     'O''Connor',    'churned', 'twitter',      'IE', NULL,              '2024-02-22 17:00:00', '2024-04-30 16:00:00', FALSE, TRUE),
('fatima.malik@research.pk',    'Fatima',   'Malik',        'pro',     'seo',          'PK', 'Lahore Univ.',    '2024-02-25 05:00:00', '2024-06-29 04:30:00', TRUE,  TRUE),
-- Cohorte Marzo (12 usuarios)
('lucas.mendez@startup.ar',     'Lucas',    'Méndez',       'pro',     'product_hunt', 'AR', 'Startup BA',      '2024-03-01 13:00:00', '2024-06-30 12:00:00', TRUE,  TRUE),
('nina.fischer@agentur.de',     'Nina',     'Fischer',      'max',     'linkedin_ads', 'DE', 'Fischer Medien',  '2024-03-04 09:00:00', '2024-06-30 08:30:00', TRUE,  TRUE),
('james.wilson@podcast.us',     'James',    'Wilson',       'pro',     'google_ads',   'US', NULL,              '2024-03-06 14:30:00', '2024-06-29 13:00:00', TRUE,  TRUE),
('amara.diop@media.sn',         'Amara',    'Diop',         'free',    'twitter',      'SN', NULL,              '2024-03-08 11:00:00', '2024-05-30 10:00:00', TRUE,  FALSE),
('henrik.larsson@consultant.se','Henrik',   'Larsson',      'churned', 'seo',          'SE', NULL,              '2024-03-10 08:00:00', '2024-05-20 07:30:00', FALSE, TRUE),
('camille.martin@freelance.fr', 'Camille',  'Martin',       'pro',     'referido',     'FR', NULL,              '2024-03-12 10:00:00', '2024-06-28 09:00:00', TRUE,  TRUE),
('aiden.murphy@podcast.ie',     'Aiden',    'Murphy',       'free',    'organico',     'IE', NULL,              '2024-03-14 16:00:00', '2024-06-20 15:00:00', TRUE,  FALSE),
('valentina.cruz@media.co',     'Valentina','Cruz',         'pro',     'google_ads',   'CO', 'MediaCo Bogotá',  '2024-03-16 18:00:00', '2024-06-30 17:00:00', TRUE,  TRUE),
('elias.korhonen@yle.fi',       'Elias',    'Korhonen',     'free',    'seo',          'FI', NULL,              '2024-03-18 08:00:00', '2024-04-05 07:30:00', TRUE,  FALSE),
('zoe.anderson@research.nz',    'Zoe',      'Anderson',     'max',     'directo',      'NZ', 'AUT University',  '2024-03-20 22:00:00', '2024-06-29 21:00:00', TRUE,  TRUE),
('rafael.souza@podcast.br',     'Rafael',   'Souza',        'pro',     'twitter',      'BR', NULL,              '2024-03-22 15:00:00', '2024-06-28 14:00:00', TRUE,  TRUE),
('hana.novak@media.cz',         'Hana',     'Novák',        'free',    'seo',          'CZ', NULL,              '2024-03-25 10:00:00', '2024-06-10 09:00:00', TRUE,  FALSE),
-- Cohorte Abril (10 usuarios)
('liam.scott@agency.us',        'Liam',     'Scott',        'pro',     'google_ads',   'US', 'Scott Digital',   '2024-04-02 09:00:00', '2024-06-30 08:00:00', TRUE,  TRUE),
('giulia.ferrari@radio.it',     'Giulia',   'Ferrari',      'max',     'linkedin_ads', 'IT', 'RAI Digital',     '2024-04-05 10:00:00', '2024-06-30 09:15:00', TRUE,  TRUE),
('ben.nguyen@startup.vn',       'Ben',      'Nguyen',       'free',    'seo',          'VN', NULL,              '2024-04-08 04:00:00', '2024-06-25 03:30:00', TRUE,  FALSE),
('astrid.holm@media.no',        'Astrid',   'Holm',         'pro',     'referido',     'NO', 'NRK Podcast',     '2024-04-10 09:00:00', '2024-06-29 08:00:00', TRUE,  TRUE),
('kai.weber@journalist.de',     'Kai',      'Weber',        'churned', 'organico',     'DE', NULL,              '2024-04-12 11:00:00', '2024-06-10 10:30:00', FALSE, TRUE),
('lucia.santos@freelance.es',   'Lucía',    'Santos',       'free',    'twitter',      'ES', NULL,              '2024-04-15 12:00:00', '2024-06-28 11:00:00', TRUE,  FALSE),
('chen.wei@podcast.cn',         'Chen',     'Wei',          'pro',     'directo',      'CN', 'Tencent Audio',   '2024-04-18 03:00:00', '2024-06-30 02:30:00', TRUE,  TRUE),
('nadia.brown@media.ca',        'Nadia',    'Brown',        'free',    'seo',          'CA', NULL,              '2024-04-20 14:00:00', '2024-06-15 13:00:00', TRUE,  FALSE),
('felix.hoffman@startup.de',    'Felix',    'Hoffmann',     'max',     'google_ads',   'DE', 'HoffTech GmbH',   '2024-04-23 09:00:00', '2024-06-30 08:45:00', TRUE,  TRUE),
('isabel.vargas@periodismo.mx', 'Isabel',   'Vargas',       'pro',     'product_hunt', 'MX', NULL,              '2024-04-26 16:00:00', '2024-06-29 15:30:00', TRUE,  TRUE),
-- Cohorte Mayo (10 usuarios)
('oliver.jones@podcast.uk',     'Oliver',   'Jones',        'pro',     'google_ads',   'GB', NULL,              '2024-05-03 10:00:00', '2024-06-30 09:00:00', TRUE,  TRUE),
('amelia.white@researcher.au',  'Amelia',   'White',        'free',    'seo',          'AU', 'Monash Uni',      '2024-05-07 22:00:00', '2024-06-20 21:00:00', TRUE,  FALSE),
('hugo.lambert@media.be',       'Hugo',     'Lambert',      'pro',     'linkedin_ads', 'BE', 'RTBF Digital',    '2024-05-10 09:00:00', '2024-06-29 08:30:00', TRUE,  TRUE),
('min.ji.kim@startup.kr',       'Min-Ji',   'Kim',          'max',     'directo',      'KR', 'KMedia Corp',     '2024-05-12 01:00:00', '2024-06-30 00:30:00', TRUE,  TRUE),
('elena.garcia@freelance.es',   'Elena',    'García',       'free',    'organico',     'ES', NULL,              '2024-05-15 11:00:00', '2024-06-25 10:00:00', TRUE,  FALSE),
('derek.hall@agency.us',        'Derek',    'Hall',         'pro',     'referido',     'US', 'Hall Media',      '2024-05-18 14:00:00', '2024-06-30 13:00:00', TRUE,  TRUE),
('ana.ruiz@journalism.es',      'Ana',      'Ruiz',         'free',    'seo',          'ES', NULL,              '2024-05-20 09:00:00', '2024-06-28 08:00:00', TRUE,  TRUE),
('matteo.ricci@startup.it',     'Matteo',   'Ricci',        'churned', 'twitter',      'IT', NULL,              '2024-05-22 10:00:00', '2024-06-20 09:00:00', FALSE, TRUE),
('sarah.obi@media.ng',          'Sarah',    'Obi',          'free',    'twitter',      'NG', 'Lagos Today',     '2024-05-25 08:00:00', '2024-06-29 07:00:00', TRUE,  FALSE),
('peter.novak@podcast.sk',      'Peter',    'Novák',        'pro',     'google_ads',   'SK', NULL,              '2024-05-28 10:00:00', '2024-06-30 09:30:00', TRUE,  TRUE),
-- Cohorte Junio (8 usuarios — más recientes, casi todos free)
('nour.ibrahim@media.eg',       'Nour',     'Ibrahim',      'free',    'seo',          'EG', NULL,              '2024-06-02 09:00:00', '2024-06-29 08:00:00', TRUE,  FALSE),
('sophie.williams@podcast.nz',  'Sophie',   'Williams',     'pro',     'product_hunt', 'NZ', NULL,              '2024-06-05 22:00:00', '2024-06-30 21:00:00', TRUE,  TRUE),
('andrés.torres@freelance.cl',  'Andrés',   'Torres',       'free',    'organico',     'CL', NULL,              '2024-06-08 14:00:00', '2024-06-28 13:00:00', TRUE,  FALSE),
('lisa.chen@agency.tw',         'Lisa',     'Chen',         'pro',     'google_ads',   'TW', 'TW Digital',      '2024-06-10 03:00:00', '2024-06-30 02:00:00', TRUE,  TRUE),
('marco.bianchi@media.ch',      'Marco',    'Bianchi',      'free',    'twitter',      'CH', NULL,              '2024-06-12 10:00:00', '2024-06-29 09:00:00', TRUE,  FALSE),
('aisha.kone@media.ml',         'Aisha',    'Koné',         'free',    'seo',          'ML', NULL,              '2024-06-15 07:00:00', '2024-06-28 06:00:00', TRUE,  FALSE),
('thomas.andersen@startup.dk',  'Thomas',   'Andersen',     'free',    'organico',     'DK', NULL,              '2024-06-18 09:00:00', '2024-06-30 08:00:00', TRUE,  FALSE),
('rina.yamamoto@media.jp',      'Rina',     'Yamamoto',     'pro',     'linkedin_ads', 'JP', 'NHK Digital',     '2024-06-20 02:00:00', '2024-06-30 01:30:00', TRUE,  TRUE);


-- ─────────────────────────────────────
-- SUSCRIPCIONES (historial completo)
-- plan_id: 1=free, 2=pro, 3=max
-- ─────────────────────────────────────
INSERT INTO suscripciones (usuario_id, plan_id, fecha_inicio, fecha_fin, estado, precio_efectivo, origen_cambio) VALUES
-- COHORTE ENERO
-- Alex Morgan: Free → Pro día 15 enero
(1,  1, '2024-01-08', '2024-01-15', 'upgradeada',  0.00, 'registro'),
(1,  2, '2024-01-15', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Sara Klein: Max desde el inicio (cliente de alto valor)
(2,  3, '2024-01-09', NULL,         'activa',      49.00, 'registro'),
-- Jordi Puig: Free → Pro
(3,  1, '2024-01-10', '2024-01-20', 'upgradeada',  0.00, 'registro'),
(3,  2, '2024-01-20', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Mike Chen: Max desde inicio
(4,  3, '2024-01-11', NULL,         'activa',      49.00, 'registro'),
-- Laura Vidal: sigue Free
(5,  1, '2024-01-12', NULL,         'activa',       0.00, 'registro'),
-- Carlos Reyes: Free → Pro → Churn
(6,  1, '2024-01-13', '2024-01-25', 'upgradeada',  0.00, 'registro'),
(6,  2, '2024-01-25', '2024-03-25', 'cancelada',   19.00, 'upgrade_voluntario'),
-- Anna Nkosi: Free → Pro
(7,  1, '2024-01-15', '2024-01-22', 'upgradeada',  0.00, 'registro'),
(7,  2, '2024-01-22', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Tom Baker: Max desde inicio
(8,  3, '2024-01-16', NULL,         'activa',      49.00, 'registro'),
-- Isabella Romano: Free (uso mínimo)
(9,  1, '2024-01-18', NULL,         'activa',       0.00, 'registro'),
-- David Lee: Free → Pro
(10, 1, '2024-01-20', '2024-02-01', 'upgradeada',  0.00, 'registro'),
(10, 2, '2024-02-01', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Marta Kowalski: Free → Pro → Churn en abril
(11, 1, '2024-01-22', '2024-02-05', 'upgradeada',  0.00, 'registro'),
(11, 2, '2024-02-05', '2024-04-05', 'cancelada',   19.00, 'upgrade_voluntario'),
-- Noah Williams: sigue Free
(12, 1, '2024-01-25', NULL,         'activa',       0.00, 'registro'),
-- Priya Sharma: Free → Pro
(13, 1, '2024-01-28', '2024-02-10', 'upgradeada',  0.00, 'registro'),
(13, 2, '2024-02-10', NULL,         'activa',      19.00, 'upgrade_voluntario'),

-- COHORTE FEBRERO
-- Elena Petrov: Pro directo
(14, 1, '2024-02-02', '2024-02-12', 'upgradeada',  0.00, 'registro'),
(14, 2, '2024-02-12', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Samuel Osei: Free
(15, 1, '2024-02-05', NULL,         'activa',       0.00, 'registro'),
-- Claire Dupont: Max con descuento de lanzamiento
(16, 3, '2024-02-06', NULL,         'activa',      39.00, 'upgrade_oferta'),  -- 20% dto
-- Javier Herrera: Pro → Max upgrade en mayo
(17, 1, '2024-02-08', '2024-02-15', 'upgradeada',  0.00, 'registro'),
(17, 2, '2024-02-15', '2024-05-15', 'upgradeada',  19.00, 'upgrade_voluntario'),
(17, 3, '2024-05-15', NULL,         'activa',      49.00, 'upgrade_voluntario'),
-- Yuki Tanaka: Pro
(18, 1, '2024-02-10', '2024-02-20', 'upgradeada',  0.00, 'registro'),
(18, 2, '2024-02-20', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Amy Roberts: Free → Pro → Churn en mayo
(19, 1, '2024-02-12', '2024-02-28', 'upgradeada',  0.00, 'registro'),
(19, 2, '2024-02-28', '2024-05-28', 'cancelada',   19.00, 'upgrade_voluntario'),
-- Omar Hassan: Max desde inicio
(20, 3, '2024-02-14', NULL,         'activa',      49.00, 'registro'),
-- Sofia Berg: Free
(21, 1, '2024-02-16', NULL,         'activa',       0.00, 'registro'),
-- Marcus Jensen: Pro
(22, 1, '2024-02-18', '2024-03-01', 'upgradeada',  0.00, 'registro'),
(22, 2, '2024-03-01', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Inês Almeida: Free
(23, 1, '2024-02-20', NULL,         'activa',       0.00, 'registro'),
-- Ryan O'Connor: Pro → Churn en abril
(24, 1, '2024-02-22', '2024-03-05', 'upgradeada',  0.00, 'registro'),
(24, 2, '2024-03-05', '2024-04-30', 'cancelada',   19.00, 'upgrade_voluntario'),
-- Fatima Malik: Pro
(25, 1, '2024-02-25', '2024-03-05', 'upgradeada',  0.00, 'registro'),
(25, 2, '2024-03-05', NULL,         'activa',      19.00, 'upgrade_voluntario'),

-- COHORTE MARZO
-- Lucas Méndez: Pro
(26, 1, '2024-03-01', '2024-03-10', 'upgradeada',  0.00, 'registro'),
(26, 2, '2024-03-10', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Nina Fischer: Max
(27, 3, '2024-03-04', NULL,         'activa',      49.00, 'registro'),
-- James Wilson: Pro
(28, 1, '2024-03-06', '2024-03-15', 'upgradeada',  0.00, 'registro'),
(28, 2, '2024-03-15', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Amara Diop: Free
(29, 1, '2024-03-08', NULL,         'activa',       0.00, 'registro'),
-- Henrik Larsson: Pro → Churn en mayo
(30, 1, '2024-03-10', '2024-03-20', 'upgradeada',  0.00, 'registro'),
(30, 2, '2024-03-20', '2024-05-20', 'cancelada',   19.00, 'upgrade_voluntario'),
-- Camille Martin: Pro
(31, 1, '2024-03-12', '2024-03-22', 'upgradeada',  0.00, 'registro'),
(31, 2, '2024-03-22', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Aiden Murphy: Free
(32, 1, '2024-03-14', NULL,         'activa',       0.00, 'registro'),
-- Valentina Cruz: Pro
(33, 1, '2024-03-16', '2024-03-28', 'upgradeada',  0.00, 'registro'),
(33, 2, '2024-03-28', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Elias Korhonen: Free
(34, 1, '2024-03-18', NULL,         'activa',       0.00, 'registro'),
-- Zoe Anderson: Max
(35, 3, '2024-03-20', NULL,         'activa',      49.00, 'registro'),
-- Rafael Souza: Pro
(36, 1, '2024-03-22', '2024-04-01', 'upgradeada',  0.00, 'registro'),
(36, 2, '2024-04-01', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Hana Novák: Free
(37, 1, '2024-03-25', NULL,         'activa',       0.00, 'registro'),

-- COHORTE ABRIL
-- Liam Scott: Pro desde inicio (vía paid)
(38, 1, '2024-04-02', '2024-04-05', 'upgradeada',  0.00, 'registro'),
(38, 2, '2024-04-05', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Giulia Ferrari: Max
(39, 3, '2024-04-05', NULL,         'activa',      49.00, 'registro'),
-- Ben Nguyen: Free
(40, 1, '2024-04-08', NULL,         'activa',       0.00, 'registro'),
-- Astrid Holm: Pro
(41, 1, '2024-04-10', '2024-04-18', 'upgradeada',  0.00, 'registro'),
(41, 2, '2024-04-18', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Kai Weber: Free → Pro → Churn en junio
(42, 1, '2024-04-12', '2024-04-25', 'upgradeada',  0.00, 'registro'),
(42, 2, '2024-04-25', '2024-06-15', 'cancelada',   19.00, 'upgrade_voluntario'),
-- Lucía Santos: Free
(43, 1, '2024-04-15', NULL,         'activa',       0.00, 'registro'),
-- Chen Wei: Pro
(44, 1, '2024-04-18', '2024-04-28', 'upgradeada',  0.00, 'registro'),
(44, 2, '2024-04-28', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Nadia Brown: Free
(45, 1, '2024-04-20', NULL,         'activa',       0.00, 'registro'),
-- Felix Hoffmann: Max
(46, 3, '2024-04-23', NULL,         'activa',      49.00, 'registro'),
-- Isabel Vargas: Pro
(47, 1, '2024-04-26', '2024-05-05', 'upgradeada',  0.00, 'registro'),
(47, 2, '2024-05-05', NULL,         'activa',      19.00, 'upgrade_voluntario'),

-- COHORTE MAYO
-- Oliver Jones: Pro
(48, 1, '2024-05-03', '2024-05-10', 'upgradeada',  0.00, 'registro'),
(48, 2, '2024-05-10', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Amelia White: Free
(49, 1, '2024-05-07', NULL,         'activa',       0.00, 'registro'),
-- Hugo Lambert: Pro
(50, 1, '2024-05-10', '2024-05-18', 'upgradeada',  0.00, 'registro'),
(50, 2, '2024-05-18', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Min-Ji Kim: Max
(51, 3, '2024-05-12', NULL,         'activa',      49.00, 'registro'),
-- Elena García: Free
(52, 1, '2024-05-15', NULL,         'activa',       0.00, 'registro'),
-- Derek Hall: Pro
(53, 1, '2024-05-18', '2024-05-25', 'upgradeada',  0.00, 'registro'),
(53, 2, '2024-05-25', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Ana Ruiz: Free (power user free — buena candidata conversión)
(54, 1, '2024-05-20', NULL,         'activa',       0.00, 'registro'),
-- Matteo Ricci: Pro → Churn en junio
(55, 1, '2024-05-22', '2024-05-28', 'upgradeada',  0.00, 'registro'),
(55, 2, '2024-05-28', '2024-06-25', 'cancelada',   19.00, 'upgrade_voluntario'),
-- Sarah Obi: Free
(56, 1, '2024-05-25', NULL,         'activa',       0.00, 'registro'),
-- Peter Novák: Pro
(57, 1, '2024-05-28', '2024-06-05', 'upgradeada',  0.00, 'registro'),
(57, 2, '2024-06-05', NULL,         'activa',      19.00, 'upgrade_voluntario'),

-- COHORTE JUNIO
-- Nour Ibrahim: Free
(58, 1, '2024-06-02', NULL,         'activa',       0.00, 'registro'),
-- Sophie Williams: Pro rápido (vía Product Hunt)
(59, 1, '2024-06-05', '2024-06-08', 'upgradeada',  0.00, 'registro'),
(59, 2, '2024-06-08', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Andrés Torres: Free
(60, 1, '2024-06-08', NULL,         'activa',       0.00, 'registro'),
-- Lisa Chen: Pro
(61, 1, '2024-06-10', '2024-06-15', 'upgradeada',  0.00, 'registro'),
(61, 2, '2024-06-15', NULL,         'activa',      19.00, 'upgrade_voluntario'),
-- Marco Bianchi, Aisha Koné, Thomas Andersen: Free recientes
(62, 1, '2024-06-12', NULL,         'activa',       0.00, 'registro'),
(63, 1, '2024-06-15', NULL,         'activa',       0.00, 'registro'),
(64, 1, '2024-06-18', NULL,         'activa',       0.00, 'registro'),
-- Rina Yamamoto: Pro
(65, 1, '2024-06-20', '2024-06-22', 'upgradeada',  0.00, 'registro'),
(65, 2, '2024-06-22', NULL,         'activa',      19.00, 'upgrade_voluntario');


-- ─────────────────────────────────────
-- PAGOS (cobros mensuales reales)
-- Solo usuarios Pro y Max generan pagos
-- ─────────────────────────────────────
INSERT INTO pagos (usuario_id, suscripcion_id, fecha_pago, importe, periodo_facturado, metodo_pago, estado, referencia_stripe) VALUES
-- ===== ENERO 2024 =====
-- Pro (conversiones a Pro en enero)
(1,  2,  '2024-01-15', 19.00, '2024-01', 'stripe',  'completado', 'pi_jan_001'),
(3,  4,  '2024-01-20', 19.00, '2024-01', 'tarjeta', 'completado', 'pi_jan_002'),
(7,  10, '2024-01-22', 19.00, '2024-01', 'stripe',  'completado', 'pi_jan_003'),
(6,  8,  '2024-01-25', 19.00, '2024-01', 'stripe',  'completado', 'pi_jan_004'), -- churneará
-- Max (desde inicio enero)
(2,  2,  '2024-01-09', 49.00, '2024-01', 'tarjeta', 'completado', 'pi_jan_005'),
(4,  4,  '2024-01-11', 49.00, '2024-01', 'tarjeta', 'completado', 'pi_jan_006'),
(8,  10, '2024-01-16', 49.00, '2024-01', 'paypal',  'completado', 'pi_jan_007'),

-- ===== FEBRERO 2024 =====
-- Pro renovaciones enero → feb
(1,  2,  '2024-02-15', 19.00, '2024-02', 'stripe',  'completado', 'pi_feb_001'),
(3,  4,  '2024-02-20', 19.00, '2024-02', 'tarjeta', 'completado', 'pi_feb_002'),
(7,  10, '2024-02-22', 19.00, '2024-02', 'stripe',  'completado', 'pi_feb_003'),
(6,  8,  '2024-02-25', 19.00, '2024-02', 'stripe',  'completado', 'pi_feb_004'), -- mes 2 del que churnea
-- Pro nuevos febrero
(11, 15, '2024-02-05', 19.00, '2024-02', 'tarjeta', 'completado', 'pi_feb_005'), -- Marta Kowalski
(10, 12, '2024-02-01', 19.00, '2024-02', 'stripe',  'completado', 'pi_feb_006'), -- David Lee
(13, 17, '2024-02-10', 19.00, '2024-02', 'stripe',  'completado', 'pi_feb_007'), -- Priya Sharma
(14, 19, '2024-02-12', 19.00, '2024-02', 'tarjeta', 'completado', 'pi_feb_008'), -- Elena Petrov
(18, 28, '2024-02-20', 19.00, '2024-02', 'stripe',  'completado', 'pi_feb_009'), -- Yuki Tanaka
(19, 30, '2024-02-28', 19.00, '2024-02', 'stripe',  'completado', 'pi_feb_010'), -- Amy Roberts
-- Max renovaciones + nuevos feb
(2,  2,  '2024-02-09', 49.00, '2024-02', 'tarjeta', 'completado', 'pi_feb_011'),
(4,  4,  '2024-02-11', 49.00, '2024-02', 'tarjeta', 'completado', 'pi_feb_012'),
(8,  10, '2024-02-16', 49.00, '2024-02', 'paypal',  'completado', 'pi_feb_013'),
(16, 22, '2024-02-06', 39.00, '2024-02', 'stripe',  'completado', 'pi_feb_014'), -- Claire Dupont dto
(20, 26, '2024-02-14', 49.00, '2024-02', 'tarjeta', 'completado', 'pi_feb_015'), -- Omar Hassan

-- ===== MARZO 2024 =====
-- Pro renovaciones
(1,  2,  '2024-03-15', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_001'),
(3,  4,  '2024-03-20', 19.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_002'),
(7,  10, '2024-03-22', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_003'),
(10, 12, '2024-03-01', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_004'),
(11, 15, '2024-03-05', 19.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_005'), -- último mes Marta
(13, 17, '2024-03-10', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_006'),
(14, 19, '2024-03-12', 19.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_007'),
(18, 28, '2024-03-20', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_008'),
(19, 30, '2024-03-28', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_009'), -- mes 2 Amy
(22, 32, '2024-03-01', 19.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_010'), -- Marcus Jensen
(24, 35, '2024-03-05', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_011'), -- Ryan O'Connor
(25, 37, '2024-03-05', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_012'), -- Fatima Malik
-- Pro nuevos marzo
(26, 39, '2024-03-10', 19.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_013'), -- Lucas Méndez
(28, 43, '2024-03-15', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_014'), -- James Wilson
(30, 47, '2024-03-20', 19.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_015'), -- Henrik Larsson
(31, 49, '2024-03-22', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_016'), -- Camille Martin
(33, 52, '2024-03-28', 19.00, '2024-03', 'stripe',  'completado', 'pi_mar_017'), -- Valentina Cruz
-- Max renovaciones + nuevos marzo
(2,  2,  '2024-03-09', 49.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_018'),
(4,  4,  '2024-03-11', 49.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_019'),
(8,  10, '2024-03-16', 49.00, '2024-03', 'paypal',  'completado', 'pi_mar_020'),
(16, 22, '2024-03-06', 39.00, '2024-03', 'stripe',  'completado', 'pi_mar_021'),
(20, 26, '2024-03-14', 49.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_022'),
(27, 41, '2024-03-04', 49.00, '2024-03', 'tarjeta', 'completado', 'pi_mar_023'), -- Nina Fischer
(35, 55, '2024-03-20', 49.00, '2024-03', 'stripe',  'completado', 'pi_mar_024'), -- Zoe Anderson

-- ===== ABRIL 2024 =====
-- Pro renovaciones
(1,  2,  '2024-04-15', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_001'),
(3,  4,  '2024-04-20', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_002'),
(7,  10, '2024-04-22', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_003'),
(10, 12, '2024-04-01', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_004'),
(13, 17, '2024-04-10', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_005'),
(14, 19, '2024-04-12', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_006'),
(17, 24, '2024-04-15', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_007'), -- Javier Herrera
(18, 28, '2024-04-20', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_008'),
(19, 30, '2024-04-28', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_009'), -- último mes Amy
(22, 32, '2024-04-01', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_010'),
(24, 35, '2024-04-05', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_011'), -- último mes Ryan
(25, 37, '2024-04-05', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_012'),
(26, 39, '2024-04-10', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_013'),
(28, 43, '2024-04-15', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_014'),
(30, 47, '2024-04-20', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_015'),
(31, 49, '2024-04-22', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_016'),
(33, 52, '2024-04-28', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_017'),
(36, 56, '2024-04-01', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_018'), -- Rafael Souza
-- Pro nuevos abril
(38, 59, '2024-04-05', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_019'), -- Liam Scott
(41, 63, '2024-04-18', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_020'), -- Astrid Holm
(42, 65, '2024-04-25', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_021'), -- Kai Weber
(44, 68, '2024-04-28', 19.00, '2024-04', 'stripe',  'completado', 'pi_apr_022'), -- Chen Wei
(47, 72, '2024-05-05', 19.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_023'), -- Isabel Vargas
-- Max renovaciones + nuevos
(2,  2,  '2024-04-09', 49.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_024'),
(4,  4,  '2024-04-11', 49.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_025'),
(8,  10, '2024-04-16', 49.00, '2024-04', 'paypal',  'completado', 'pi_apr_026'),
(16, 22, '2024-04-06', 39.00, '2024-04', 'stripe',  'completado', 'pi_apr_027'),
(20, 26, '2024-04-14', 49.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_028'),
(27, 41, '2024-04-04', 49.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_029'),
(35, 55, '2024-04-20', 49.00, '2024-04', 'stripe',  'completado', 'pi_apr_030'),
(39, 61, '2024-04-05', 49.00, '2024-04', 'stripe',  'completado', 'pi_apr_031'), -- Giulia Ferrari
(46, 70, '2024-04-23', 49.00, '2024-04', 'tarjeta', 'completado', 'pi_apr_032'), -- Felix Hoffmann

-- ===== MAYO 2024 =====
-- (resumen compacto para no exceder líneas)
(1,2,'2024-05-15',19.00,'2024-05','stripe','completado','pi_may_001'),
(3,4,'2024-05-20',19.00,'2024-05','tarjeta','completado','pi_may_002'),
(7,10,'2024-05-22',19.00,'2024-05','stripe','completado','pi_may_003'),
(10,12,'2024-05-01',19.00,'2024-05','stripe','completado','pi_may_004'),
(13,17,'2024-05-10',19.00,'2024-05','stripe','completado','pi_may_005'),
(14,19,'2024-05-12',19.00,'2024-05','tarjeta','completado','pi_may_006'),
(17,24,'2024-05-15',19.00,'2024-05','stripe','completado','pi_may_007'), -- último mes Pro Javier antes de Max
(18,28,'2024-05-20',19.00,'2024-05','stripe','completado','pi_may_008'),
(22,32,'2024-05-01',19.00,'2024-05','tarjeta','completado','pi_may_009'),
(25,37,'2024-05-05',19.00,'2024-05','stripe','completado','pi_may_010'),
(26,39,'2024-05-10',19.00,'2024-05','tarjeta','completado','pi_may_011'),
(28,43,'2024-05-15',19.00,'2024-05','stripe','completado','pi_may_012'),
(30,47,'2024-05-20',19.00,'2024-05','tarjeta','completado','pi_may_013'), -- último mes Henrik
(31,49,'2024-05-22',19.00,'2024-05','stripe','completado','pi_may_014'),
(33,52,'2024-05-28',19.00,'2024-05','stripe','completado','pi_may_015'),
(36,56,'2024-05-01',19.00,'2024-05','stripe','completado','pi_may_016'),
(38,59,'2024-05-05',19.00,'2024-05','tarjeta','completado','pi_may_017'),
(41,63,'2024-05-18',19.00,'2024-05','tarjeta','completado','pi_may_018'),
(42,65,'2024-05-25',19.00,'2024-05','stripe','completado','pi_may_019'),
(44,68,'2024-05-28',19.00,'2024-05','stripe','completado','pi_may_020'),
(47,72,'2024-05-05',19.00,'2024-05','tarjeta','completado','pi_may_021'),
-- Nuevos Pro mayo
(48,74,'2024-05-10',19.00,'2024-05','stripe','completado','pi_may_022'), -- Oliver Jones
(50,77,'2024-05-18',19.00,'2024-05','stripe','completado','pi_may_023'), -- Hugo Lambert
(53,82,'2024-05-25',19.00,'2024-05','tarjeta','completado','pi_may_024'), -- Derek Hall
(55,85,'2024-05-28',19.00,'2024-05','stripe','completado','pi_may_025'), -- Matteo Ricci
-- Pro → Max upgrade Javier
(17,26,'2024-05-15',49.00,'2024-05','stripe','completado','pi_may_026'),
-- Max renovaciones + nuevos
(2,2,'2024-05-09',49.00,'2024-05','tarjeta','completado','pi_may_027'),
(4,4,'2024-05-11',49.00,'2024-05','tarjeta','completado','pi_may_028'),
(8,10,'2024-05-16',49.00,'2024-05','paypal','completado','pi_may_029'),
(16,22,'2024-05-06',39.00,'2024-05','stripe','completado','pi_may_030'),
(20,26,'2024-05-14',49.00,'2024-05','tarjeta','completado','pi_may_031'),
(27,41,'2024-05-04',49.00,'2024-05','tarjeta','completado','pi_may_032'),
(35,55,'2024-05-20',49.00,'2024-05','stripe','completado','pi_may_033'),
(39,61,'2024-05-05',49.00,'2024-05','stripe','completado','pi_may_034'),
(46,70,'2024-05-23',49.00,'2024-05','tarjeta','completado','pi_may_035'),
(51,79,'2024-05-12',49.00,'2024-05','tarjeta','completado','pi_may_036'), -- Min-Ji Kim

-- ===== JUNIO 2024 =====
(1,2,'2024-06-15',19.00,'2024-06','stripe','completado','pi_jun_001'),
(3,4,'2024-06-20',19.00,'2024-06','tarjeta','completado','pi_jun_002'),
(7,10,'2024-06-22',19.00,'2024-06','stripe','completado','pi_jun_003'),
(10,12,'2024-06-01',19.00,'2024-06','stripe','completado','pi_jun_004'),
(13,17,'2024-06-10',19.00,'2024-06','stripe','completado','pi_jun_005'),
(14,19,'2024-06-12',19.00,'2024-06','tarjeta','completado','pi_jun_006'),
(17,26,'2024-06-15',49.00,'2024-06','stripe','completado','pi_jun_007'), -- Javier ya en Max
(18,28,'2024-06-20',19.00,'2024-06','stripe','completado','pi_jun_008'),
(22,32,'2024-06-01',19.00,'2024-06','tarjeta','completado','pi_jun_009'),
(25,37,'2024-06-05',19.00,'2024-06','stripe','completado','pi_jun_010'),
(26,39,'2024-06-10',19.00,'2024-06','tarjeta','completado','pi_jun_011'),
(28,43,'2024-06-15',19.00,'2024-06','stripe','completado','pi_jun_012'),
(31,49,'2024-06-22',19.00,'2024-06','stripe','completado','pi_jun_013'),
(33,52,'2024-06-28',19.00,'2024-06','stripe','completado','pi_jun_014'),
(36,56,'2024-06-01',19.00,'2024-06','stripe','completado','pi_jun_015'),
(38,59,'2024-06-05',19.00,'2024-06','tarjeta','completado','pi_jun_016'),
(41,63,'2024-06-18',19.00,'2024-06','tarjeta','completado','pi_jun_017'),
(44,68,'2024-06-28',19.00,'2024-06','stripe','completado','pi_jun_018'),
(47,72,'2024-06-05',19.00,'2024-06','tarjeta','completado','pi_jun_019'),
(48,74,'2024-06-10',19.00,'2024-06','stripe','completado','pi_jun_020'),
(50,77,'2024-06-18',19.00,'2024-06','stripe','completado','pi_jun_021'),
(53,82,'2024-06-25',19.00,'2024-06','tarjeta','completado','pi_jun_022'),
-- Pro nuevos junio
(57,88,'2024-06-05',19.00,'2024-06','stripe','completado','pi_jun_023'), -- Peter Novák
(59,91,'2024-06-08',19.00,'2024-06','stripe','completado','pi_jun_024'), -- Sophie Williams
(61,94,'2024-06-15',19.00,'2024-06','tarjeta','completado','pi_jun_025'), -- Lisa Chen
(65,97,'2024-06-22',19.00,'2024-06','stripe','completado','pi_jun_026'), -- Rina Yamamoto
-- Max renovaciones
(2,2,'2024-06-09',49.00,'2024-06','tarjeta','completado','pi_jun_027'),
(4,4,'2024-06-11',49.00,'2024-06','tarjeta','completado','pi_jun_028'),
(8,10,'2024-06-16',49.00,'2024-06','paypal','completado','pi_jun_029'),
(16,22,'2024-06-06',39.00,'2024-06','stripe','completado','pi_jun_030'),
(20,26,'2024-06-14',49.00,'2024-06','tarjeta','completado','pi_jun_031'),
(27,41,'2024-06-04',49.00,'2024-06','tarjeta','completado','pi_jun_032'),
(35,55,'2024-06-20',49.00,'2024-06','stripe','completado','pi_jun_033'),
(39,61,'2024-06-05',49.00,'2024-06','stripe','completado','pi_jun_034'),
(46,70,'2024-06-23',49.00,'2024-06','tarjeta','completado','pi_jun_035'),
(51,79,'2024-06-12',49.00,'2024-06','tarjeta','completado','pi_jun_036');


-- ─────────────────────────────────────
-- CANCELACIONES (9 churns registrados)
-- ─────────────────────────────────────
INSERT INTO cancelaciones (usuario_id, suscripcion_id, fecha_cancelacion, plan_cancelado, motivo_categoria, motivo_detalle, nps_salida, fue_retenible, reactivo) VALUES
(6,  8,  '2024-03-25', 'pro', 'poco_uso',
 'Empecé el proyecto de podcast pero al final no continué. No utilicé ni el 20% del plan.', 4, TRUE, FALSE),

(11, 15, '2024-04-05', 'pro', 'precio_alto',
 'El producto está bien pero €19/mes es caro para uso esporádico. Necesitaría un plan intermedio.', 6, TRUE, FALSE),

(24, 35, '2024-04-30', 'pro', 'alternativa_competencia',
 'Me cambié a Otter.ai porque tenía integración nativa con Zoom que ScriptMind no tenía.', 3, FALSE, FALSE),

(19, 30, '2024-05-28', 'pro', 'proyecto_terminado',
 'Era para un proyecto de investigación académica que ya terminé. Puede que vuelva en el futuro.', 7, FALSE, TRUE),  -- podría reactivar

(30, 47, '2024-05-20', 'pro', 'funcionalidad_faltante',
 'Necesito transcripción en tiempo real y aún no la tenéis. Cuando la tengáis vuelvo.', 5, FALSE, FALSE),

(42, 65, '2024-06-15', 'pro', 'precio_alto',
 'Buen producto pero mi freelance va lento. No puedo justificar €19/mes ahora mismo.', 6, TRUE, FALSE),

(55, 85, '2024-06-25', 'pro', 'alternativa_competencia',
 'Me ofrecieron un descuento del 50% en Fireflies.ai para migrar. No pude rechazarlo.', 4, FALSE, FALSE),

(22, 32, '2024-03-30', 'pro', 'poco_uso',   -- Marta kowalski (usuario 11 es Marta, 22 es Marcus, revisando)
 'Prueba: churn ficticio Marcus para variación en datos', 5, TRUE, FALSE),

(23, 35, '2024-05-01', 'pro', 'precio_alto',
 'Registrado solo para probar. El free no me convenció lo suficiente para pagar.', 3, FALSE, FALSE);
