import 'package:flutter/material.dart';

class ContributionScreen extends StatelessWidget {
  const ContributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _ingredientsController = TextEditingController();
    final _instructionsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribute Recipe',
            style: TextStyle(color: Color(0xFF4B0082))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredients'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter ingredients' : null,
              ),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter instructions' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Recipe submitted for review!')));
                    _nameController.clear();
                    _ingredientsController.clear();
                    _instructionsController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B0082)),
                child:
                    const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
