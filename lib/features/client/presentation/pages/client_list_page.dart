import 'package:bolo/core/widgets/empty_message_widget.dart';
import 'package:bolo/core/widgets/loading_widget.dart';
import 'package:bolo/features/client/data/models/client_model.dart';
import 'package:bolo/features/client/presentation/pages/client_form_page.dart';
import 'package:bolo/features/client/presentation/providers/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientListPage extends StatefulWidget {
  final bool selectionMode;
  const ClientListPage({super.key, this.selectionMode = false});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: Consumer<ClientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }
          if (provider.clients.isEmpty) {
            return const EmptyMessageWidget(
              icon: Icons.people_outline,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: provider.clients.length,
            itemBuilder: (context, index) {
              final client = provider.clients[index];
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                confirmDismiss: (_) => _confirmDelete(),
                onDismissed: (_) {
                  provider.deleteClient(client.id!);
                },
                child: _buildClientCard(client),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    final colorScheme = Theme.of(context).colorScheme;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Deseja excluir o cliente?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Não'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildClientCard(ClientModel client) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (widget.selectionMode) {
            Navigator.pop(context, client);
          } else {
            _openForm(client: client);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  (client.nome ?? '?')[0].toUpperCase(),
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.nome ?? '',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${client.logradouro}, ${client.numero}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${client.bairro} - ${client.cidade}, ${client.uf}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openForm({ClientModel? client}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientFormPage(client: client),
      ),
    );
    if (mounted) {
      context.read<ClientProvider>().loadClients();
    }
  }
}
