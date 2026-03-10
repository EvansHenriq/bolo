import 'package:confeito/core/utils/formatters.dart';
import 'package:confeito/features/client/data/models/client_model.dart';
import 'package:confeito/features/client/presentation/pages/client_list_page.dart';
import 'package:confeito/features/order/data/models/order_item_model.dart';
import 'package:confeito/features/order/data/models/order_model.dart';
import 'package:confeito/features/order/presentation/providers/order_provider.dart';
import 'package:confeito/features/product/data/models/product_model.dart';
import 'package:confeito/features/product/presentation/pages/product_list_page.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderFormPage extends StatefulWidget {
  final OrderModel? order;

  const OrderFormPage({super.key, this.order});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeClienteController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _valorTotalController = MoneyMaskedTextController(
    precision: 2,
    initialValue: 0.00,
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  double _total = 0.00;
  int? _clienteId;
  DateTime _dataHoraPedido = DateTime.now();
  List<OrderItemModel> _selectedItems = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _isEditing = true;
      _clienteId = widget.order!.tbClienteId;
      _nomeClienteController.text = widget.order!.nomeCliente ?? '';
      _selectedItems =
          widget.order!.items.map((i) => i.copyWith()).toList();

      if (widget.order!.dataHora != null) {
        final dt = widget.order!.dataHora!;
        _dataHoraPedido = dt;
        _dataController.text = DateFormat.yMd('pt').format(dt);
        _horaController.text =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }

      for (final item in _selectedItems) {
        _total += (item.precoCusto ?? 0) * (item.quantidade ?? 1);
      }
      _valorTotalController.text = _total.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Pedido' : 'Novo Pedido'),
        actions: [
          IconButton(
            onPressed: _onSave,
            icon: const Icon(Icons.check),
            tooltip: 'Salvar',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valor Total:',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _valorTotalController.text,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um cliente!';
                  }
                  return null;
                },
                controller: _nomeClienteController,
                style: textTheme.bodyLarge?.copyWith(
                  color: !_isEditing
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
                decoration: standardInputDecoration('Nome do Cliente',
                    prefixIcon: Icons.person_outline),
                onTap: !_isEditing ? _selectClient : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma Data!';
                        }
                        return null;
                      },
                      controller: _dataController,
                      style: textTheme.bodyLarge,
                      decoration: standardInputDecoration('Data do Pedido',
                          prefixIcon: Icons.calendar_today_outlined),
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um Horário!';
                        }
                        return null;
                      },
                      controller: _horaController,
                      style: textTheme.bodyLarge,
                      decoration: standardInputDecoration('Horário',
                          prefixIcon: Icons.access_time_outlined),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Produto'),
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: _selectedItems.isNotEmpty,
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 350),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _selectedItems.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              _total -=
                                  (_selectedItems[index].quantidade ?? 1) *
                                      (_selectedItems[index].precoCusto ?? 0);
                              _valorTotalController.text =
                                  _total.toStringAsFixed(2);
                              _selectedItems.removeAt(index);
                            });
                          },
                          child: _buildItemWidget(index),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemWidget(int index) {
    final item = _selectedItems[index];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome ?? '',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.descricao ?? '',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatCurrency(item.precoCusto ?? 0),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filled(
                onPressed: (item.quantidade ?? 1) > 1
                    ? () {
                        setState(() {
                          item.quantidade = (item.quantidade ?? 1) - 1;
                        });
                        _updateTotal(-(item.precoCusto ?? 0));
                      }
                    : null,
                icon: const Icon(Icons.remove, size: 20),
                style: IconButton.styleFrom(
                  minimumSize: const Size(36, 36),
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  disabledBackgroundColor:
                      colorScheme.surfaceContainerHighest,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantidade ?? 1}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    item.quantidade = (item.quantidade ?? 1) + 1;
                  });
                  _updateTotal(item.precoCusto ?? 0);
                },
                icon: const Icon(Icons.add, size: 20),
                style: IconButton.styleFrom(
                  minimumSize: const Size(36, 36),
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateTotal(double value) {
    setState(() {
      _total += value;
      _valorTotalController.text = _total.toStringAsFixed(2);
    });
  }

  Future<void> _selectClient() async {
    final client = await Navigator.push<ClientModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const ClientListPage(selectionMode: true),
      ),
    );
    if (client != null) {
      setState(() {
        _clienteId = client.id;
        _nomeClienteController.text = client.nome ?? '';
      });
    }
  }

  Future<void> _selectDate() async {
    final data = await showDatePicker(
      locale: const Locale('pt', 'PT'),
      initialEntryMode: DatePickerEntryMode.calendar,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() {
        _dataHoraPedido = DateTime(data.year, data.month, data.day);
        _dataController.text =
            DateFormat.yMd('pt').format(_dataHoraPedido);
      });
    }
  }

  Future<void> _selectTime() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _horaController.text = hora.format(context);
      });
    }
  }

  Future<void> _addProduct() async {
    final product = await Navigator.push<ProductModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductListPage(selectionMode: true),
      ),
    );
    if (product != null) {
      setState(() {
        _selectedItems.add(OrderItemModel(
          nome: product.nome,
          descricao: product.descricao,
          precoCusto: product.precoCusto,
          quantidade: 1,
        ));
        _updateTotal(product.precoCusto ?? 0);
      });
    }
  }

  Future<void> _onSave() async {
    if (_selectedItems.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Selecione no mínimo 1 produto!'),
          actions: [
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(ctx);
                _addProduct();
              },
              child: const Text('Selecionar'),
            ),
          ],
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Parse date and time
    final dateParts = _dataController.text;
    final timeParts = _horaController.text;
    final dateTimeStr = '$dateParts $timeParts';
    DateTime dateTime;
    try {
      dateTime = DateFormat.yMd('pt').add_Hm().parse(dateTimeStr);
    } catch (_) {
      dateTime = _dataHoraPedido;
    }

    final order = OrderModel(
      id: widget.order?.id,
      nomeCliente: _nomeClienteController.text,
      dataHora: dateTime,
      valorTotal: _valorTotalController.numberValue,
      tbClienteId: _clienteId,
      items: _selectedItems,
    );

    await context.read<OrderProvider>().saveOrder(order);
    if (mounted) Navigator.pop(context);
  }
}
