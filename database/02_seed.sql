-- =============================================================
-- ViveRioja Experience S.L. — Datos de Prueba Realistas
-- Ejecutar DESPUÉS de 01_schema.sql
-- =============================================================

-- -------------------------
-- BODEGAS PARTNER (7 reales)
-- -------------------------
INSERT INTO bodegas (nombre, tipo, localidad, provincia, denominacion_origen, año_fundacion, descripcion, web, capacidad_max) VALUES
('Marqués de Riscal',        'bodega',          'Elciego',         'Álava',    'DOCa Rioja',         1858, 'Bodega pionera con arquitectura de Frank Gehry. Icono del enoturismo mundial.',                   'www.marquesderiscal.com',    80),
('Ysios',                    'bodega',          'Laguardia',       'Álava',    'DOCa Rioja',         1999, 'Diseñada por Santiago Calatrava. Integración arquitectónica con el paisaje alavés.',             'www.ysios.com',              60),
('Bodegas Muga',             'bodega',          'Haro',            'La Rioja', 'DOCa Rioja',         1932, 'Bodega artesanal en el Barrio de la Estación de Haro. Referente de la viticultura tradicional.', 'www.bodegasmuga.com',        70),
('López de Heredia',         'bodega',          'Haro',            'La Rioja', 'DOCa Rioja',         1877, 'La bodega más antigua de Haro. Elaboración tradicional con crianzas de décadas.',                'www.lopezdeheredia.com',     40),
('Venta Moncalvillo',        'restaurante',     'Daroca de Rioja', 'La Rioja', NULL,                 1999, 'Dos estrellas Michelin. Cocina de vanguardia riojana con bodega propia.',                       'www.ventamoncalvillo.com',   30),
('Echaurren Tradición',      'bodega_restaurante','Ezcaray',        'La Rioja', NULL,                 1898, 'Restaurante histórico de Ezcaray. Estrella Michelin. Cocina tradicional riojana de autor.',      'www.echaurren.com',          50),
('Hotel Marqués de Riscal',  'bodega_hotel',    'Elciego',         'Álava',    'DOCa Rioja',         2006, 'Hotel 5* de lujo diseñado por Frank Gehry. Spa Caudalie. Destino enoturístico premium.',         'www.hotel-marquesderiscal.com', 120);


-- -------------------------
-- EMPLEADOS (8)
-- -------------------------
INSERT INTO empleados (nombre, apellidos, email, rol, idiomas, fecha_alta) VALUES
('Carlos',    'Martínez Ruiz',      'c.martinez@viverioja.es',   'director',       'es,en',         '2022-01-10'),
('Laura',     'García Fernández',   'l.garcia@viverioja.es',     'gestor',         'es,en,fr',      '2022-03-15'),
('Alejandro', 'López Pérez',        'a.lopez@viverioja.es',      'guia',           'es,en',         '2022-06-01'),
('Sofía',     'Romero Jiménez',     's.romero@viverioja.es',     'sommelier',      'es,en,fr',      '2022-09-01'),
('Miguel',    'Torres Blanco',      'm.torres@viverioja.es',     'guia',           'es,de',         '2023-02-15'),
('Ana',       'Sánchez Moreno',     'a.sanchez@viverioja.es',    'recepcionista',  'es,en',         '2023-05-01'),
('Pablo',     'Iglesias Vega',      'p.iglesias@viverioja.es',   'guia',           'es,en,it',      '2023-09-10'),
('Elena',     'Castro Navarro',     'e.castro@viverioja.es',     'sommelier',      'es,fr',         '2024-01-20');


-- -------------------------
-- EXPERIENCIAS (12, mixtas de tier)
-- -------------------------
INSERT INTO experiencias (nombre, slug, tier, categoria, descripcion, precio_base, precio_max, duracion_horas, aforo_min, aforo_max, incluye_transporte, incluye_manutension, fecha_alta) VALUES
-- ESTÁNDAR
('Visita Clásica Bodegas Muga',
 'visita-clasica-muga',
 'estandar', 'enoturismo',
 'Recorrido por las instalaciones de Muga: lagares de madera, barricas, sala de crianza. Cata de 2 vinos (Crianza + Reserva) con guía certificado.',
 24.99, 24.99, 2.0, 1, 25, FALSE, FALSE, '2022-06-01'),

('Paseo por los Viñedos de Ysios',
 'paseo-vinedos-ysios',
 'estandar', 'enoturismo',
 'Ruta a pie entre los viñedos de Laguardia con vistas a la Sierra de Cantabria. Introducción a la viticultura y finalización con cata de 1 vino.',
 19.99, 19.99, 1.5, 1, 30, FALSE, FALSE, '2022-06-01'),

('Taller Introducción a la Cata',
 'taller-intro-cata',
 'estandar', 'maridaje',
 'Aprende a catar vino desde cero: vista, nariz, boca. Incluye 3 vinos riojanos de distintas añadas y ficha de cata personal.',
 29.99, 29.99, 2.0, 4, 20, FALSE, FALSE, '2022-09-01'),

