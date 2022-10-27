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

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(_formData.isEmpty){
      final product = ModalRoute.of(context)?.settings.arguments as Product?;
      if(product != null){
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

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();

      Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(_formData);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de produto'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
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
                    return 'Nome é obrigatório';
                  }

                  if (name.length < 3) {
                    return 'Nome precisa de no mínimo três letras';
                  }

                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['price']?.toString(),
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                onSaved: (value) => _formData['price'] = value ?? '0',
                validator: (value) {
                  final price = double.tryParse(value ?? '0') ?? -1;

                  if (price <= 0) {
                    return 'Informe um preço válido';
                  }

                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['description']?.toString(),
                decoration: const InputDecoration(labelText: 'Descrição'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onSaved: (value) => _formData['description'] = value ?? '',
                validator: (value) {
                  final description = value ?? '';

                  if (description.trim().isEmpty) {
                    return 'Descrição é obrigatória';
                  }

                  if (description.length < 3) {
                    return 'Descrição precisa de no mínimo três letras';
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
                      onSaved: (value) => _formData['imageUrl'] = value ?? '',
                      validator: (value) {
                        final imageUrl = value ?? '';

                        if (!_isValidImageUrl(imageUrl)) {
                          return 'Informe uma URL válida';
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
