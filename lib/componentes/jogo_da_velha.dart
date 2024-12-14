import 'dart:math';
import 'package:flutter/material.dart';

class JogoDaVelha extends StatefulWidget {
  const JogoDaVelha({super.key});

  @override
  State<JogoDaVelha> createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> _tabuleiro = List.filled(9, '');
  String _jogador = 'X';
  bool _contraMaquina = false;
  bool _pensando = false;
  final Random _randomico = Random();

  void _iniciarJogo() {
    setState(() {
      _tabuleiro = List.filled(9, '');
      _jogador = 'X';
    });
  }

  void _trocaJogador() {
    setState(() {
      _jogador = _jogador == 'X' ? 'O' : 'X';
    });
  }

  void _mostreDialogoVencedor(String vencedor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vencedor == 'Empate' ? 'O jogo empatou!' : 'O $vencedor foi o vencedor'),
          actions: [
            ElevatedButton(
              child: const Text('Reiniciar Jogo'),
              onPressed: () {
                Navigator.of(context).pop();
                _iniciarJogo();
              },
            ),
          ],
        );
      },
    );
  }

  bool _verificaVencedor(String jogador) {
    const posicoesVencedoras = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var posicoes in posicoesVencedoras) {
      if (_tabuleiro[posicoes[0]] == jogador &&
          _tabuleiro[posicoes[1]] == jogador &&
          _tabuleiro[posicoes[2]] == jogador) {
        _mostreDialogoVencedor(jogador);
        return true;
      }
    }
    if (!_tabuleiro.contains('')) {
      _mostreDialogoVencedor('Empate');
      return true;
    }
    return false;
  }

int _posicaoVencedora(String jogador) {
    const posicoesVencedoras = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var posicoes in posicoesVencedoras) {
      final valores = posicoes.map((pos) => _tabuleiro[pos]).toList();
      if (valores.where((valor) => valor == jogador).length == 2 &&
          valores.contains('')) {
        return posicoes[valores.indexOf('')];
      }
    }
    return -1;
  }

  void _realizaJogada(int movimento) {
    setState(() {
      _tabuleiro[movimento] = 'O';
      if (!_verificaVencedor('O')) {
        _trocaJogador();
      }
      _pensando = false;
    });
  }

  void _jogadaComputador() {
  setState(() => _pensando = true);
  Future.delayed(const Duration(seconds: 1), () {
    int movimento;

    movimento = _posicaoVencedora('O');
    if (movimento != -1) {
      _realizaJogada(movimento);
      return;
    }
    movimento = _posicaoVencedora('X');
    if (movimento != -1) {
      _realizaJogada(movimento);
      return;
    }
    List<int> posicoesDisponiveis = [];
    for (int i = 0; i < _tabuleiro.length; i++) {
      if (_tabuleiro[i] == '') {
        posicoesDisponiveis.add(i);
      }
    }

    if (posicoesDisponiveis.isNotEmpty) {
      movimento = posicoesDisponiveis[_randomico.nextInt(posicoesDisponiveis.length)];
      _realizaJogada(movimento);
    }
  });
}
  void _jogada(int index) {
    if (_tabuleiro[index] == '') {
      setState(() {
        _tabuleiro[index] = _jogador;
        if (!_verificaVencedor(_jogador)) {
          _trocaJogador();
          if (_contraMaquina && _jogador == 'O') {
            _jogadaComputador();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double altura = MediaQuery.of(context).size.height * 0.5;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: _contraMaquina,
                  onChanged: (value) {
                    setState(() {
                      _contraMaquina = value;
                      _iniciarJogo();
                    });
                  },
                ),
              ),
              Text(_contraMaquina ? 'Computador' : 'Humano'),
              const SizedBox(width: 30.0),
              if (_pensando)
                const SizedBox(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: SizedBox(
            width: altura,
            height: altura,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _jogada(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        _tabuleiro[index],
                        style: const TextStyle(fontSize: 40.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: _iniciarJogo,
            child: const Text('Reiniciar o jogo'),
          ),
        ),
      ],
    );
  }
}