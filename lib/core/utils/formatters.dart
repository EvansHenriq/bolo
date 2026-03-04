import 'package:flutter/material.dart';

String formatCurrency(double valor) {
  int digitos = 2;
  bool isNegativo = false;

  if (valor.isNegative) {
    isNegativo = true;
    valor = valor * (-1);
  }

  String formataInteiro({required String inteiro, required String separador}) {
    String inverso = '';
    String inteiroConvertido = '';
    int j = 0;
    for (int i = inteiro.length; i > 0; i--) {
      j++;
      inverso = inverso + inteiro.substring(i - 1, i);
      if (j % 3 == 0 && i != 1) {
        inverso = inverso + separador;
      }
    }
    for (int i = inverso.length; i > 0; i--) {
      inteiroConvertido = inteiroConvertido + inverso.substring(i - 1, i);
    }
    return inteiroConvertido;
  }

  String formataValor(
      {String separadorMilhar = ',', String separadorDecimal = '.'}) {
    String valorConvertido = valor.toStringAsFixed(digitos);
    List<String> valoresSeparados = valorConvertido.split('.');
    String inteiro = valoresSeparados[0];
    String decimal = valoresSeparados[1];
    inteiro = formataInteiro(inteiro: inteiro, separador: separadorMilhar);
    if (isNegativo) {
      return '-$inteiro$separadorDecimal$decimal';
    } else {
      return '$inteiro$separadorDecimal$decimal';
    }
  }

  return 'R\$ ${formataValor(separadorDecimal: ',', separadorMilhar: '.')}';
}

InputDecoration standardInputDecoration(String label, {IconData? prefixIcon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
  );
}
