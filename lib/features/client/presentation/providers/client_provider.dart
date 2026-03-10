import 'package:flutter/foundation.dart';
import 'package:confeito/features/client/data/models/client_model.dart';
import 'package:confeito/features/client/data/repositories/client_repository.dart';

class ClientProvider extends ChangeNotifier {
  final ClientRepository _repository;

  ClientProvider(this._repository);

  List<ClientModel> _clients = [];
  List<ClientModel> get clients => _clients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadClients() async {
    _isLoading = true;
    notifyListeners();
    _clients = await _repository.getClients();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveClient(ClientModel client) async {
    await _repository.saveClient(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _repository.deleteClient(id);
    _clients.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
