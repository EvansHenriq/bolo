import 'package:bolo/core/utils/formatters.dart';
import 'package:bolo/features/client/data/models/client_model.dart';
import 'package:bolo/features/client/presentation/providers/client_provider.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientFormPage extends StatefulWidget {
  final ClientModel? client;

  const ClientFormPage({super.key, this.client});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = MaskedTextController(mask: 'AA');

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nomeController.text = widget.client!.nome ?? '';
      _logradouroController.text = widget.client!.logradouro ?? '';
      _numeroController.text = widget.client!.numero ?? '';
      _complementoController.text = widget.client!.complemento ?? '';
      _bairroController.text = widget.client!.bairro ?? '';
      _cidadeController.text = widget.client!.cidade ?? '';
      _ufController.text = widget.client!.uf ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.client != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                controller: _nomeController,
                label: 'Nome do Contato',
                prefixIcon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Nome do Contato não preenchido!';
                  }
                  if (v.length < 3) {
                    return 'Nome do Contato deve ter no mínimo 3 caracteres!';
                  }
                  if (v.length > 50) {
                    return 'Nome do Contato deve ter no máximo 50 caracteres!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _logradouroController,
                label: 'Logradouro',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Logradouro não preenchido!';
                  }
                  if (v.length < 3) {
                    return 'Logradouro deve ter no mínimo 3 caracteres!';
                  }
                  if (v.length > 50) {
                    return 'Logradouro deve ter no máximo 50 caracteres!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildField(
                      controller: _numeroController,
                      label: 'Número',
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Número não preenchido!';
                        }
                        if (v.length > 10) {
                          return 'Número deve ter no máximo 10 caracteres!';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildField(
                      controller: _complementoController,
                      label: 'Complemento',
                      validator: (v) {
                        if (v != null && v.length > 50) {
                          return 'Complemento deve ter no máximo 50 caracteres!';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _bairroController,
                label: 'Bairro',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bairro não preenchido!';
                  if (v.length < 3) {
                    return 'Bairro deve ter no mínimo 3 caracteres!';
                  }
                  if (v.length > 30) {
                    return 'Bairro deve ter no máximo 30 caracteres!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildField(
                      controller: _cidadeController,
                      label: 'Cidade',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Cidade não preenchida!';
                        }
                        if (v.length < 3) {
                          return 'Cidade deve ter no mínimo 3 caracteres!';
                        }
                        if (v.length > 50) {
                          return 'Cidade deve ter no máximo 50 caracteres!';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _ufController,
                      style: textTheme.bodyLarge,
                      decoration: standardInputDecoration('UF'),
                      onChanged: (text) {
                        _ufController.text = text.toUpperCase();
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'UF não preenchido!';
                        }
                        if (v.length != 2) {
                          return 'UF deve ter exatamente 2 caracteres!';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: standardInputDecoration(label, prefixIcon: prefixIcon),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final client = ClientModel(
      id: widget.client?.id,
      nome: _nomeController.text,
      logradouro: _logradouroController.text,
      numero: _numeroController.text,
      complemento: _complementoController.text,
      bairro: _bairroController.text,
      cidade: _cidadeController.text,
      uf: _ufController.text,
    );

    await context.read<ClientProvider>().saveClient(client);
    if (mounted) Navigator.pop(context);
  }
}
