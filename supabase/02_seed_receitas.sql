-- Seed inicial para a tabela receitas. Roda uma vez apos 01_receitas.sql.
-- `imagem_url` aponta para os assets do app (mesmo caminho do seed antigo).

insert into public.receitas
  (nome, descricao, imagem_url, tempo_minutos, porcoes, dificuldade, categoria, ingredientes, modo_preparo, destaque)
values
  (
    'Macarrão ao Alho e Óleo',
    'Rápido, fácil e delicioso para o dia a dia.',
    'assets/images/macarrao-alho-e-oleo.jpg',
    15, 2, 'Fácil', 'Jantar',
    '[
      {"nome":"Macarrão","quantidade":"200g"},
      {"nome":"Alho","quantidade":"4 dentes"},
      {"nome":"Azeite","quantidade":"4 colheres"},
      {"nome":"Salsinha","quantidade":"a gosto"},
      {"nome":"Sal e pimenta","quantidade":"a gosto"}
    ]'::jsonb,
    '[
      "Cozinhe o macarrão conforme as instruções da embalagem.",
      "Em uma frigideira, aqueça o azeite e doure o alho fatiado.",
      "Adicione o macarrão escorrido e misture bem.",
      "Finalize com salsinha, sal e pimenta a gosto."
    ]'::jsonb,
    true
  ),
  (
    'Omelete de Queijo',
    'Café da manhã proteico em menos de 10 minutos.',
    'assets/images/omelete-de-queijo.jpg',
    10, 1, 'Fácil', 'Café da Manhã',
    '[
      {"nome":"Ovos","quantidade":"3 unidades"},
      {"nome":"Queijo mussarela","quantidade":"50g"},
      {"nome":"Sal","quantidade":"a gosto"},
      {"nome":"Manteiga","quantidade":"1 colher"}
    ]'::jsonb,
    '[
      "Bata os ovos com sal em uma tigela.",
      "Derreta a manteiga em frigideira antiaderente.",
      "Despeje os ovos e cozinhe em fogo médio.",
      "Adicione o queijo antes de dobrar a omelete.",
      "Dobre ao meio e sirva quente."
    ]'::jsonb,
    true
  ),
  (
    'Frango Grelhado com Limão',
    'Proteína magra temperada com ervas e limão.',
    'assets/images/frango-grelhado-com-limao.jpg',
    20, 2, 'Médio', 'Almoço',
    '[
      {"nome":"Filé de frango","quantidade":"2 unidades"},
      {"nome":"Limão","quantidade":"1 unidade"},
      {"nome":"Alho","quantidade":"2 dentes"},
      {"nome":"Azeite","quantidade":"2 colheres"},
      {"nome":"Sal e pimenta","quantidade":"a gosto"},
      {"nome":"Orégano","quantidade":"a gosto"}
    ]'::jsonb,
    '[
      "Tempere o frango com limão, alho, sal, pimenta e orégano.",
      "Deixe marinar por 10 minutos.",
      "Aqueça uma grelha com azeite em fogo alto.",
      "Grelhe o frango por 5-7 minutos de cada lado."
    ]'::jsonb,
    true
  ),
  (
    'Salada Caesar',
    'Clássico da culinária americana, fresco e saboroso.',
    'assets/images/salada-caesar.jpg',
    10, 2, 'Fácil', 'Almoço',
    '[
      {"nome":"Alface romana","quantidade":"1 pé"},
      {"nome":"Croutons","quantidade":"1 xícara"},
      {"nome":"Parmesão ralado","quantidade":"50g"},
      {"nome":"Molho Caesar","quantidade":"4 colheres"}
    ]'::jsonb,
    '[
      "Lave e rasgue a alface em pedaços.",
      "Misture o molho Caesar com a alface.",
      "Adicione os croutons e o parmesão.",
      "Sirva imediatamente."
    ]'::jsonb,
    false
  ),
  (
    'Ovos Mexidos',
    'Cremoso e rápido, perfeito para o café da manhã.',
    'assets/images/ovo-mexido.jpg',
    8, 1, 'Fácil', 'Café da Manhã',
    '[
      {"nome":"Ovos","quantidade":"3 unidades"},
      {"nome":"Manteiga","quantidade":"1 colher"},
      {"nome":"Sal e pimenta","quantidade":"a gosto"},
      {"nome":"Cebolinha","quantidade":"a gosto"}
    ]'::jsonb,
    '[
      "Bata os ovos com sal e pimenta.",
      "Derreta a manteiga em fogo baixo.",
      "Adicione os ovos e mexa lentamente.",
      "Retire antes de firmar completamente.",
      "Finalize com cebolinha picada."
    ]'::jsonb,
    false
  ),
  (
    'Vitamina de Banana',
    'Energética e nutritiva, pronta em 5 minutos.',
    'assets/images/vitamina-banana.jpg',
    5, 1, 'Fácil', 'Lanches',
    '[
      {"nome":"Banana","quantidade":"2 unidades"},
      {"nome":"Leite","quantidade":"200ml"},
      {"nome":"Mel","quantidade":"1 colher"},
      {"nome":"Canela","quantidade":"a gosto"}
    ]'::jsonb,
    '[
      "Descasque as bananas e corte em pedaços.",
      "Bata no liquidificador com o leite e o mel.",
      "Polvilhe canela por cima.",
      "Sirva gelado."
    ]'::jsonb,
    true
  );
