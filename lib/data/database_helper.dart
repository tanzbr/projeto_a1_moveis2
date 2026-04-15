import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/receita.dart';
import 'receitas_data.dart' as seed;

class DatabaseHelper {
  static Database? _db;

  static Future<Database> getDatabase() async {
    _db ??= await _abrir();
    return _db!;
  }

  static Future<Database> _abrir() async {
    final caminho = kIsWeb
        ? 'receitas.db'
        : p.join(await getDatabasesPath(), 'receitas.db');
    return openDatabase(
      caminho,
      version: 2,
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

        // seed inicial
        for (final r in seed.receitasSeed) {
          await db.insert('receitas', r.toMap());
        }
      }
    );
  }

  static Future<List<Receita>> listarReceitas() async {
    final db = await getDatabase();
    final rows = await db.query('receitas', orderBy: 'id ASC');
    return rows.map((m) => Receita.fromMap(m)).toList();
  }

  static Future<Receita?> buscarReceita(int id) async {
    final db = await getDatabase();
    final rows = await db.query('receitas', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Receita.fromMap(rows.first);
  }

  static Future<int> inserirReceita(Receita r) async {
    final db = await getDatabase();
    final map = r.toMap();
    map.remove('id');
    return db.insert('receitas', map);
  }

  static Future<int> atualizarReceita(Receita r) async {
    final db = await getDatabase();
    return db.update('receitas', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  static Future<void> salvarFavorito(int receitaId) async {
    final db = await getDatabase();
    await db.update(
        'receitas', {'favorito': 1}, where: 'id = ?', whereArgs: [receitaId]);
  }

  static Future<void> removerFavorito(int receitaId) async {
    final db = await getDatabase();
    await db.update(
        'receitas', {'favorito': 0}, where: 'id = ?', whereArgs: [receitaId]);
  }

  static Future<void> excluirReceita(int id) async {
    final db = await getDatabase();
    await db.delete('receitas', where: 'id = ?', whereArgs: [id]);
  }
}