-- PERSONALIZADA
('Experiencia Privada López de Heredia',
 'privada-lopez-heredia',
 'personalizada', 'enoturismo',
 'Acceso exclusivo a las galerías subterráneas y cata privada de vinos con guía personal. Grupos desde 2 personas, precio según tamaño y selección de vinos.',
 75.00, 150.00, 3.0, 2, 10, FALSE, FALSE, '2022-06-15'),

('Ruta Personalizada La Rioja Alavesa',
 'ruta-rioja-alavesa',
 'personalizada', 'combinada',
 'Diseña tu ruta por las bodegas de La Rioja Alavesa. Elige 2-3 bodegas, maridaje y nivel de experiencia. Transporte incluido para grupos de 4+.',
 90.00, 200.00, 6.0, 2, 12, TRUE, FALSE, '2022-08-01'),

('Cata Maridaje a Medida',
 'cata-maridaje-medida',
 'personalizada', 'maridaje',
 'Nuestro sommelier diseña una cata de 5-7 vinos maridados con productos gastronómicos riojanos según tus preferencias declaradas.',
 60.00, 120.00, 2.5, 2, 8, FALSE, TRUE, '2023-01-15'),

-- PREMIUM
('Weekend en Hotel Marqués de Riscal',
 'weekend-marques-riscal',
 'premium', 'spa',
 'Escapada 2 noches en habitación superior. Acceso ilimitado al Spa Caudalie, desayuno incluido, visita privada a la bodega y cata guiada de 6 vinos con sommelier.',
 280.00, 380.00, 48.0, 2, 6, FALSE, TRUE, '2022-06-01'),

('Cena Maridaje Venta Moncalvillo',
 'cena-venta-moncalvillo',
 'premium', 'gastronomia',
 'Cena de 7 pases en Venta Moncalvillo (2 estrellas Michelin) con maridaje de vinos riojanos de autor seleccionados por el sumiller. Recogida en Logroño incluida.',
 195.00, 195.00, 4.0, 2, 10, TRUE, TRUE, '2022-06-01'),

('Experiencia 360° Frank Gehry',
 'experiencia-gehry-360',
 'premium', 'cultural',
 'Visita arquitectónica al edificio de Frank Gehry, bodega premium, cata de 8 vinos selectos y cena de gala en el restaurante del hotel. Experiencia inmersiva única.',
 250.00, 250.00, 5.5, 2, 8, FALSE, TRUE, '2022-10-01'),

('VIP Harvest — Vendimia en Rioja',
 'vip-harvest-vendimia',
 'premium', 'aventura',
 'Participa activamente en la vendimia con viticultores locales. Pisado tradicional de uva, elaboración de tu propio vino y botella personalizada. Solo disponible septiembre-octubre.',
 300.00, 350.00, 8.0, 2, 12, TRUE, TRUE, '2022-08-15'),

('Gran Tour Gastronómico Echaurren',
 'gran-tour-echaurren',
 'premium', 'gastronomia',
 'Visita a Echaurren Tradición (1 estrella Michelin) en Ezcaray: cocina en vivo con el chef, almuerzo de 6 pases con maridaje y traslado desde Logroño.',
 160.00, 160.00, 6.0, 2, 10, TRUE, TRUE, '2023-03-01'),

('Gran Tour Rioja 3 Días',
 'gran-tour-rioja-3-dias',
 'premium', 'combinada',
 'Itinerario completo: Haro, Laguardia, Leza, Logroño. 3 noches en hotel 4*, 4 bodegas, 2 restaurantes estrella Michelin, guía privado y transporte de lujo.',
 450.00, 550.00, 72.0, 2, 10, TRUE, TRUE, '2023-06-01');


-- -------------------------
-- EXPERIENCIA_BODEGA
-- -------------------------
INSERT INTO experiencia_bodega (experiencia_id, bodega_id, rol) VALUES
(1,  3, 'principal'),   -- Visita Muga → Bodegas Muga
(2,  2, 'principal'),   -- Paseo Ysios → Ysios
(3,  3, 'principal'),   -- Taller Cata → Muga
(3,  4, 'colaboradora'),-- Taller Cata también usa vinos de López de Heredia
(4,  4, 'principal'),   -- Privada LH → López de Heredia
(5,  1, 'principal'),   -- Ruta Alavesa → Marqués de Riscal (bodega)
(5,  2, 'colaboradora'),-- + Ysios
(6,  3, 'principal'),   -- Cata Maridaje → Muga
(6,  5, 'colaboradora'),-- + Venta Moncalvillo (productos)
(7,  7, 'principal'),   -- Weekend → Hotel Marqués de Riscal
(7,  1, 'colaboradora'),-- + Bodega MR
(8,  5, 'principal'),   -- Cena VM → Venta Moncalvillo
(9,  7, 'principal'),   -- Gehry 360 → Hotel
(9,  1, 'colaboradora'),-- + Bodega
(10, 1, 'principal'),   -- VIP Harvest → MR
(10, 3, 'colaboradora'),-- + Muga
(11, 6, 'principal'),   -- Tour Echaurren → Echaurren
(12, 1, 'principal'),   -- Gran Tour 3D → MR
(12, 2, 'colaboradora'),-- + Ysios
(12, 3, 'colaboradora'),-- + Muga
(12, 4, 'colaboradora'),-- + LH
(12, 5, 'colaboradora');-- + Venta Moncalvillo


