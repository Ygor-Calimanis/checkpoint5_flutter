import 'package:expense_tracker/models/carteira.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CarteiraRepository {
  Future<List<Carteira>> getCarteira({required String userId}) async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('carteiras')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', userId);

    final carteiras = data.map((e) => Carteira.fromMap(e)).toList();

    return carteiras;
  }

  Future cadastrarCarteira(Carteira carteira) async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('carteiras')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', carteira.userId);
    final exists = data.isNotEmpty;

    if (exists) {
      alterarCarteira(carteira);
    } 

    else {
      await supabase
          .from('carteiras')
          .insert({'user_id': carteira.userId, 'saldo': carteira.saldo});
    }
  }

  Future alterarCarteira(Carteira carteira) async {
    final supabase = Supabase.instance.client;

    await supabase.from('carteiras').update({
      'saldo': carteira.saldo,
    }).match({'user_id': carteira.userId});
  }

  Future excluirCarteira(Carteira carteira) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('carteiras')
        .delete()
        .match({'user_id': carteira.userId});
  }
}
