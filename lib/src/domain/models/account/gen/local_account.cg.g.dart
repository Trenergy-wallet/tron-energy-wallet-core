// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../local_account.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalAccount _$LocalAccountFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_LocalAccount',
      json,
      ($checkedConvert) {
        final val = _LocalAccount(
          name: $checkedConvert('name', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String),
          iconPath: $checkedConvert('icon_path', (v) => v as String),
          iconColorBg: $checkedConvert('icon_color_bg', (v) => v as String),
          address: $checkedConvert('address', (v) => v as String),
          publicKey: $checkedConvert('public_key', (v) => v as String),
          token: $checkedConvert('token', (v) => v as String),
          useFavorite: $checkedConvert(
            'use_favorite',
            (v) => v as bool? ?? false,
          ),
          hasWalletRights: $checkedConvert(
            'has_wallet_rights',
            (v) => v as bool? ?? false,
          ),
          useShowPartnerPromo: $checkedConvert(
            'use_show_partner_promo',
            (v) => v as bool? ?? true,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'iconPath': 'icon_path',
        'iconColorBg': 'icon_color_bg',
        'publicKey': 'public_key',
        'useFavorite': 'use_favorite',
        'hasWalletRights': 'has_wallet_rights',
        'useShowPartnerPromo': 'use_show_partner_promo',
      },
    );

Map<String, dynamic> _$LocalAccountToJson(_LocalAccount instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'icon_path': instance.iconPath,
      'icon_color_bg': instance.iconColorBg,
      'address': instance.address,
      'public_key': instance.publicKey,
      'token': instance.token,
      'use_favorite': instance.useFavorite,
      'has_wallet_rights': instance.hasWalletRights,
      'use_show_partner_promo': instance.useShowPartnerPromo,
    };