-- -------------------------
-- CLIENTES (35)
-- -------------------------
INSERT INTO clientes (nombre, apellidos, email, telefono, fecha_nacimiento, nacionalidad, ciudad, pais, canal_adquisicion, fecha_registro) VALUES
-- Españoles
('María',       'González López',      'maria.gonzalez@gmail.com',        '+34 612 345 678', '1988-03-12', 'ES', 'Madrid',      'España',     'web',             '2023-01-15'),
('Javier',      'Martínez Ruiz',       'javier.martinez@hotmail.com',     '+34 634 567 890', '1975-07-22', 'ES', 'Bilbao',      'España',     'redes_sociales',  '2023-02-20'),
('Carmen',      'Rodríguez Pérez',     'carmen.rodriguez@outlook.com',    '+34 656 789 012', '1990-11-05', 'ES', 'Barcelona',   'España',     'referido',        '2023-03-10'),
('Antonio',     'López García',        'antonio.lopez@gmail.com',         '+34 678 901 234', '1965-04-18', 'ES', 'Valencia',    'España',     'agencia',         '2023-04-05'),
('Isabel',      'Fernández Torres',    'isabel.fernandez@yahoo.es',       '+34 600 123 456', '1982-09-30', 'ES', 'Logroño',     'España',     'web',             '2023-04-12'),
('Pablo',       'Sánchez Moreno',      'pablo.sanchez@gmail.com',         '+34 622 345 678', '1993-06-15', 'ES', 'Zaragoza',    'España',     'redes_sociales',  '2023-05-08'),
('Lucía',       'Ramírez Jiménez',     'lucia.ramirez@icloud.com',        '+34 644 567 890', '1987-12-01', 'ES', 'Pamplona',    'España',     'web',             '2023-06-01'),
('Diego',       'Hernández Castro',    'diego.hernandez@gmail.com',       '+34 666 789 012', '1979-08-14', 'ES', 'Sevilla',     'España',     'feria',           '2023-06-15'),
('Marta',       'Jiménez Vega',        'marta.jimenez@gmail.com',         '+34 688 901 234', '1995-02-28', 'ES', 'Vitoria',     'España',     'referido',        '2023-07-20'),
('Sergio',      'Torres Blanco',       'sergio.torres@hotmail.com',       '+34 610 234 567', '1970-10-09', 'ES', 'San Sebastián','España',    'web',             '2023-08-05'),
-- Internacionales Europa
('Sophie',      'Dubois Martin',       'sophie.dubois@laposte.net',       '+33 612 345 678', '1985-05-20', 'FR', 'Paris',       'Francia',    'web',             '2023-05-15'),
('Thomas',      'Müller Schmidt',      'thomas.muller@gmx.de',            '+49 170 123 4567','1978-03-08', 'DE', 'Múnich',      'Alemania',   'agencia',         '2023-07-10'),
('Emma',        'Wilson Johnson',      'emma.wilson@gmail.com',           '+44 7911 123456', '1991-11-17', 'GB', 'Londres',     'Reino Unido','web',             '2023-08-20'),
('Luca',        'Rossi Ferrari',       'luca.rossi@libero.it',            '+39 347 123 4567','1983-06-25', 'IT', 'Milán',       'Italia',     'redes_sociales',  '2023-09-05'),
('Anna',        'Van den Berg',        'anna.vandenberg@gmail.com',       '+31 612 345 678', '1990-01-14', 'NL', 'Ámsterdam',   'Países Bajos','agencia',        '2023-10-01'),
-- Internacionales fuera Europa
('Michael',     'Thompson Davis',      'michael.thompson@outlook.com',    '+1 917 555 0123', '1968-07-30', 'US', 'Nueva York',  'EEUU',       'web',             '2023-11-15'),
('Yuki',        'Tanaka Watanabe',     'yuki.tanaka@docomo.ne.jp',        '+81 80 1234 5678','1986-04-12', 'JP', 'Tokio',       'Japón',      'agencia',         '2024-01-20'),
('Ana Carolina','Silva Pereira',       'anacarolina.silva@gmail.com',     '+55 11 98765 4321','1992-09-03', 'BR', 'São Paulo',   'Brasil',     'redes_sociales',  '2024-02-10'),
-- Más españoles (clientes frecuentes / alto valor)
('Roberto',     'Álvarez Navarro',     'roberto.alvarez@gmail.com',       '+34 632 456 789', '1960-12-20', 'ES', 'Madrid',      'España',     'referido',        '2022-11-01'),
('Patricia',    'Moreno García',       'patricia.moreno@gmail.com',       '+34 654 678 901', '1977-04-05', 'ES', 'Bilbao',      'España',     'web',             '2022-12-15'),
('Eduardo',     'Ruiz Castillo',       'eduardo.ruiz@empresa.com',        '+34 676 890 123', '1969-08-17', 'ES', 'Madrid',      'España',     'agencia',         '2023-01-08'),
('Natalia',     'Iglesias Prado',      'natalia.iglesias@gmail.com',      '+34 698 012 345', '1994-03-22', 'ES', 'La Coruña',   'España',     'redes_sociales',  '2023-09-12'),
('Álvaro',      'Cruz Medina',         'alvaro.cruz@hotmail.com',         '+34 611 234 567', '1988-07-11', 'ES', 'Málaga',      'España',     'web',             '2023-10-20'),
('Cristina',    'Molina Ramos',        'cristina.molina@gmail.com',       '+34 633 456 789', '1984-01-29', 'ES', 'Valladolid',  'España',     'feria',           '2023-11-05'),
('Víctor',      'Ortega Serrano',      'victor.ortega@outlook.com',       '+34 655 678 901', '1971-05-16', 'ES', 'Burgos',      'España',     'referido',        '2023-12-01'),
('Laura',       'Gil Fuentes',         'laura.gil@gmail.com',             '+34 677 890 123', '1996-10-08', 'ES', 'Logroño',     'España',     'web',             '2024-01-10'),
('Carlos',      'Herrera Montoya',     'carlos.herrera@gmail.com',        '+34 699 012 345', '1980-02-14', 'ES', 'Bilbao',      'España',     'redes_sociales',  '2024-02-25'),
('Beatriz',     'Santos Nieto',        'beatriz.santos@yahoo.es',         '+34 612 345 679', '1989-06-03', 'ES', 'Madrid',      'España',     'web',             '2024-03-15'),
('Jorge',       'Reyes Domínguez',     'jorge.reyes@gmail.com',           '+34 634 567 891', '1974-11-27', 'ES', 'Zaragoza',    'España',     'agencia',         '2024-04-01'),
('Silvia',      'Vargas Campos',       'silvia.vargas@gmail.com',         '+34 656 789 013', '1991-08-19', 'ES', 'Valencia',    'España',     'web',             '2024-05-10'),
('François',    'Leroy Dupont',        'francois.leroy@orange.fr',        '+33 698 765 432', '1975-12-04', 'FR', 'Lyon',        'Francia',    'agencia',         '2024-06-01'),
('Ingrid',      'Hansen Nielsen',      'ingrid.hansen@gmail.com',         '+45 20 123 456',  '1987-03-15', 'DK', 'Copenhague',  'Dinamarca',  'web',             '2024-07-20'),
('Marco',       'Bianchi Conti',       'marco.bianchi@gmail.com',         '+39 333 987 6543','1982-09-09', 'IT', 'Roma',        'Italia',     'redes_sociales',  '2024-08-05'),
('Elena',       'Popescu Ionescu',     'elena.popescu@gmail.com',         '+40 721 234 567', '1993-04-25', 'RO', 'Bucarest',    'Rumanía',    'web',             '2024-09-01'),
('Haruto',      'Sato Kimura',         'haruto.sato@gmail.com',           '+81 90 8765 4321','1979-01-30', 'JP', 'Osaka',       'Japón',      'agencia',         '2024-10-15');


