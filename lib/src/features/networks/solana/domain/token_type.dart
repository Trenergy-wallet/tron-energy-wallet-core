import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';

/// Enumeration of supported token program types in the Solana network.
///
/// Used to identify the token standard (classic SPL or Token-2022)
/// based on the owner program of its mint account.
enum SolTokenType {
  /// The classic Solana token standard (SPL Token Program)
  splToken('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),

  /// The new token standard with extensions (Token-2022 / Token Extensions)
  splToken2022('TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb'),

  /// Unknown or unsupported token program type
  unknown('')
  ;

  /// Constructor to initialize the enum element with a string program address
  const SolTokenType(this._program);

  /// Factory method to determine the token standard by its owner
  /// program address.
  ///
  /// Accepts [owner] (the program address retrieved from the RPC
  /// getAccountInfo response).
  /// If the owner matches a known contract, it returns the corresponding type.
  /// If [owner] is null or does not match any constants,
  /// it returns [SolTokenType.unknown].
  factory SolTokenType.fromOwner(SolAddress? owner) {
    final selected = SolTokenType.values.firstWhere(
      (e) => e._program == owner?.address,
      orElse: () => .unknown,
    );
    return selected;
  }

  /// Internal string representation of the program's smart contract address
  final String _program;

  /// Returns the [SolAddress] object for the corresponding token program.
  ///
  /// Throws an [AppException] with the [ExceptionCode.wrongToken] code
  /// if this method is called on the [SolTokenType.unknown] element
  SolAddress get programId {
    if (this == unknown) {
      throw AppException(message: 'Unknown token program', code: .wrongToken);
    }
    return SolAddress.unchecked(_program);
  }

  /// Returns `true` if the token complies with the new Token-2022 standard
  bool get isToken2022 => this == SolTokenType.splToken2022;

  /// Returns `true` if the token complies with the classic SPL Token standard
  bool get isSplToken => this == SolTokenType.splToken;

  /// Returns `true` if the token program type is undefined
  bool get isUnknown => this == unknown;
}
