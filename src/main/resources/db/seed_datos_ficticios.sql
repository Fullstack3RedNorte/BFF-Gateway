-- =============================================================
-- SEED: Datos ficticios para desarrollo y demo
-- RedNorte · MS-ListaEspera · Junio 2026
-- =============================================================
-- Ejecutar DESPUÉS de las migraciones del backend
-- =============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 1. ESPECIALIDADES
-- -------------------------------------------------------------
INSERT IGNORE INTO especialidad (id, nombre, descripcion) VALUES
  (1,  'Cardiología',          'Diagnóstico y tratamiento de enfermedades del corazón'),
  (2,  'Traumatología',        'Lesiones y enfermedades del sistema músculo-esquelético'),
  (3,  'Neurología',           'Enfermedades del sistema nervioso central y periférico'),
  (4,  'Oftalmología',         'Enfermedades y cirugías del ojo'),
  (5,  'Gastroenterología',    'Enfermedades del aparato digestivo'),
  (6,  'Oncología',            'Diagnóstico y tratamiento del cáncer'),
  (7,  'Endocrinología',       'Trastornos hormonales y metabólicos'),
  (8,  'Reumatología',         'Enfermedades autoinmunes y del tejido conectivo'),
  (9,  'Otorrinolaringología', 'Enfermedades de oído, nariz y garganta'),
  (10, 'Dermatología',         'Enfermedades de la piel, cabello y uñas');

-- -------------------------------------------------------------
-- 2. TIPOS DE VULNERABILIDAD
-- -------------------------------------------------------------
INSERT IGNORE INTO tipo_vulnerabilidad (id, nombre) VALUES
  (1, 'Adulto mayor (≥ 65 años)'),
  (2, 'Gestante'),
  (3, 'Discapacidad acreditada'),
  (4, 'Pueblo indígena'),
  (5, 'Zona rural o aislada');

-- -------------------------------------------------------------
-- 3. SOLICITUDES
-- -------------------------------------------------------------
INSERT INTO solicitud (
  rut_paciente, rut_funcionario, especialidad_id,
  diagnostico, es_ges, patologia_ges,
  nivel_urgencia, es_vulnerable, tipo_vulnerabilidad_id,
  prioridad, estado, fecha_registro, fecha_actualizacion, fecha_cita
) VALUES
-- P1 GES
('12.345.678-9','15.800.001-K',1,'Insuficiencia cardíaca congestiva',TRUE,'ICC - GES Nº4','GES',FALSE,NULL,1,'EN_ESPERA','2026-04-10 08:30:00','2026-04-10 08:30:00',NULL),
('9.876.543-2', '15.800.001-K',6,'Cáncer de mama etapa II',TRUE,'Cáncer de mama - GES Nº15','GES',FALSE,NULL,1,'CITADO','2026-04-15 09:00:00','2026-05-20 10:15:00','2026-07-05 09:00:00'),
('11.222.333-4','15.800.002-1',3,'Epilepsia - primer episodio',TRUE,'Epilepsia - GES Nº25','GES',FALSE,NULL,1,'ATENDIDO','2026-03-01 11:00:00','2026-06-01 14:00:00','2026-06-01 10:00:00'),
('14.555.666-7','15.800.002-1',5,'Hemorragia digestiva alta - úlcera péptica',TRUE,'Úlcera péptica - GES Nº35','GES',FALSE,NULL,1,'EN_ESPERA','2026-06-01 07:45:00','2026-06-01 07:45:00',NULL),
('7.001.002-3', '15.800.003-2',7,'Diabetes mellitus tipo 2 descompensada',TRUE,'DM tipo 2 - GES Nº19','GES',FALSE,NULL,1,'EN_ESPERA','2026-06-15 08:00:00','2026-06-15 08:00:00',NULL),
-- P2 Urgente
('16.777.888-5','15.800.001-K',2,'Fractura de cadera post-caída',FALSE,NULL,'URGENTE',TRUE,1,2,'EN_ESPERA','2026-05-20 10:00:00','2026-05-20 10:00:00',NULL),
('18.999.000-6','15.800.002-1',4,'Desprendimiento de retina sospechoso',FALSE,NULL,'URGENTE',FALSE,NULL,2,'CITADO','2026-06-01 09:30:00','2026-06-10 11:00:00','2026-07-10 08:30:00'),
('8.123.456-7', '15.800.003-2',1,'Angina inestable sin elevación del ST',FALSE,NULL,'URGENTE',FALSE,NULL,2,'ATENDIDO','2026-05-10 14:20:00','2026-06-05 09:00:00','2026-06-05 08:00:00'),
('10.234.567-8','15.800.001-K',9,'Hipoacusia severa bilateral',FALSE,NULL,'URGENTE',TRUE,3,2,'EN_ESPERA','2026-06-20 11:15:00','2026-06-20 11:15:00',NULL),
('19.345.678-9','15.800.002-1',3,'ACV isquémico reciente - seguimiento neurológico',FALSE,NULL,'URGENTE',FALSE,NULL,2,'AUSENTE','2026-05-05 08:00:00','2026-06-10 09:00:00','2026-06-10 09:00:00'),
-- P3 Vulnerable
('6.456.789-0', '15.800.003-2',8,'Artritis reumatoide - control reumatológico',FALSE,NULL,'ELECTIVA',TRUE,1,3,'EN_ESPERA','2026-05-25 09:45:00','2026-05-25 09:45:00',NULL),
('20.567.890-1','15.800.001-K',7,'Hipotiroidismo en adulto mayor',FALSE,NULL,'ELECTIVA',TRUE,1,3,'CITADO','2026-05-30 10:30:00','2026-06-15 08:00:00','2026-07-15 09:00:00'),
('13.678.901-2','15.800.002-1',5,'Colon irritable - colonoscopía diagnóstica',FALSE,NULL,'ELECTIVA',TRUE,2,3,'EN_ESPERA','2026-06-05 08:15:00','2026-06-05 08:15:00',NULL),
('5.789.012-3', '15.800.003-2',10,'Psoriasis moderada - evaluación dermatológica',FALSE,NULL,'ELECTIVA',TRUE,4,3,'EN_ESPERA','2026-06-18 13:00:00','2026-06-18 13:00:00',NULL),
('17.890.123-4','15.800.001-K',2,'Gonartrosis avanzada - evaluación quirúrgica',FALSE,NULL,'ELECTIVA',TRUE,5,3,'ATENDIDO','2026-04-01 10:00:00','2026-06-20 11:00:00','2026-06-20 10:00:00'),
-- P4 Electiva
('4.901.234-5', '15.800.002-1',4,'Control oftalmológico anual - presbicia',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'EN_ESPERA','2026-06-10 14:00:00','2026-06-10 14:00:00',NULL),
('21.012.345-6','15.800.003-2',9,'Rinitis alérgica crónica',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'CITADO','2026-06-12 09:00:00','2026-06-22 10:00:00','2026-07-22 10:00:00'),
('15.123.456-7','15.800.001-K',10,'Acné moderado - evaluación',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'EN_ESPERA','2026-06-22 15:30:00','2026-06-22 15:30:00',NULL),
('3.234.567-8', '15.800.002-1',5,'Reflujo gastroesofágico crónico',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'ANULADO','2026-05-01 09:00:00','2026-06-01 08:00:00',NULL),
('22.345.678-9','15.800.003-2',8,'Fibromialgia - segunda opinión',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'CERRADO','2026-03-15 11:00:00','2026-05-15 14:00:00',NULL),
('11.456.789-0','15.800.001-K',6,'Seguimiento post-tratamiento oncológico',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'EN_ESPERA','2026-06-28 08:30:00','2026-06-28 08:30:00',NULL),
('2.567.890-1', '15.800.002-1',3,'Cefalea tensional recurrente',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'EN_ESPERA','2026-06-29 10:00:00','2026-06-29 10:00:00',NULL),
('23.678.901-2','15.800.003-2',7,'Obesidad - derivación endocrinología',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'DERIVADO','2026-05-20 12:00:00','2026-06-25 09:00:00',NULL),
('9.789.012-3', '15.800.001-K',2,'Lumbalgia crónica - kinesioterapia insuficiente',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'EN_ESPERA','2026-06-25 16:00:00','2026-06-25 16:00:00',NULL),
('1.890.123-4', '15.800.002-1',1,'Hipertensión arterial sin respuesta a tratamiento',FALSE,NULL,'ELECTIVA',FALSE,NULL,4,'VENCIDO','2026-01-10 08:00:00','2026-04-10 08:00:00',NULL);