-- -------------------------
-- RESERVAS (55 registros)
-- Distribuidas 2023-2025, estados variados
-- -------------------------
INSERT INTO reservas (cliente_id, experiencia_id, empleado_id, fecha_reserva, fecha_experiencia, hora_inicio, num_personas, precio_unitario, descuento_pct, precio_total, canal_reserva, codigo_promo, estado, notas) VALUES
-- 2023 — primeros meses
(1,  1, 3, '2023-03-10', '2023-03-15', '10:00', 2,  24.99, 0,    49.98,  'web',        NULL,        'completada', NULL),
(2,  2, 3, '2023-03-18', '2023-03-25', '11:00', 4,  19.99, 0,    79.96,  'web',        NULL,        'completada', 'Grupo familiar'),
(11, 5, 7, '2023-04-05', '2023-04-12', '09:30', 2,  90.00, 0,   180.00,  'agencia',    NULL,        'completada', 'Pareja francesa, EN'),
(19, 7, 3, '2023-04-10', '2023-05-01', '14:00', 2, 280.00, 0,   560.00,  'web',        NULL,        'completada', 'Aniversario'),
(3,  3, 4, '2023-04-20', '2023-04-28', '17:00', 6,  29.99, 0,   179.94,  'telefono',   NULL,        'completada', 'Despedida de soltero'),
(20, 9, 7, '2023-05-01', '2023-05-15', '19:00', 2, 250.00, 0,   500.00,  'web',        NULL,        'completada', 'Ejecutivos Madrid'),
(4,  8, 3, '2023-05-12', '2023-05-20', '20:30', 4, 195.00, 0,   780.00,  'agencia',    NULL,        'completada', 'Empresa tech Valencia'),
(12, 5, 7, '2023-05-20', '2023-06-03', '10:00', 3,  90.00, 0,   270.00,  'agencia',    NULL,        'completada', 'Grupo alemán, EN'),
(5,  1, 3, '2023-06-01', '2023-06-10', '10:30', 1,  24.99, 0,    24.99,  'web',        NULL,        'completada', NULL),
(21, 11,7, '2023-06-05', '2023-06-18', '13:00', 2, 160.00, 0,   320.00,  'presencial', NULL,        'completada', 'Tour gastronómico Madrid'),
(13, 2, 5, '2023-06-10', '2023-06-20', '11:00', 2,  19.99, 0,    39.98,  'web',        NULL,        'completada', NULL),
(6,  6, 4, '2023-06-15', '2023-06-25', '18:00', 2,  60.00, 0,   120.00,  'redes_sociales', NULL,   'completada', NULL),
(19, 10,3, '2023-07-01', '2023-09-15', '08:00', 2, 300.00, 0,   600.00,  'web',        NULL,        'completada', 'Vendimia — reserva anticipada'),
(7,  4, 4, '2023-07-10', '2023-07-20', '10:00', 2,  75.00, 0,   150.00,  'web',        NULL,        'completada', NULL),
(14, 9, 7, '2023-07-15', '2023-07-28', '19:00', 4, 250.00, 0,  1000.00,  'agencia',    NULL,        'completada', 'Grupo italiano, EN+IT'),
(8,  7, 3, '2023-07-20', '2023-08-05', '14:00', 2, 280.00, 0,   560.00,  'web',        NULL,        'completada', NULL),
(22, 12,7, '2023-07-25', '2023-08-10', '09:00', 2, 450.00, 0,   900.00,  'agencia',    NULL,        'completada', 'Pareja lunamiel'),
(16, 8, 3, '2023-08-01', '2023-08-15', '20:30', 2, 195.00, 0,   390.00,  'agencia',    NULL,        'completada', 'Cliente USA, EN'),
(9,  3, 4, '2023-08-05', '2023-08-12', '17:30', 8,  29.99, 0,   239.92,  'telefono',   NULL,        'completada', 'Grupo cumpleaños'),
(10, 5, 7, '2023-08-10', '2023-08-20', '09:30', 2,  90.00, 0,   180.00,  'web',        NULL,        'completada', 'Cliente San Sebastián'),
-- Canceladas y no_show
(23, 1, 3, '2023-08-15', '2023-08-25', '10:00', 2,  24.99, 0,    49.98,  'web',        NULL,        'cancelada',  'Cliente canceló por viaje'),
(24, 6, 4, '2023-09-01', '2023-09-10', '18:00', 2,  60.00, 0,   120.00,  'web',        NULL,        'no_show',    'Sin aviso previo'),
-- 2023 otoño/invierno
(19, 9, 7, '2023-09-05', '2023-09-20', '19:00', 2, 250.00, 0,   500.00,  'presencial', NULL,        'completada', 'Segunda visita'),
(20, 10,3, '2023-09-08', '2023-10-01', '08:00', 4, 300.00, 0,  1200.00,  'web',        NULL,        'completada', 'Vendimia grupo'),
(15, 5, 7, '2023-09-15', '2023-09-28', '10:00', 2,  90.00, 0,   180.00,  'agencia',    NULL,        'completada', 'Pareja NL, EN'),
(25, 11,7, '2023-10-05', '2023-10-15', '13:00', 4, 160.00, 0,   640.00,  'web',        NULL,        'completada', NULL),
(17, 12,7, '2023-10-10', '2023-10-25', '09:00', 2, 450.00, 0,   900.00,  'agencia',    NULL,        'completada', 'Cliente Japón, EN'),
(1,  3, 4, '2023-11-01', '2023-11-10', '17:30', 3,  29.99, 0,    89.97,  'web',        NULL,        'completada', 'Segunda visita'),
(26, 2, 5, '2023-11-10', '2023-11-20', '11:00', 2,  19.99, 0,    39.98,  'web',        NULL,        'completada', NULL),
(21, 8, 3, '2023-11-15', '2023-11-25', '20:30', 2, 195.00, 0,   390.00,  'web',        NULL,        'completada', NULL),
-- 2024
(27, 1, 3, '2024-01-20', '2024-01-28', '10:30', 2,  24.99, 0,    49.98,  'web',        NULL,        'completada', NULL),
(18, 5, 7, '2024-02-01', '2024-02-14', '10:00', 2,  90.00, 0,   180.00,  'redes_sociales', NULL,   'completada', 'San Valentín Brasil, EN'),
(28, 9, 7, '2024-02-10', '2024-02-20', '19:00', 2, 250.00, 0,   500.00,  'web',        NULL,        'completada', NULL),
(19, 7, 3, '2024-03-05', '2024-03-20', '14:00', 2, 280.00, 0,   560.00,  'web',        NULL,        'completada', 'Tercera visita'),
(29, 6, 4, '2024-03-15', '2024-03-22', '18:00', 2,  60.00, 0,   120.00,  'agencia',    NULL,        'completada', NULL),
(2,  8, 3, '2024-04-01', '2024-04-10', '20:30', 2, 195.00, 0,   390.00,  'web',        NULL,        'completada', 'Repetidor'),
(30, 11,7, '2024-04-10', '2024-04-20', '13:00', 4, 160.00, 0,   640.00,  'web',        NULL,        'completada', NULL),
(31, 4, 4, '2024-05-01', '2024-05-10', '10:00', 2,  75.00, 0,   150.00,  'agencia',    NULL,        'completada', 'Pareja Francia, FR'),
(32, 2, 5, '2024-05-10', '2024-05-18', '11:00', 2,  19.99, 0,    39.98,  'web',        NULL,        'completada', 'Dinamarca, EN'),
(20, 12,7, '2024-05-15', '2024-06-01', '09:00', 4, 450.00, 0,  1800.00,  'presencial', NULL,        'completada', 'Tercer gran tour'),
-- Con promo QR jurado
(26, 1, 3, '2024-06-01', '2024-06-10', '10:00', 2,  24.99, 15,   42.48,  'qr_promo',   'JURADO2024','completada', 'Promo QR jurado'),
(22, 3, 4, '2024-06-05', '2024-06-15', '17:30', 4,  29.99, 15,  101.97,  'qr_promo',   'JURADO2024','completada', 'Promo QR jurado'),
-- Verano 2024
(33, 9, 7, '2024-07-01', '2024-07-15', '19:00', 2, 250.00, 0,   500.00,  'web',        NULL,        'completada', 'Italia'),
(3,  10,3, '2024-07-10', '2024-09-20', '08:00', 2, 300.00, 0,   600.00,  'web',        NULL,        'completada', 'Vendimia 2024'),
(34, 5, 7, '2024-07-15', '2024-07-25', '10:00', 2,  90.00, 0,   180.00,  'agencia',    NULL,        'completada', 'Rumanía, EN'),
(19, 8, 3, '2024-08-01', '2024-08-15', '20:30', 2, 195.00, 0,   390.00,  'web',        NULL,        'completada', 'Cuarta visita'),
(35, 12,7, '2024-08-10', '2024-08-25', '09:00', 2, 450.00, 0,   900.00,  'agencia',    NULL,        'completada', 'Japón gran tour'),
(4,  7, 3, '2024-09-01', '2024-09-15', '14:00', 4, 280.00, 0,  1120.00,  'agencia',    NULL,        'completada', 'Empresa Valencia'),
-- Pendientes / confirmadas 2025
(1,  9, 7, '2025-01-10', '2025-03-15', '19:00', 2, 250.00, 0,   500.00,  'web',        NULL,        'confirmada', NULL),
(27, 7, 3, '2025-01-20', '2025-04-01', '14:00', 2, 280.00, 0,   560.00,  'web',        NULL,        'confirmada', NULL),
(13, 12,7, '2025-02-05', '2025-05-10', '09:00', 2, 450.00, 0,   900.00,  'agencia',    NULL,        'confirmada', NULL),
(28, 3, 4, '2025-02-15', '2025-03-22', '17:30', 4,  29.99, 0,   119.96,  'web',        NULL,        'pendiente',  NULL),
(5,  11,7, '2025-03-01', '2025-04-20', '13:00', 2, 160.00, 0,   320.00,  'redes_sociales', NULL,   'pendiente',  NULL);


