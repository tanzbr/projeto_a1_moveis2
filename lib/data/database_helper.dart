import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/receita.dart';
import 'receitas_data.dart' as seed;

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final caminho = kIsWeb
        ? 'receitas.db'
        : p.join(await getDatabasesPath(), 'receitas.db');
    return openDatabase(
      caminho,
      version: 1,
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
            destaque INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE favoritos (
            receitaId INTEGER PRIMARY KEY,
            dataAdicao TEXT NOT NULL,
            FOREIGN KEY (receitaId) REFERENCES receitas(id)
          )
        ''');

        // seed inicial
        for (final r in seed.receitasSeed) {
          await db.insert('receitas', _toMap(r));
        }
      },
    );
  }

  Map<String, dynamic> _toMap(Receita r) => {
        'id': r.id,
        'nome': r.nome,
        'descricao': r.descricao,
        'imagemUrl': r.imagemUrl,
        'tempoMinutos': r.tempoMinutos,
        'porcoes': r.porcoes,
        'dificuldade': r.dificuldade,
        'categoria': r.categoria,
        'ingredientes': jsonEncode(
          r.ingredientes
              .map((i) => {'nome': i.nome, 'quantidade': i.quantidade})
              .toList(),
        ),
        'modoPreparo': jsonEncode(r.modoPreparo),
        'destaque': r.destaque ? 1 : 0,
      };

  Receita _fromMap(Map<String, dynamic> m) {
    final ingRaw = jsonDecode(m['ingredientes'] as String) as List;
    final passosRaw = jsonDecode(m['modoPreparo'] as String) as List;
    return Receita(
      id: m['id'] as int,
      nome: m['nome'] as String,
      descricao: (m['descricao'] ?? '') as String,
      imagemUrl: (m['imagemUrl'] ?? '') as String,
      tempoMinutos: m['tempoMinutos'] as int,
      porcoes: m['porcoes'] as int,
      dificuldade: m['dificuldade'] as String,
      categoria: m['categoria'] as String,
      ingredientes: ingRaw
          .map((e) => Ingrediente(
                nome: e['nome'] as String,
                quantidade: e['quantidade'] as String,
              ))
          .toList(),
      modoPreparo: passosRaw.map((e) => e as String).toList(),
      destaque: (m['destaque'] as int) == 1,
    );
  }

  Future<List<Receita>> listarReceitas() async {
    final db = await database;
    final rows = await db.query('receitas', orderBy: 'id ASC');
    return rows.map(_fromMap).toList();
  }

  Future<Receita?> buscarReceita(int id) async {
    final db = await database;
    final rows = await db.query('receitas', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<int> inserirReceita(Receita r) async {
    final db = await database;
    final map = _toMap(r);
    map.remove('id');
    return db.insert('receitas', map);
  }

  Future<int> atualizarReceita(Receita r) async {
    final db = await database;
    return db.update(
      'receitas',
      _toMap(r),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  // ---------- Favoritos ----------
  Future<void> salvarFavorito(int receitaId) async {
    final db = await database;
    await db.insert(
      'favoritos',
      {
        'receitaId': receitaId,
        'dataAdicao': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removerFavorito(int receitaId) async {
    final db = await database;
    await db.delete('favoritos', where: 'receitaId = ?', whereArgs: [receitaId]);
  }

  Future<List<int>> listarIdsFavoritos() async {
    final db = await database;
    final rows = await db.query('favoritos');
    return rows.map((r) => r['receitaId'] as int).toList();
  }

  Future<Map<int, DateTime>> mapaDatasAdicao() async {
    final db = await database;
    final rows = await db.query('favoritos');
    return {
      for (final r in rows)
        r['receitaId'] as int:
            DateTime.tryParse(r['dataAdicao'] as String) ?? DateTime.now(),
    };
  }
}
