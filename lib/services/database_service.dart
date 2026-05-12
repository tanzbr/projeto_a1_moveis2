import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/receita.dart';
import 'receitas_seed.dart' as seed;

// camada de acesso ao SQLite — singleton simples no padrão MVCS
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _abrir();
    return _database!;
  }

  Future<Database> _abrir() async {
    // no web o caminho é só o nome do arquivo (IndexedDB);
    // no mobile/desktop é resolvido via getDatabasesPath()
    final caminho = kIsWeb
        ? 'receitas.db'
        : p.join(await getDatabasesPath(), 'receitas.db');
    return openDatabase(
      caminho,
      version: 2,
      // onCreate roda apenas na 1ª execução: cria a tabela e insere o seed.
      // Optei por `favorito` como coluna (e não tabela separada) p/ simplificar.
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE receitas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT,
            imagemUrl TEXT,
            tempoMinutos INTEGER,
            porcoes INTEGER,
            dificuldade TEXT,
            categoria TEXT,
            ingredientes TEXT,
            modoPreparo TEXT,
            destaque INTEGER DEFAULT 0,
            favorito INTEGER DEFAULT 0
          )
        ''');

        // popula com receitas iniciais p/ a app não abrir vazia
        for (final r in seed.receitasSeed) {
          await db.insert('receitas', r.toMap());
        }
      },
    );
  }

  Future<List<Receita>> listarReceitas() async {
    final db = await database;
    final rows = await db.query('receitas', orderBy: 'id ASC');
    return rows.map((m) => Receita.fromMap(m)).toList();
  }

  Future<Receita?> buscarReceita(int id) async {
    final db = await database;
    final rows = await db.query('receitas', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Receita.fromMap(rows.first);
  }

  Future<int> inserirReceita(Receita r) async {
    final db = await database;
    final map = r.toMap();
    map.remove('id');
    return db.insert('receitas', map);
  }

  Future<int> atualizarReceita(Receita r) async {
    final db = await database;
    return db.update('receitas', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<void> salvarFavorito(int receitaId) async {
    final db = await database;
    await db.update(
      'receitas',
      {'favorito': 1},
      where: 'id = ?',
      whereArgs: [receitaId],
    );
  }

  Future<void> removerFavorito(int receitaId) async {
    final db = await database;
    await db.update(
      'receitas',
      {'favorito': 0},
      where: 'id = ?',
      whereArgs: [receitaId],
    );
  }

  Future<void> excluirReceita(int id) async {
    final db = await database;
    await db.delete('receitas', where: 'id = ?', whereArgs: [id]);
  }
}