-- -------------------------
-- PAGOS (~55 registros)
-- Cada reserva completada tiene pago 'completado'
-- Cancelada/no_show puede tener reembolso
-- -------------------------
INSERT INTO pagos (reserva_id, fecha_pago, importe, metodo_pago, estado, referencia_externa) VALUES
(1,  '2023-03-10', 49.98,   'tarjeta',       'completado', 'ch_1A2B3C4D'),
(2,  '2023-03-18', 79.96,   'tarjeta',       'completado', 'ch_2B3C4D5E'),
(3,  '2023-04-05', 180.00,  'transferencia', 'completado', 'TRF-2304-001'),
(4,  '2023-04-10', 280.00,  'tarjeta',       'completado', 'ch_3C4D5E6F'),  -- señal 50%
(4,  '2023-04-30', 280.00,  'tarjeta',       'completado', 'ch_3C4D5E7G'),  -- resto
(5,  '2023-04-20', 179.94,  'tarjeta',       'completado', 'ch_4D5E6F7G'),
(6,  '2023-05-01', 500.00,  'tarjeta',       'completado', 'ch_5E6F7G8H'),
(7,  '2023-05-12', 780.00,  'transferencia', 'completado', 'TRF-2305-002'),
(8,  '2023-05-20', 270.00,  'tarjeta',       'completado', 'ch_6F7G8H9I'),
(9,  '2023-06-01', 24.99,   'bizum',         'completado', 'BIZ-2306-001'),
(10, '2023-06-05', 320.00,  'tarjeta',       'completado', 'ch_7G8H9I0J'),
(11, '2023-06-10', 39.98,   'tarjeta',       'completado', 'ch_8H9I0J1K'),
(12, '2023-06-15', 120.00,  'tarjeta',       'completado', 'ch_9I0J1K2L'),
(13, '2023-07-01', 300.00,  'tarjeta',       'completado', 'ch_0J1K2L3M'),  -- señal
(13, '2023-09-10', 300.00,  'tarjeta',       'completado', 'ch_0J1K2L4N'),  -- resto
(14, '2023-07-10', 150.00,  'tarjeta',       'completado', 'ch_1K2L3M4N'),
(15, '2023-07-15', 1000.00, 'transferencia', 'completado', 'TRF-2307-003'),
(16, '2023-07-20', 280.00,  'tarjeta',       'completado', 'ch_2L3M4N5O'),  -- señal
(16, '2023-08-01', 280.00,  'tarjeta',       'completado', 'ch_2L3M4N6P'),  -- resto
(17, '2023-07-25', 450.00,  'transferencia', 'completado', 'TRF-2307-004'),
(17, '2023-08-05', 450.00,  'transferencia', 'completado', 'TRF-2308-001'),
(18, '2023-08-01', 390.00,  'tarjeta',       'completado', 'ch_3M4N5O6P'),
(19, '2023-08-05', 239.92,  'efectivo',      'completado', NULL),
(20, '2023-08-10', 180.00,  'bizum',         'completado', 'BIZ-2308-002'),
-- Cancelada — reembolso
(21, '2023-08-15', 49.98,   'tarjeta',       'reembolsado','ch_REF-0001'),
-- No_show — sin reembolso (política empresa)
(22, '2023-09-01', 120.00,  'tarjeta',       'completado', 'ch_4N5O6P7Q'),
(23, '2023-09-05', 500.00,  'tarjeta',       'completado', 'ch_5O6P7Q8R'),
(24, '2023-09-08', 600.00,  'transferencia', 'completado', 'TRF-2309-002'),
(24, '2023-09-30', 600.00,  'transferencia', 'completado', 'TRF-2310-001'),
(25, '2023-09-15', 180.00,  'tarjeta',       'completado', 'ch_6P7Q8R9S'),
(26, '2023-10-05', 640.00,  'tarjeta',       'completado', 'ch_7Q8R9S0T'),
(27, '2023-10-10', 450.00,  'transferencia', 'completado', 'TRF-2310-002'),
(27, '2023-10-20', 450.00,  'transferencia', 'completado', 'TRF-2310-003'),
(28, '2023-11-01', 89.97,   'tarjeta',       'completado', 'ch_8R9S0T1U'),
(29, '2023-11-10', 39.98,   'tarjeta',       'completado', 'ch_9S0T1U2V'),
(30, '2023-11-15', 390.00,  'bizum',         'completado', 'BIZ-2311-001'),
(31, '2024-01-20', 49.98,   'tarjeta',       'completado', 'ch_0T1U2V3W'),
(32, '2024-02-01', 180.00,  'paypal',        'completado', 'PP-2402-001'),
(33, '2024-02-10', 500.00,  'tarjeta',       'completado', 'ch_1U2V3W4X'),
(34, '2024-03-05', 280.00,  'tarjeta',       'completado', 'ch_2V3W4X5Y'),  -- señal
(34, '2024-03-15', 280.00,  'tarjeta',       'completado', 'ch_2V3W4X6Z'),  -- resto
(35, '2024-03-15', 120.00,  'tarjeta',       'completado', 'ch_3W4X5Y6Z'),
(36, '2024-04-01', 390.00,  'tarjeta',       'completado', 'ch_4X5Y6Z7A'),
(37, '2024-04-10', 640.00,  'tarjeta',       'completado', 'ch_5Y6Z7A8B'),
(38, '2024-05-01', 150.00,  'tarjeta',       'completado', 'ch_6Z7A8B9C'),
(39, '2024-05-10', 39.98,   'bizum',         'completado', 'BIZ-2405-001'),
(40, '2024-05-15', 900.00,  'transferencia', 'completado', 'TRF-2405-001'),
(40, '2024-05-20', 900.00,  'transferencia', 'completado', 'TRF-2405-002'),
(41, '2024-06-01', 42.48,   'tarjeta',       'completado', 'ch_7A8B9C0D'),
(42, '2024-06-05', 101.97,  'tarjeta',       'completado', 'ch_8B9C0D1E'),
(43, '2024-07-01', 500.00,  'tarjeta',       'completado', 'ch_9C0D1E2F'),
(44, '2024-07-10', 300.00,  'transferencia', 'completado', 'TRF-2407-001'),
(44, '2024-09-15', 300.00,  'transferencia', 'completado', 'TRF-2409-001'),
(45, '2024-07-15', 180.00,  'paypal',        'completado', 'PP-2407-001'),
(46, '2024-08-01', 390.00,  'tarjeta',       'completado', 'ch_0D1E2F3G'),
(47, '2024-08-10', 450.00,  'transferencia', 'completado', 'TRF-2408-001'),
(47, '2024-08-20', 450.00,  'transferencia', 'completado', 'TRF-2408-002'),
(48, '2024-09-01', 560.00,  'tarjeta',       'completado', 'ch_1E2F3G4H'),
(48, '2024-09-05', 560.00,  'tarjeta',       'completado', 'ch_1E2F3G5I'),
-- Pagos de reservas futuras (confirmadas) — señal
(49, '2025-01-10', 250.00,  'tarjeta',       'completado', 'ch_2F3G4H5I'),
(50, '2025-01-20', 280.00,  'tarjeta',       'completado', 'ch_3G4H5I6J'),
(51, '2025-02-05', 450.00,  'transferencia', 'completado', 'TRF-2502-001');


