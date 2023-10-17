import 'package:expense_tracker/models/carteira.dart';
import 'package:expense_tracker/repository/carteira_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CarteiraCadastroPage extends StatefulWidget {
  const CarteiraCadastroPage({super.key});

  @override
  State<CarteiraCadastroPage> createState() => _CarteiraCadastroPageState();
}

class _CarteiraCadastroPageState extends State<CarteiraCadastroPage> {
  User? user;

  final carteirasRepo = CarteiraRepository();

  final saldoController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Carteira'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSaldo(),
                const SizedBox(height: 30),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildSaldo() {
    return TextFormField(
      controller: saldoController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Informe o saldo',
        labelText: 'Saldo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Ionicons.cash_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe um saldo';
        }
        final saldo = NumberFormat.currency(locale: 'pt_BR')
            .parse(saldoController.text.replaceAll('R\$', ''));
        if (saldo <= 0) {
          return 'Informe um saldo maior que zero';
        }

        return null;
      },
    );
  }

  SizedBox _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          if (isValid) {
            // saldo
            final saldo = NumberFormat.currency(locale: 'pt_BR')
                .parse(saldoController.text.replaceAll('R\$', ''));

            final userId = user?.id ?? '';

            final carteira = Carteira(
              id: 0,
              userId: userId,
              saldo: saldo.toDouble(),
            );

            await _updateCarteira(carteira);
          }
        },
        child: const Text('Atualizar'),
      ),
    );
  }

  Future<void> _updateCarteira(Carteira carteira) async {
    final scaffold = ScaffoldMessenger.of(context);

    await carteirasRepo.cadastrarCarteira(carteira).then((_) {
      // Mensagem de Sucesso
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Saldo atualizado com sucesso',
        ),
      ));
      Navigator.of(context).pop(true);
    }).catchError((error) {
      // Mensagem de Erro
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Erro ao atualizar Saldo',
        ),
      ));

      Navigator.of(context).pop(true);
    });
  }





}