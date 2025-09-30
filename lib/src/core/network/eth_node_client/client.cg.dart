import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tron_energy_wallet_core/src/models/dto/btc_node/eth_node/send_raw_transaction_response.cg.dart'
    show SendRawTransactionResponse;

part 'gen/client.cg.g.dart';

/// RestClient
@RestApi()
abstract interface class ETHNodeClient {
  /// RestClient
  factory ETHNodeClient(Dio dio) = _ETHNodeClient;

  /// Send transaction
  @POST('/eth/{apiToken}')
  Future<SendRawTransactionResponse> sendRawTransaction({
    @Path('apiToken') required String apiToken,
    @Body() required Map<String, dynamic> body,
  });
}