-- -------------------------
-- RESEÑAS (22 registros)
-- Solo de reservas 'completadas'
-- -------------------------
INSERT INTO resenas (reserva_id, cliente_id, puntuacion, comentario, fecha_resena, publicada, respuesta_empresa) VALUES
(1,  1,  5, 'Experiencia increíble. Carlos nos explicó todo con pasión. Los vinos de Muga son espectaculares. Volveremos sin duda.',
     '2023-03-16', TRUE,  'Gracias María, fue un placer teneros. ¡Hasta la próxima vendimia!'),
(2,  2,  4, 'Muy buena ruta por los viñedos. El paisaje es impresionante. Quizás algo corta para el precio.',
     '2023-03-26', TRUE,  'Gracias Javier. Valoramos tu feedback — estamos ampliando el recorrido esta primavera.'),
(3, 11,  5, 'Magnifique expérience! Sophie et moi avons adoré la route personnalisée. Le guide parlait parfaitement français.',
     '2023-04-13', TRUE,  'Merci Sophie! Nous sommes ravis que vous ayez apprécié.'),
(4, 19,  5, 'Llevamos años visitando La Rioja y esta fue sin duda la mejor experiencia. El hotel Marqués de Riscal es de otro nivel.',
     '2023-05-03', TRUE,  'Roberto, es un honor que nos elegiréis para vuestro aniversario. Enhorabuena.'),
