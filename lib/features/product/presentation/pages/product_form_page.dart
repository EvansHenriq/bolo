import 'dart:convert';
import 'dart:io';

import 'package:confeito/core/utils/formatters.dart';
import 'package:confeito/features/product/data/models/product_model.dart';
import 'package:confeito/features/product/presentation/providers/product_provider.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;
  final File? imageFile;

  const ProductFormPage({super.key, this.product, this.imageFile});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = MoneyMaskedTextController(
    precision: 2,
    initialValue: 0.0,
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  File? _imageFile;
  int _imageCounter = 0;
  bool _photoRemoved = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nomeController.text = widget.product!.nome ?? '';
      _descricaoController.text = widget.product!.descricao ?? '';
      _valorController.text =
          widget.product!.precoCusto?.toStringAsFixed(2) ?? '';
      _imageFile =
          widget.imageFile?.path.isNotEmpty == true ? widget.imageFile : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
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
              Center(
                child: GestureDetector(
                  onTap: () => _showPicker(context),
                  child: Stack(
                    children: [
                      Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: colorScheme.surfaceContainerHighest,
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Adicionar foto',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      if (_imageFile != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _removePhoto,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: colorScheme.onError,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome não preenchido!';
                  }
                  if (value.length < 3) {
                    return 'Nome deve ter no mínimo 3 caracteres!';
                  }
                  if (value.length > 50) {
                    return 'Nome deve ter no máximo 50 caracteres!';
                  }
                  return null;
                },
                controller: _nomeController,
                style: textTheme.bodyLarge,
                decoration: standardInputDecoration('Nome'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Descrição não preenchido!';
                  }
                  if (value.length > 100) {
                    return 'Descricao deve ter no máximo 100 caracteres!';
                  }
                  return null;
                },
                controller: _descricaoController,
                style: textTheme.bodyLarge,
                decoration: standardInputDecoration('Descrição'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value == 'R\$ 0,00') {
                    return 'Valor não preenchido!';
                  }
                  return null;
                },
                controller: _valorController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: standardInputDecoration('Valor'),
                keyboardType: TextInputType.number,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _imageFile = null;
      _photoRemoved = true;
    });
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeria'),
                onTap: () {
                  _pickFromGallery();
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () {
                  FocusScope.of(ctx).unfocus();
                  _pickFromCamera();
                  Navigator.of(ctx).pop();
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remover foto'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final photos = await picker.pickMultiImage(
      maxHeight: 1080,
      maxWidth: 1080,
      imageQuality: 80,
    );
    if (photos.isNotEmpty) {
      await _savePhoto(photos);
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    setState(() => _imageFile = null);
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (photo != null) {
      await _savePhoto([photo]);
    }
  }

  Future<void> _savePhoto(List<XFile> photos) async {
    final dir = await getApplicationDocumentsDirectory();
    for (final photo in photos) {
      final file = File(photo.path);
      _imageFile =
          await file.copy('${dir.path}/foto_${_imageCounter++}.jpg');
      if (file.existsSync()) await file.delete();
      _photoRemoved = false;
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    String? foto;
    if (_imageFile != null) {
      foto = base64.encode(_imageFile!.readAsBytesSync());
    } else if (!_photoRemoved) {
      foto = widget.product?.foto;
    }

    final product = ProductModel(
      id: widget.product?.id,
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      precoCusto: _valorController.numberValue,
      foto: foto,
    );

    await context.read<ProductProvider>().saveProduct(product);
    if (mounted) Navigator.pop(context);
  }
}
