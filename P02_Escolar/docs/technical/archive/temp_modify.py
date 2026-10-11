from pathlib import Path

p = Path('03_Stess_Test.sql')
txt = p.read_text(encoding='utf-8')
repl = {
    "    @MaxRuns INT = 3,                                           -- Número de ejecuciones completas máximo de runs encadenados (opcional)\n": "    @MaxRuns INT = 1,                                           -- Número de ejecuciones completas máximo de runs encadenados (opcional)\n",
    "    @BatchSize INT = 500,                                       -- Parámetros de stress inserción masiva Tamaño de lote para operaciones pesadas.\n": "    @BatchSize INT = 1,                                       -- Parámetros de stress inserción masiva Tamaño de lote para operaciones pesales.\n",
    "    @MaxIters INT = 100,                                        -- Límite de iteraciones por run.\n": "    @MaxIters INT = 1,                                        -- Límite de iteraciones por run.\n",
    "    @TargetNewProf INT = 500,                                   -- objetivo total de nuevos profesores a crear en este run\n": "    @TargetNewProf INT = 1,                                   -- objetivo total de nuevos profesores a crear en este run\n",
    "    @TargetNewAlu INT = 5000,                                   -- objetivo total de alumnos a crear en este run\n": "    @TargetNewAlu INT = 1,                                   -- objetivo total de alumnos a crear en este run\n",
    "    @TargetInscripciones INT = 50000,                           -- Objetivo total de inscripciones por run.\n": "    @TargetInscripciones INT = 1,                           -- Objetivo total de inscripciones por run.\n",
    "    @PauseBetweenBatches VARCHAR(8) = '00:00:01';               -- Pausa entre lotes para reducir presión en el log y evitar timeouts Formato hh:mm:ss.\n": "    @PauseBetweenBatches VARCHAR(8) = '00:00:00';               -- Pausa entre lotes para reducir presión en el log y evitar timeouts Formato hh:mm:ss.\n",
}
for old, new in repl.items():
    txt = txt.replace(old, new)
Path('temp_stress_fast.sql').write_text(txt, encoding='utf-8')
print('WROTE', Path('temp_stress_fast.sql').exists())
