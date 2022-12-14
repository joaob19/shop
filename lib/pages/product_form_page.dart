import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlFocus = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formData = <String, Object>{};
  bool _isLoading = false;

  void _toggleLoaderIndicator() {
    setState(() => _isLoading = !_isLoading);
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final product = ModalRoute.of(context)?.settings.arguments as Product?;
      if (product != null) {
        _formData.addAll({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
        });

        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocus.removeListener(_updateImage);
    _imageUrlFocus.dispose();
  }

  void _updateImage() {
    setState(() {});
  }

  bool _isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool isPng = url.toLowerCase().endsWith('.png');
    bool isJpg = url.toLowerCase().endsWith('.jpg');
    bool isJep = url.toLowerCase().endsWith('.jpeg');
    bool endWithFile = isPng || isJpg || isJep;
    return (isValidUrl && endWithFile);
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _toggleLoaderIndicator();
      _formKey.currentState?.save();
      try {
        await Provider.of<ProductList>(
          context,
          listen: false,
        ).saveProduct(_formData);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Ocorreu um erro!'),
              content: const Text('Ocorreu um erro ao salvar o produto.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      } finally {
        _toggleLoaderIndicator();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formul??rio de produto'),
        actions: [
          IconButton(
            onPressed: () => _submitForm(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['name']?.toString(),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _formData['name'] = value ?? '',
                      validator: (value) {
                        final name = value ?? '';

                        if (name.trim().isEmpty) {
                          return 'Nome ?? obrigat??rio';
                        }

                        if (name.length < 3) {
                          return 'Nome precisa de no m??nimo tr??s letras';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      decoration: const InputDecoration(labelText: 'Pre??o'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _formData['price'] = value ?? '0',
                      validator: (value) {
                        final price = double.tryParse(value ?? '0') ?? -1;

                        if (price <= 0) {
                          return 'Informe um pre??o v??lido';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration: const InputDecoration(labelText: 'Descri????o'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      onSaved: (value) =>
                          _formData['description'] = value ?? '',
                      validator: (value) {
                        final description = value ?? '';

                        if (description.trim().isEmpty) {
                          return 'Descri????o ?? obrigat??ria';
                        }

                        if (description.length < 3) {
                          return 'Descri????o precisa de no m??nimo tr??s letras';
                        }

                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            focusNode: _imageUrlFocus,
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL da imagem',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitForm(),
                            onSaved: (value) =>
                                _formData['imageUrl'] = value ?? '',
                            validator: (value) {
                              final imageUrl = value ?? '';

                              if (!_isValidImageUrl(imageUrl)) {
                                return 'Informe uma URL v??lida';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Informe a URL')
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
