import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/receita.dart';
import 'receitas_data.dart' as seed;

// camada de acesso ao SQLite — todos os métodos são static (singleton simples)
class DatabaseHelper {
  // referência única ao banco; abre na 1ª chamada e reaproveita
  static Database? _db;

  static Future<Database> getDatabase() async {
    _db ??= await _abrir();
    return _db!;
  }

  static Future<Database> _abrir() async {
    // no web o caminho é só o nome do arquivo (IndexedDB);
    // no mobile/desktop é resolvido via getDatabasesPath()
    final caminho = kIsWeb
        ? 'receitas.db'
        : p.join(await getDatabasesPath(), 'receitas.db');
    return openDatabase(
      caminho,
      version: 2,
      // onCreate roda apenas na 1ª execução: cria a tabela e insere o seed.
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
            destaque INTEGER DEFAULT 0
          )
        ''');

        // popula com receitas iniciais p/ a app não abrir vazia
        for (final r in seed.receitasSeed) {
          await db.insert('receitas', r.toMap());
        }
      }
    );
  }

  // SELECT * — usado pela Home, Explorar e Favoritos
  static Future<List<Receita>> listarReceitas() async {
    final db = await getDatabase();
    final rows = await db.query('receitas', orderBy: 'id ASC');
    return rows.map((m) => Receita.fromMap(m)).toList();
  }

  // SELECT por id (tela de detalhes recarrega após editar)
  static Future<Receita?> buscarReceita(int id) async {
    final db = await getDatabase();
    final rows = await db.query('receitas', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Receita.fromMap(rows.first);
  }

  // INSERT — remove o id p/ deixar o AUTOINCREMENT do SQLite gerar
  static Future<int> inserirReceita(Receita r) async {
    final db = await getDatabase();
    final map = r.toMap();
    map.remove('id');
    return db.insert('receitas', map);
  }

  // UPDATE da linha inteira (mais simples que montar campos individuais)
  static Future<int> atualizarReceita(Receita r) async {
    final db = await getDatabase();
    return db.update('receitas', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  // DELETE definitivo (chamado a partir da tela de cadastro/edição)
  static Future<void> excluirReceita(int id) async {
    final db = await getDatabase();
    await db.delete('receitas', where: 'id = ?', whereArgs: [id]);
  }
}
