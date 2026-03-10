import 'package:confeito/features/client/data/datasources/client_local_datasource.dart';
import 'package:confeito/features/client/data/models/client_model.dart';

class ClientRepository {
  final ClientLocalDatasource _datasource;

  ClientRepository(this._datasource);

  Future<List<ClientModel>> getClients() => _datasource.getAll();
  Future<ClientModel?> getClient(int id) => _datasource.getById(id);

  Future<int> saveClient(ClientModel client) {
    if (client.id != null) {
      return _datasource.update(client);
    }
    return _datasource.insert(client);
  }

  Future<int> deleteClient(int id) => _datasource.softDelete(id);
}
