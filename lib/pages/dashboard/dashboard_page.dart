import 'package:expense_tracker/components/user_drawer.dart';
import 'package:expense_tracker/models/carteira.dart';
import 'package:expense_tracker/models/tipo_transacao.dart';
import 'package:expense_tracker/models/transacao.dart';
import 'package:expense_tracker/repository/carteira_repository.dart';
import 'package:expense_tracker/repository/transacoes_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  final transacoesRepo = TransacoesReepository();
  final carteiraRepo = CarteiraRepository();

  late Future<List<Transacao>> futureReceitas;
  late Future<List<Transacao>> futureDespesas;
  late Future<List<Carteira>> futureCarteira;
  User? user;

  String filtragem = "por 30 dias";
  String saldo = "3000";
  DateTime? dataFiltragem = DateTime.now().subtract(const Duration(days: 30));

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;

    futureReceitas = transacoesRepo.listarTransacoes(
        userId: user?.id ?? '',
        tipoTransacao: TipoTransacao.receita,
        dataFiltragem: dataFiltragem);
    futureDespesas = transacoesRepo.listarTransacoes(
        userId: user?.id ?? '',
        tipoTransacao: TipoTransacao.despesa,
        dataFiltragem: dataFiltragem);
        
    futureCarteira = carteiraRepo.getCarteira(userId: user!.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
          actions: [
            // create a filter menu action
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: const Text('30 dias'),
                    onTap: () {
                      setState(() {
                        filtragem = "por 30 dias";
                        dataFiltragem =
                            DateTime.now().subtract(const Duration(days: 30));
                        futureReceitas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.receita,
                            dataFiltragem: dataFiltragem);
                        futureDespesas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.despesa,
                            dataFiltragem: dataFiltragem);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('60 dias'),
                    onTap: () {
                      setState(() {
                        filtragem = "por 60 dias";
                        dataFiltragem =
                            DateTime.now().subtract(const Duration(days: 60));
                        futureReceitas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.receita,
                            dataFiltragem: dataFiltragem);
                        futureDespesas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.despesa,
                            dataFiltragem: dataFiltragem);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('90 dias'),
                    onTap: () {
                      setState(() {
                        filtragem = "por 90 dias";
                        dataFiltragem =
                            DateTime.now().subtract(const Duration(days: 90));
                        futureReceitas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.receita,
                            dataFiltragem: dataFiltragem);
                        futureDespesas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.despesa,
                            dataFiltragem: dataFiltragem);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('Tudo'),
                    onTap: () {
                      setState(() {
                        filtragem = "todas as transações";
                        dataFiltragem = null;
                        futureReceitas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.receita);
                        futureDespesas = transacoesRepo.listarTransacoes(
                            userId: user?.id ?? '',
                            tipoTransacao: TipoTransacao.despesa);
                      });
                    },
                  ),
                ];
              },
            ),
          ],
        ),
        drawer: const UserDrawer(),
        floatingActionButton: FloatingActionButton(
          heroTag: "dashboard-config",
          onPressed: () async {

            Navigator.pushNamed(context, '/dashboard-config').then((res) => refreshState());

          },
          child: const Icon(Icons.wallet),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const SizedBox(width: 20),
                const Text('Saldo: ',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                        
                FutureBuilder(
                  future: futureCarteira,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Erro ao carregar o saldo", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("ainda não cadastrado", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                      );
                    } else {
                      final saldo = snapshot.data!.first.saldo.toString();
                      return Center(
                        child: Text("R\$ $saldo", style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                      );
                    }
                  }),
              ]),
              Row(children: [
                const SizedBox(width: 20),
                Text('Filtrando $filtragem'),
              ]),
              FutureBuilder(
                  future: futureReceitas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Erro ao carregar o dashboard"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Nenhuma transação cadastrada"),
                      );
                    } else {
                      final transacoes = snapshot.data!;
                      return Center(
                        child: SizedBox(
                            width: 500,
                            child: SfCircularChart(
                              title: ChartTitle(
                                  text:
                                      'Receitas | Total: ${getTotal(transacoes)}',
                                  textStyle:
                                      const TextStyle(color: Colors.green)),
                              legend: const Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              series: <CircularSeries>[
                                PieSeries<Transacao, String>(
                                  dataLabelSettings:
                                      const DataLabelSettings(isVisible: true),
                                  dataSource: transacoes,
                                  xValueMapper: (Transacao transacao, _) =>
                                      transacao.descricao,
                                  yValueMapper: (Transacao transacao, _) =>
                                      transacao.valor,
                                )
                              ],
                            )),
                      );
                    }
                  }),
              const SizedBox(height: 30),
              FutureBuilder(
                  future: futureDespesas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Erro ao carregar o dashboard"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Nenhuma transação cadastrada"),
                      );
                    } else {
                      final transacoes = snapshot.data!;
                      return Center(
                        child: SizedBox(
                            width: 500,
                            child: SfCircularChart(
                              title: ChartTitle(
                                  text:
                                      'Despesas | Total: ${getTotal(transacoes)}',
                                  textStyle: const TextStyle(color: Colors.pink)),
                              legend: const Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              series: <CircularSeries>[
                                PieSeries<Transacao, String>(
                                  dataLabelSettings:
                                      const DataLabelSettings(isVisible: true),
                                  dataSource: transacoes,
                                  xValueMapper: (Transacao transacao, _) =>
                                      transacao.descricao,
                                  yValueMapper: (Transacao transacao, _) =>
                                      transacao.valor,
                                )
                              ],
                            )),
                      );
                    }
                  }),
            ],
          ),
        ));
  }

  double getTotal(List<Transacao> t) {
    double total = t.map((e) => e.valor).fold(0, (p, a) => p + a);
    return total;
  }
  
  refreshState() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureCarteira = carteiraRepo.getCarteira(userId: user!.id);
      });
    });
  }
}
