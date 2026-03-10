import 'dart:convert';
import 'dart:io';

import 'package:confeito/core/utils/formatters.dart';
import 'package:confeito/core/widgets/empty_message_widget.dart';
import 'package:confeito/core/widgets/loading_widget.dart';
import 'package:confeito/features/product/data/models/product_model.dart';
import 'package:confeito/features/product/presentation/pages/product_form_page.dart';
import 'package:confeito/features/product/presentation/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatefulWidget {
  final bool selectionMode;
  const ProductListPage({super.key, this.selectionMode = false});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final Map<int, File> _imageCache = {};
  int _imageCounter = 0;
  bool _isBuildingCache = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  Future<File?> _decodeImage(String base64Str) async {
    final bytes = base64Decode(base64Str);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/foto_${_imageCounter++}.jpg');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file;
  }

  Future<void> _buildImageCache(List<ProductModel> products) async {
    if (_isBuildingCache) return;
    _isBuildingCache = true;

    bool hasNewImages = false;
    for (final product in products) {
      if (product.id != null && !_imageCache.containsKey(product.id)) {
        if (product.foto != null && product.foto!.isNotEmpty) {
          final file = await _decodeImage(product.foto!);
          if (file != null) {
            _imageCache[product.id!] = file;
            hasNewImages = true;
          }
        }
      }
    }

    _isBuildingCache = false;
    if (hasNewImages && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }
          if (provider.products.isEmpty) {
            return const EmptyMessageWidget(
              icon: Icons.shopping_bag_outlined,
            );
          }

          _buildImageCache(provider.products);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
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
                confirmDismiss: (_) => _confirmDelete(product.nome ?? ''),
                onDismissed: (_) {
                  provider.deleteProduct(product.id!);
                  _imageCache.remove(product.id);
                },
                child: _buildProductCard(product, index),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(String name) async {
    final colorScheme = Theme.of(context).colorScheme;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Deseja excluir o produto?'),
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

  Widget _buildProductCard(ProductModel product, int index) {
    final imageFile = _imageCache[product.id];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (widget.selectionMode) {
            Navigator.pop(context, product);
          } else {
            _openForm(product: product, imageFile: imageFile);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 72,
                  width: 72,
                  color: colorScheme.surfaceContainerHighest,
                  child: imageFile != null
                      ? Image.file(imageFile, fit: BoxFit.cover)
                      : Image.asset('assets/images/placeholder_product.jpeg', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nome ?? '',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.descricao ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(product.precoCusto ?? 0),
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openForm({ProductModel? product, File? imageFile}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(product: product, imageFile: imageFile),
      ),
    );
    if (mounted) {
      _imageCache.clear();
      context.read<ProductProvider>().loadProducts();
    }
  }
}