(5,  3,  4, 'El taller estuvo genial para nuestro grupo. Aprendimos muchísimo sobre cata. Sofía es una sommelier excelente.',
     '2023-04-29', TRUE,  NULL),
(6, 20,  5, 'La cena en Venta Moncalvillo fue un sueño. Cada plato maridado a la perfección. Totalmente recomendable.',
     '2023-05-16', TRUE,  'Patricia, nos alegra que disfrutarais. Es uno de nuestros productos estrella.'),
(7,  4,  5, 'Contratamos la cena para todo el equipo. Superó todas las expectativas. Repetiremos con clientes.',
     '2023-05-21', TRUE,  'Encantados de recibir a vuestro equipo Antonio. Estamos a vuestra disposición.'),
(13,19,  5, 'La experiencia de vendimia fue mágica. Pisar la uva, elaborar nuestro propio vino... inexplicable. Gracias.',
     '2023-09-17', TRUE,  'Roberto, la vendimia es siempre especial. Vuestras botellas os esperan en bodega!'),
(15,14,  5, 'Fantastica esperienza! La cena Gehry con vista al viñedo al atardecer fue perfecta. Torneremo!',
     '2023-07-29', TRUE,  'Grazie Luca! We hope to see you and your group again.'),
(17,22,  5, 'Our honeymoon experience was absolutely perfect. Three days felt like a dream. Cannot recommend enough.',
     '2023-08-12', TRUE,  'Natalia y Álvaro, fue nuestro honor acompañaros en vuestra luna de miel.'),