-- -------------------------------------------------------------
-- 4. HISTORIAL DE ESTADOS
-- -------------------------------------------------------------
INSERT INTO historial_estado (solicitud_id, estado_anterior, estado_nuevo, motivo, fecha_cambio, rut_usuario_responsable) VALUES
(3,NULL,'EN_ESPERA','Registro inicial','2026-03-01 11:00:00','15.800.002-1'),
(3,'EN_ESPERA','CITADO','Hora disponible en agenda','2026-04-15 10:00:00','15.800.002-1'),
(3,'CITADO','ATENDIDO','Paciente atendido sin novedad','2026-06-01 14:00:00','15.800.002-1'),
(8,NULL,'EN_ESPERA','Registro inicial','2026-05-10 14:20:00','15.800.003-2'),
(8,'EN_ESPERA','CITADO','Urgencia confirmada por médico','2026-05-15 09:00:00','15.800.003-2'),
(8,'CITADO','ATENDIDO','Hospitalización completada','2026-06-05 09:00:00','15.800.003-2'),
(10,NULL,'EN_ESPERA','Registro inicial','2026-05-05 08:00:00','15.800.002-1'),
(10,'EN_ESPERA','CITADO','Se asignó hora de control','2026-05-20 11:00:00','15.800.002-1'),
(10,'CITADO','AUSENTE','Paciente no se presentó','2026-06-10 09:00:00','15.800.002-1'),
(19,NULL,'EN_ESPERA','Registro inicial','2026-05-01 09:00:00','15.800.002-1'),
(19,'EN_ESPERA','ANULADO','Paciente desiste del tratamiento','2026-06-01 08:00:00','15.800.002-1'),
(20,NULL,'EN_ESPERA','Registro inicial','2026-03-15 11:00:00','15.800.001-K'),
(20,'EN_ESPERA','CITADO','Hora agendada','2026-04-20 10:00:00','15.800.001-K'),
(20,'CITADO','ATENDIDO','Control finalizado','2026-05-10 15:00:00','15.800.001-K'),
(20,'ATENDIDO','CERRADO','Caso cerrado por resolución','2026-05-15 14:00:00','15.800.001-K'),
(23,NULL,'EN_ESPERA','Registro inicial','2026-05-20 12:00:00','15.800.003-2'),
(23,'EN_ESPERA','DERIVADO','Derivado a nutricionista previo','2026-06-25 09:00:00','15.800.003-2'),
(25,NULL,'EN_ESPERA','Registro inicial','2026-01-10 08:00:00','15.800.002-1'),
(25,'EN_ESPERA','VENCIDO','Plazo GES vencido sin atención','2026-04-10 08:00:00','15.800.002-1');

SET FOREIGN_KEY_CHECKS = 1;
