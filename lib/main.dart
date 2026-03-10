import 'package:confeito/app.dart';
import 'package:confeito/core/database/database_helper.dart';
import 'package:confeito/features/client/data/datasources/client_local_datasource.dart';
import 'package:confeito/features/client/data/repositories/client_repository.dart';
import 'package:confeito/features/client/presentation/providers/client_provider.dart';
import 'package:confeito/features/order/data/datasources/order_local_datasource.dart';
import 'package:confeito/features/order/data/repositories/order_repository.dart';
import 'package:confeito/features/order/presentation/providers/order_provider.dart';
import 'package:confeito/features/product/data/datasources/product_local_datasource.dart';
import 'package:confeito/features/product/data/repositories/product_repository.dart';
import 'package:confeito/features/product/presentation/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            ProductRepository(ProductLocalDatasource(dbHelper)),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ClientProvider(
            ClientRepository(ClientLocalDatasource(dbHelper)),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            OrderRepository(OrderLocalDatasource(dbHelper)),
          ),
        ),
      ],
      child: const ConfeitoApp(),
    ),
  );
}