(18,16,  4, 'Excellent dinner at Venta Moncalvillo. The sommelier pairing was exceptional. Slightly rushed at the end.',
     '2023-08-16', TRUE,  'Thank you Michael! We noted your feedback about the timing.'),
(20,10,  4, 'Buena ruta personalizada. El guía Miguel habló algo rápido al principio pero muy profesional.',
     '2023-08-21', TRUE,  NULL),
(23,19,  5, 'Segunda vez en la experiencia 360° Gehry y mejor que la primera. Mejoran constantemente.',
     '2023-09-21', TRUE,  'Roberto, vuestra fidelidad es nuestro mayor reconocimiento. Gracias.'),
(27,17,  5, 'As a Japanese wine lover, this 3-day tour exceeded my expectations. Professional service, incredible wines.',
     '2023-10-26', TRUE,  'Thank you Yuki! It was our pleasure to share Rioja with you.'),
(30,21,  4, 'Buena cena en Venta Moncalvillo. Quizás esperaba algo más en la selección de vinos premium.',
     '2023-11-26', TRUE,  'Eduardo, tomaremos nota para la selección de vinos. Gracias por tu sinceridad.'),
(32,18,  5, 'Ruta a medida para San Valentín perfecta. La bienvenida en Logroño fue un detalle. Muito obrigada!',
     '2024-02-15', TRUE,  'Ana Carolina, fue una alegría celebrar vuestro San Valentín en La Rioja!'),
(36,  2,  5, 'Segunda visita a la cena Venta Moncalvillo y sigue siendo inmejorable. Un clásico.',
     '2024-04-11', TRUE,  NULL),
(41, 41, 3, 'Muy buen taller. Ideal para iniciarse. Sofía explica con mucha claridad.',
     '2024-06-16', FALSE, NULL),  -- pendiente moderación
(43,33,  4, 'Great Gehry experience. The wine selection was outstanding. The dinner could have a vegetarian option.',
     '2024-07-16', TRUE,  'Marco, great feedback — we are adding vegetarian options for 2025!'),
(46,19,  5, 'Cuarta visita a ViveRioja. Siempre sorprenden. La cena en Venta Moncalvillo nunca defrauda.',
     '2024-08-16', TRUE,  'Roberto, eres parte de la familia ViveRioja. Hasta la próxima.'),
(48,  4,  5, 'Trajimos a cuatro directivos de nuestra empresa y quedaron impresionados. Cerraremos acuerdo de empresa.',
     '2024-09-16', TRUE,  'Antonio, sería un honor ser vuestro proveedor oficial. Contactadnos para condiciones B2B.'),
(44,  3,  5, 'Vendimia 2024 fue épica. Mi botella ya tiene nombre. Gracias al equipo entero de ViveRioja.',
     '2024-09-22', TRUE,  'Carmen, tu botella te espera. ¡Salud!');
